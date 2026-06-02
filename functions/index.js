// deploy: 2026-05-22 (raise generateLesson output tokens, disable thinking)
const {defineSecret} = require("firebase-functions/params");
const {HttpsError, onCall} = require("firebase-functions/v2/https");

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");
const googleTranslateApiKey = defineSecret("GOOGLE_TRANSLATE_API_KEY");

const region = "us-central1";
const geminiModel = process.env.GEMINI_MODEL || "gemini-2.5-flash";
const geminiBaseUrl =
  "https://generativelanguage.googleapis.com/v1beta/models";
const translateBaseUrl =
  "https://translation.googleapis.com/language/translate/v2";
const elevenLabsBaseUrl = "https://api.elevenlabs.io/v1";

const voiceIds = {
  English: "EXAVITQu4vr4xnSDxMaL",
  German: "pNInz6obpgDQGcFmaJgB",
  Spanish: "ErXwobaYiN019PkySvjV",
  French: "MF3mGyEYCl7XYWbV9V6O",
  Italian: "AZnzlk1XvdvUeBnXmlld",
  Japanese: "21m00Tcm4TlvDq8ikWAM",
  Korean: "XB0fDUnXU5powFXDhCwa",
  Portuguese: "onwK4e9ZLuTAKqWW03F9",
  Mandarin: "XB0fDUnXU5powFXDhCwa",
  Arabic: "zcAOhNBS3c14rBihAFp1",
  Hindi: "SOYHLrjzK2X1ezoPC6cr",
  Turkish: "IKne3meq5aSn9XLyUdCD",
  Dutch: "TxGEqnHWrfWFTfGW9XjX",
  Polish: "ZQe5CZNOzWyzPSCn5a3c",
  Russian: "29vD33N1CtxCmqQRPOHJ",
  Swedish: "pMsXgVXv3BLzUgSXRplE",
};

const langToIso = {
  English: "en",
  German: "de",
  Spanish: "es",
  French: "fr",
  Italian: "it",
  Japanese: "ja",
  Korean: "ko",
  Portuguese: "pt",
  Mandarin: "zh",
  Arabic: "ar",
  Hindi: "hi",
  Turkish: "tr",
  Dutch: "nl",
  Polish: "pl",
  Russian: "ru",
  Swedish: "sv",
};

function requireSignedIn(request) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in is required.");
  }
}

function asString(value, fallback = "") {
  return typeof value === "string" ? value.trim() : fallback;
}

function toIso(displayName) {
  const value = asString(displayName);
  return langToIso[value] || value.toLowerCase().slice(0, 2);
}

function safeProviderError(responseText, fallback) {
  let message = fallback;
  try {
    const json = JSON.parse(responseText);
    message = json?.error?.message || message;
  } catch (_) {
    message = responseText || message;
  }

  return String(message).slice(0, 500);
}

function parseJsonText(text) {
  try {
    return JSON.parse(text);
  } catch (error) {
    const match = text.match(/\{[\s\S]*\}/);
    if (!match) throw error;
    return JSON.parse(match[0]);
  }
}

function extractGeminiText(json) {
  const parts = json?.candidates?.[0]?.content?.parts || [];
  // When thinking is enabled, the model may return thinking in parts[0]
  // and the actual response in a later part. Take the last non-empty text.
  let text = "";
  for (const part of parts) {
    const t = asString(part?.text);
    if (t) text = t;
  }
  return text;
}

async function callGemini(body) {
  const url = `${geminiBaseUrl}/${geminiModel}:generateContent` +
    `?key=${geminiApiKey.value()}`;
  const response = await fetch(url, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify(body),
  });

  const responseText = await response.text();
  if (!response.ok) {
    console.error("Gemini API error", {
      status: response.status,
      model: geminiModel,
      body: responseText.slice(0, 500),
    });
    throw new HttpsError(
      "internal",
      `Gemini request failed with ${response.status}: ${safeProviderError(responseText, "unknown error")}`,
    );
  }

  return JSON.parse(responseText);
}

function callable(options, handler) {
  return onCall(
    {
      region,
      cors: true,
      enforceAppCheck: false,
      ...options,
    },
    async (request) => {
      requireSignedIn(request);
      return handler(request);
    },
  );
}

exports.generateLesson = callable(
  {secrets: [geminiApiKey], timeoutSeconds: 60, memory: "512MiB"},
  async (request) => {
    const targetLanguage = asString(request.data?.targetLanguage, "German");
    const level = asString(request.data?.level, "A1");
    const goalCategory = asString(request.data?.goalCategory, "travel");

    const prompt = `You are Verba's AI language tutor. Generate a structured speaking lesson.

Context:
- User's native language: English
- Target language: ${targetLanguage}
- Current level: ${level}
- Goal: ${goalCategory}
- Lesson theme: Daily conversational practice

Generate a JSON lesson with exactly 7 speaking turns. Return ONLY valid JSON, no markdown.

Format:
{
  "title": "Lesson title",
  "theme": "Brief theme description",
  "turns": [
    {
      "ai_prompt_text": "What the AI tutor says to the user (in English)",
      "target_phrase": "Phrase user should say in ${targetLanguage}",
      "phonetic_guide": "Readable phonetic spelling",
      "evaluation_focus": "What to evaluate",
      "success_feedback": "Encouraging message on success",
      "correction_hint": "Helpful hint on failure"
    }
  ]
}`;

    const json = await callGemini({
      contents: [{parts: [{text: prompt}]}],
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 4096,
        responseMimeType: "application/json",
        thinkingConfig: {thinkingBudget: 0},
      },
    });

    return parseJsonText(extractGeminiText(json));
  },
);

exports.evaluateSpeech = callable(
  {secrets: [geminiApiKey], timeoutSeconds: 45, memory: "512MiB"},
  async (request) => {
    const turn = request.data?.turn || {};
    const targetPhrase = asString(turn.targetPhrase);
    const phoneticGuide = asString(turn.phoneticGuide);
    const evaluationFocus = asString(turn.evaluationFocus);
    const correctionHint = asString(turn.correctionHint, "Try once more.");
    const transcription = asString(request.data?.transcription);
    if (!targetPhrase) {
      throw new HttpsError("invalid-argument", "targetPhrase is required.");
    }

    const prompt = `Evaluate this language learner's pronunciation attempt.

Target phrase: "${targetPhrase}"
Phonetic target: "${phoneticGuide}"
User's transcribed speech: "${transcription || "[no speech detected]"}"
Evaluation focus: ${evaluationFocus}

Rate on:
1. accuracy (0-100): Did they say the right words?
2. pronunciation (0-100): Were phonemes correct?
3. fluency (0-100): Was speech natural?

Return ONLY valid JSON, no markdown:
{"accuracy": INT, "pronunciation": INT, "fluency": INT, "feedback_type": "success"|"warning"|"error", "feedback_message": STRING}

Rules: success = accuracy>=85, warning = accuracy 60-84, error = accuracy<60
Fallback hint if needed: ${correctionHint}`;

    const json = await callGemini({
      contents: [{parts: [{text: prompt}]}],
      generationConfig: {
        temperature: 0.3,
        maxOutputTokens: 256,
        responseMimeType: "application/json",
        thinkingConfig: {thinkingBudget: 0},
      },
    });

    return parseJsonText(extractGeminiText(json));
  },
);

exports.getPhoneticGuide = callable(
  {secrets: [geminiApiKey], timeoutSeconds: 30, memory: "256MiB"},
  async (request) => {
    const phrase = asString(request.data?.phrase);
    const language = asString(request.data?.language, "English");
    if (!phrase) {
      throw new HttpsError("invalid-argument", "phrase is required.");
    }

    const prompt = `Provide a simple, readable phonetic pronunciation guide for the following phrase in ${language}.

Phrase: "${phrase}"

Rules:
- Write phonetics using uppercase syllables to show stress (e.g. "GOO-ten MOR-gen")
- Use simple English letter combinations that an English speaker would naturally read correctly
- Separate syllables with hyphens
- Separate words with spaces
- Return ONLY valid JSON, no markdown: {"phonetic": "YOUR_PHONETIC_HERE"}`;

    const json = await callGemini({
      contents: [{parts: [{text: prompt}]}],
      generationConfig: {
        temperature: 0.2,
        maxOutputTokens: 128,
        responseMimeType: "application/json",
        thinkingConfig: {thinkingBudget: 0},
      },
    });

    return parseJsonText(extractGeminiText(json));
  },
);

exports.transcribeAudio = callable(
  {secrets: [geminiApiKey], timeoutSeconds: 60, memory: "1GiB"},
  async (request) => {
    const audioBase64 = asString(request.data?.audioBase64);
    const languageHint = asString(request.data?.languageHint, "English");
    const mimeType = asString(request.data?.mimeType, "audio/wav");
    if (!audioBase64) {
      throw new HttpsError("invalid-argument", "audioBase64 is required.");
    }

    const json = await callGemini({
      contents: [
        {
          parts: [
            {
              text:
                "Transcribe the spoken words in this audio exactly. " +
                `Language: ${languageHint}. ` +
                "Return only the transcription, no other text.",
            },
            {
              inline_data: {
                mime_type: mimeType,
                data: audioBase64,
              },
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.0,
        maxOutputTokens: 256,
      },
    });

    return {transcription: extractGeminiText(json)};
  },
);

exports.detectLanguage = callable(
  {secrets: [googleTranslateApiKey], timeoutSeconds: 30, memory: "256MiB"},
  async (request) => {
    const text = asString(request.data?.text);
    if (!text) return {language: null};

    const response = await fetch(
      `${translateBaseUrl}/detect?key=${googleTranslateApiKey.value()}`,
      {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({q: text}),
      },
    );
    const responseText = await response.text();
    if (!response.ok) {
      const errorMessage = safeProviderError(
        responseText,
        `Google Translate detect failed with ${response.status}.`,
      );
      console.error("Google Translate detect failed", {
        status: response.status,
        textLength: text.length,
        error: errorMessage,
      });
      throw new HttpsError(
        "internal",
        `Translation detect failed with ${response.status}: ${errorMessage}`,
      );
    }

    const json = JSON.parse(responseText);
    const language = json?.data?.detections?.[0]?.[0]?.language || null;
    return {language};
  },
);

exports.translateText = callable(
  {secrets: [googleTranslateApiKey], timeoutSeconds: 30, memory: "256MiB"},
  async (request) => {
    const text = asString(request.data?.text);
    const sourceLang = asString(request.data?.sourceLang);
    const targetLang = asString(request.data?.targetLang);
    if (!text || !sourceLang || !targetLang) {
      throw new HttpsError(
        "invalid-argument",
        "text, sourceLang, and targetLang are required.",
      );
    }
    const sourceIso = toIso(sourceLang);
    const targetIso = toIso(targetLang);

    const response = await fetch(
      `${translateBaseUrl}?key=${googleTranslateApiKey.value()}`,
      {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({
          q: text,
          source: sourceIso,
          target: targetIso,
          format: "text",
        }),
      },
    );

    const responseText = await response.text();
    if (!response.ok) {
      const errorMessage = safeProviderError(
        responseText,
        `Google Translate failed with ${response.status}.`,
      );
      console.error("Google Translate translation failed", {
        status: response.status,
        sourceLang,
        targetLang,
        sourceIso,
        targetIso,
        textLength: text.length,
        error: errorMessage,
      });
      throw new HttpsError(
        "internal",
        `Translation failed with ${response.status}: ${errorMessage}`,
      );
    }

    const json = JSON.parse(responseText);
    const first = json?.data?.translations?.[0] || {};
    return {
      originalText: text,
      translatedText: first.translatedText || text,
      sourceLang,
      targetLang,
      detectedLanguage: first.detectedSourceLanguage || null,
    };
  },
);

exports.synthesizeSpeech = callable(
  {secrets: [elevenLabsApiKey], timeoutSeconds: 60, memory: "512MiB"},
  async (request) => {
    const text = asString(request.data?.text);
    const language = asString(request.data?.language, "English");
    const speed = Number(request.data?.speed || 1.0);
    if (!text) {
      throw new HttpsError("invalid-argument", "text is required.");
    }

    const voiceId = voiceIds[language] || voiceIds.English;
    const audio = await synthesizeWithVoice(text, voiceId, speed);
    return {
      audioBase64: audio.toString("base64"),
      contentType: "audio/mpeg",
    };
  },
);

async function synthesizeWithVoice(text, voiceId, speed) {
  const response = await fetch(
    `${elevenLabsBaseUrl}/text-to-speech/${voiceId}`,
    {
      method: "POST",
      headers: {
        "xi-api-key": elevenLabsApiKey.value(),
        "Content-Type": "application/json",
        Accept: "audio/mpeg",
      },
      body: JSON.stringify({
        text,
        model_id: "eleven_multilingual_v2",
        voice_settings: {
          stability: 0.8,
          similarity_boost: 0.7,
          speed,
        },
      }),
    },
  );

  if (!response.ok) {
    throw new HttpsError(
      "internal",
      `ElevenLabs request failed with ${response.status}.`,
    );
  }

  return Buffer.from(await response.arrayBuffer());
}
