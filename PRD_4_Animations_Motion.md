# PRD 4: ANIMATIONS & MOTION SPECIFICATION
**Product:** Verba — AI Language Learning + Translation App  
**Version:** 1.0  
**Status:** Execution Ready  
**Last Updated:** April 2026  
**Animation Runtime:** Rive (primary) + Lottie (onboarding/celebration) + Flutter native animations

---

## ANIMATION PHILOSOPHY

**Core Principle:** Every animation must either communicate information, reinforce feedback, or delight the user — never purely decorative without purpose.

**Animation Tiers:**
- **Tier 1 (Critical):** Speaking feedback animations — must be frame-perfect, zero delay
- **Tier 2 (Important):** Screen transitions, mascot reactions — must feel smooth
- **Tier 3 (Delight):** Celebration effects, achievement unlocks — can be elaborate

**Performance Targets:**
- All animations: 60fps minimum on mid-range Android (Snapdragon 6xx)
- Speaking feedback animation trigger latency: <16ms after feedback received
- Mascot state transitions: <200ms interpolation
- Screen transitions: 250–350ms standard

---

## 1. MASCOT — RIVE SPECIFICATION

### 1.1 Mascot Concept
**Name:** VERN (Verba's Expressive Recognition Node)
**Design:** Friendly, geometric, abstract language-learning companion
**Style:** Rounded, flat geometric shapes with a glowing core
**Visual Description:** 
- Primary body: Rounded hexagonal shape, semi-transparent with gradient inner glow (indigo → violet)
- Eyes: Two circular glowing "lenses" — expression via eye shape/size
- Accent wings/fins: Subtle animated elements reflecting voice activity (think sound bars as "ears")
- Color base: Dark body with gradient luminescence matching app accent palette
- Physical personality: Curious, bouncy, enthusiastic — never static

**Size Usage:**
- Lesson screen: 180×180dp (prominent)
- Onboarding screens: 120×120dp (supporting)
- Home screen XP widget: 48×48dp (compact)
- Celebration overlay: 240×240dp (hero)

---

### 1.2 Rive State Machine — VERN

**Rive File:** `assets/rive/vern_mascot.riv`

**State Machine Name:** `VernStateMachine`

**States (8 total):**

#### State 1: `idle`
**Trigger:** Default fallback state, no interaction occurring
**Animation:**
- Gentle floating: Y-axis sine wave, amplitude ±6dp, period 3.0s
- Body slow pulse: Scale 1.0 → 1.03 → 1.0, period 2.5s
- Eyes: Slow blink every 4–5s (random interval 4–6s)
- Accent elements: Slow rotation 0.5 RPM
- Subtle glow pulse: opacity 0.6 → 1.0 → 0.6 on body glow layer, period 3s

**Flutter trigger code:**
```dart
_controller.setBoolInput('isIdle', true);
```

---

#### State 2: `listening`
**Trigger:** User taps mic, recording begins
**Animation:**
- "Ears" (accent fins): Spring into upright position (200ms elastic spring)
- Eyes: Widen to 1.3x normal size, pupils shift slightly toward user
- Body: Leans forward (rotate -5° on X from center)
- Sound bar visualizers: 3 small bars on sides of head animate with fake audio reactivity (random shuffle at 8fps to simulate hearing)
- Overall scale: Grows to 1.05x (100ms ease-out)
- Glow: Pulses fast — 0.8s period, blue tint shifts to represent active listening

**Flutter trigger code:**
```dart
_controller.setBoolInput('isListening', true);
_controller.setBoolInput('isIdle', false);
```

---

#### State 3: `speaking`
**Trigger:** ElevenLabs audio begins playing
**Animation:**
- Mouth element: Opens and closes in sync with speech rhythm (approximated by audio amplitude)
- Body: Small rhythmic bobbing, period synced to speech cadence (~400ms)
- Eyes: Warm expression, slight squint (friendly speaking look)
- Glow: Warmer color shift (slight violet → gold pulse during speech)
- Lips element: Animated waveform shape below eyes (scales X with amplitude)

**Flutter trigger:**
- Listen to audio player amplitude stream
- Pipe amplitude (0.0–1.0) to Rive number input: `_controller.setNumberInput('speakAmplitude', amplitude)`

---

#### State 4: `celebrating`
**Trigger:** User achieves SUCCESS feedback on a turn
**Animation:**
- Body: Jumps up +30dp, bounces back with elastic spring (600ms total)
- Arms/side elements: Throw up in celebration V shape
- Stars: 6–8 small star particles burst from body (Rive particle simulation)
- Eyes: Happy crescent (^_^) shape for 1.5s
- Sparkle ring: Expands from center outward (scale 0.0 → 1.5, fade out 1.0s)
- Body color: Flash bright white → return to normal (80ms)
- Mini confetti: 12 small dots scatter from body position

**Duration:** 1.8s total, then return to idle
**Flutter trigger:**
```dart
_controller.setTrigger('celebrate');
```

---

#### State 5: `thinking`
**Trigger:** AI processing speech, waiting for Gemini eval response
**Animation:**
- Body: Tilts head (rotates 8° right)
- "..." thought dots: Appear above head, dots pulse in sequence (0.4s stagger)
- Eyes: One slightly squinted (thinking look)
- Subtle body pulse: Slower than idle (4s period)
- Processing ring: Circular dotted line slowly rotates around body (360°/3s)

**Flutter trigger:**
```dart
_controller.setBoolInput('isThinking', true);
```

---

#### State 6: `encouraging`
**Trigger:** WARNING feedback (almost correct)
**Animation:**
- Body: Wobbles gently side to side (±10° rotation, 3 oscillations over 0.8s)
- One "thumbs up" gesture element appears then disappears (fade in 0.2s, hold 0.5s, fade out 0.3s)
- Warm amber glow pulse (matching warning color)
- Eyes: Encouraging wide look, slight nod (body Y oscillation)

**Duration:** 1.2s, then return to idle

---

#### State 7: `sad` / `retry`
**Trigger:** ERROR feedback (wrong answer, retry needed)
**Animation:**
- Eyes: Downturned sad expression (0.5s transition)
- Body: Slight deflation (scale 1.0 → 0.95 over 300ms)
- Shake: Horizontal head shake ±5dp, 3 oscillations, 500ms
- Color tint: Slight desaturation for 0.8s then recover
- Red glow ring: Appears then quickly fades (400ms in, 400ms out)

**Duration:** 1.2s total, then transition to `encouraging`

---

#### State 8: `excited`
**Trigger:** Milestone achievement, perfect lesson completion, new streak record
**Animation:**
- All celebration particles doubled
- VERN grows to 1.15x size (elastic spring)
- Full color flash: gradient sweep across body (left to right, 0.5s)
- Stars + rainbow arc: Multiple arcs expand from VERN body
- Vibration echo: 3 concentric rings expand outward from body center
- Loop bouncing: 3 full jump cycles instead of 1

**Duration:** 3.0s, requires user tap to dismiss
**Flutter trigger:**
```dart
_controller.setTrigger('megaCelebrate');
```

---

### 1.3 State Transition Rules

```
idle → listening    (on mic tap)
listening → thinking    (on mic release)
thinking → celebrating  (on success feedback)
thinking → encouraging  (on warning feedback)
thinking → sad          (on error feedback)
sad → encouraging       (auto after 1.2s)
encouraging → idle      (after retry prompt shown)
celebrating → idle      (after 1.8s)
any state → speaking    (when ElevenLabs audio starts)
speaking → idle         (when audio ends)
idle → excited          (on milestone achievement)
excited → idle          (after 3.0s or user tap)
```

---

## 2. UI ANIMATIONS

### 2.1 Screen Transitions

**Standard Push (A → B):**
```
Outgoing screen A: Slide left + fade (opacity 1.0→0.6) — 280ms cubic ease-in-out
Incoming screen B: Slide from right (offset 30px→0) + fade (0.0→1.0) — 280ms cubic ease-in-out
```

**Modal presentation (any → paywall/achievement):**
```
Backdrop: Opacity 0.0 → 0.6, color black, 200ms
Modal content: Scale 0.92 → 1.0 + translateY (60px→0) — 320ms spring (damping: 0.8)
```

**Dismiss modal:**
```
Modal content: Scale 1.0 → 0.95 + translateY (0→80px) — 250ms ease-in
Backdrop: Opacity 0.6 → 0.0 — 200ms
```

**Bottom sheet (bridge CTA, settings):**
```
Sheet: translateY (fullHeight → 0) — 350ms spring (damping: 0.78)
Backdrop: Opacity 0.0 → 0.5 — 250ms
```

**Tab switch:**
```
No slide. Content: Cross-fade 150ms + scale 0.97→1.0 (new tab content)
Icon: Bounce spring (scale 1.0→1.2→1.0, 200ms)
```

---

### 2.2 Button Press Animations

**Primary CTA Button (gradient):**
```
On press down: Scale 0.96, 80ms ease-out
On release: Scale 1.0, bounce spring 160ms
Haptic: Medium impact
Visual: Glow behind button pulses brighter on press
```

**Mic Button:**
```
On press: Scale 0.9 + glow expands, 100ms ease-out
While held: Gradient ring pulses outward (ring expands 80dp→96dp→80dp, 600ms loop)
On release: Scale returns 0.9→1.0, spring 200ms
```

**Language chip (selection):**
```
On tap: Scale 0.95→1.05→1.0, 200ms
Background: Cross-fade to gradient fill, 200ms
Border: Glow appears, 200ms
```

**Social auth buttons:**
```
On press: Opacity 0.8, scale 0.98, 80ms
On release: Opacity 1.0, scale 1.0, spring 150ms
Haptic: Light impact
```

**[Next →] navigation:**
```
Ripple effect from tap point, 300ms
Arrow icon translates +4px right, then returns (shuttle effect), 200ms
```

---

### 2.3 Progress Indicators

**XP Progress Bar:**
```
On XP gain:
  1. Bar fills to new position (ease-out cubic, duration = dist_px × 4ms min 300ms, max 1200ms)
  2. Shimmer overlay sweeps left→right across filled portion (400ms after fill)
  3. Level-up: Bar flashes white, empties, then fills from 0 to new position

Idle state: Subtle shimmer loops every 8s (keeps bar alive)
```

**Lesson Turn Progress Bar (top of lesson screen):**
```
On turn complete: Fills one segment over 300ms ease-out
Color: Gradient fill matching accuracy (green=100%, amber=60%, no fill=failed)
```

**Streak Counter:**
```
On increment: Number winds up (blur + scale 1.5→1.0) + flame emoji bounces
On streak break: Counter shakes + fade to grey briefly
```

**Circular Progress (plan loader, daily goal):**
```
Animated stroke dash: rotates from 0° to target°, speed = 1% per 15ms
Glow trail: subtle glow follows the stroke head
```

---

### 2.4 XP Pop Animation

Triggered every time XP is earned:

```
1. XP bubble appears at mic button center: "+5 XP"
   - Font: Heading 3, gradient text
   - Scale 0.0→1.2→1.0, 200ms spring

2. Bubble floats up: translateY 0 → -80dp over 1.0s ease-out

3. Bubble fades out: opacity 1.0→0.0 in last 300ms of travel

4. XP bar in header increments: smooth ease-out over 600ms

5. If level-up triggers: additional golden burst animation
```

---

### 2.5 Achievement Unlock Overlay

```
1. Screen overlay: dark bg fades in (opacity 0.0→0.8, 300ms)

2. Achievement card scales in: 0.7→1.0 + fade in (350ms spring)

3. Particle burst:
   - 20 particles, random velocities within 45° cone upward
   - Colors: gold, white, gradient primary
   - Particles: small circles 4–8dp
   - Duration: 800ms gravity fall

4. Achievement text: slide up from center (translateY 20→0, 250ms delay)

5. "Tap to continue" text: fade in after 1.0s

6. Dismiss: card scales down + fade out (200ms), then overlay fades
```

---

### 2.6 Onboarding-Specific Animations

**Screen 7 — Confidence Graph:**
```
Graph line draws from left_x to right_x:
  - Duration: 1.5s
  - Easing: ease-in-out
  - Both lines draw simultaneously, Verba line 20% faster
  - Data points: Appear with scale 0→1 spring as line reaches them
  - Area fill: Fades in after line completes (opacity 0→0.15, 300ms)
```

**Screen 8 — Speed Comparison:**
```
Number countdown animation for each tile:
  - "6 months" counts down: 60→6 months (number ticker, 1.5s)
  - "6 weeks" counts down: 60→6 weeks (20% faster, makes difference pop)
  - Both start simultaneously on screen enter
```

**Screen 9 — Plan Loader:**
```
Checklist items:
  - Each item: fade in + slide from translateX(-20px→0), staggered 500ms delay
  - Checkmark: Draws stroke (SVG path animation, 300ms)
  - Processing item: Skeleton shimmer placeholder, replaced on complete
  
Progress ring:
  - Stroked circle fills from 0% to 90% over 3.5s (eased)
  - At 100%: ring flashes then checkmark appears (spring scale 0→1)
```

---

## 3. VOICE INTERACTION ANIMATIONS

### 3.1 Waveform Visualization

**Component:** Custom Flutter `CustomPainter` widget + Rive integration

**Architecture:**
```
Audio stream → FFT processing → amplitude array[5] → 
  → Rive: pass amplitudes as number inputs
  → CustomPainter: draw 5 bars based on amplitude values
```

**Visual Specification:**
```
BARS:
  Count: 5 bars (could be 7 on larger screens)
  Width: 5dp each
  Gap: 4dp between bars
  Min height: 6dp (silence floor)
  Max height: 52dp (peak)
  Corner radius: 2.5dp (pill shape)
  
COLOR:
  Gradient fill per bar: bottom = primary (#4F46E5) → top = accent (#818CF8)
  Opacity during listening: 1.0
  Opacity during idle: 0.3 (hint bars)
  
ANIMATION:
  Height: Interpolated toward target amplitude with spring damping
  Spring params: stiffness 400, damping 28 (responsive but not jittery)
  Update rate: 30fps polling from audio stream
  
SYMMETRY:
  Bar 3 (center) = full amplitude
  Bars 2,4 = 0.75 × amplitude
  Bars 1,5 = 0.5 × amplitude
  (Creates natural mountain shape)
```

---

### 3.2 Mic Button Ring Glow States

**IDLE State:**
```
Ring: None visible
Glow: 0dp spread, static
```

**LISTENING State:**
```
Primary ring: 80dp → 92dp → 80dp pulsing (1.2s period)
Ring color: rgba(79,70,229,0.5) [indigo at 50%]
Ring width: 3dp stroke
Glow spread: 0 → 20dp → 0 (matches ring pulse)
Secondary outer ring: opacity 0.2, 80dp → 108dp → fade (same period, 0.4s delay)
```

**PROCESSING State:**
```
Ring: 80dp diameter, 3dp stroke, gradient
Animation: Rotates 360° per 1.2s (infinite)
Dash pattern: dash 60°, gap 300° (partial ring sweeping around)
```

**SUCCESS Burst:**
```
1. Ring color flashes green (rgba(16,185,129,1.0)) — 80ms
2. Ring expands rapidly: 80dp → 160dp in 400ms ease-out
3. Ring opacity: 1.0→0.0 simultaneously (ring disappears as it expands)
4. 8 small dots scatter outward on all axes (particle burst)
   - Dots: 6dp circles, gradient color
   - Travel distance: 30–50dp randomly
   - Duration: 400ms ease-out
   - Opacity: 1.0→0.0
5. Mic button: scale 1.0→1.15→1.0 (spring, 300ms)
```

**ERROR Shake:**
```
Mic button: translateX animation — 0→-8→8→-6→6→-4→4→0 (500ms, 7 oscillations)
Ring: Red rgba(239,68,68,0.5) flashes then fades (600ms)
Haptic: Error pattern (3 short vibrations)
```

---

### 3.3 Feedback Ring Transitions

**Turn Completion Feedback Animation Sequence:**
```
Frame 0ms:   Processing completes, feedback data received
Frame 16ms:  Mic button ring color transitions to result color (200ms crossfade)
Frame 50ms:  VERN mascot begins transition to result state
Frame 100ms: Feedback overlay fades in from bottom (translateY 20→0 + opacity 0→1, 250ms)
Frame 200ms: XP pop starts (if success)
Frame 350ms: Feedback CTA buttons appear (slide up from bottom, staggered 80ms each)
Frame 600ms: System idle — waiting for user tap or retry
```

---

## 4. RIVE FILE STRUCTURE

### 4.1 File Organization
```
assets/
  rive/
    vern_mascot.riv         ← Main mascot (all 8 states)
    ui_elements.riv         ← Reusable UI micro-animations
    celebrations.riv        ← Achievement/milestone animations
    onboarding.riv          ← Onboarding-specific flows
    
  lottie/
    plan_loading.json       ← Screen 9 plan loader animation
    confetti.json           ← Celebration confetti  
    bell_notification.json  ← Screen 12 bell animation
    sparkle.json            ← Generic sparkle/delight
```

### 4.2 Rive File: `vern_mascot.riv` — Internal Structure

```
Artboard: VernMascot (400×400 units)

Layers:
  └── BackgroundGlow (group)
      └── GlowCircle (ellipse, animated opacity/scale)
  └── Body (group)
      └── HexBody (shape, animated position/scale/rotation)
      └── BodyGlow (gradient fill layer, animated)
      └── CoreGem (inner shape, animated)
  └── LeftAccent (group — "ear" fin)
      └── AccentFin (shape, animated rotation)
      └── SoundBar1..3 (rectangles, animated scaleY)
  └── RightAccent (group — "ear" fin, mirror of left)
  └── FaceLayer (group)
      └── LeftEye (group)
          └── EyeBase (ellipse)
          └── Pupil (ellipse, animated position)
          └── EyeShape (animated for expressions)
      └── RightEye (group, mirror)
      └── MouthLayer (group)
          └── MouthCurve (path, animated points for expressions)
          └── SpeechBars[3] (tiny rectangles, animated scaleY for speaking)
  └── ArmLeft (group, optional — for celebration gestures)
  └── ArmRight (group)
  └── ParticleSystem (group)
      └── Stars[8] (shapes, animated position/opacity per state)
      └── ConfettiDots[12] (shapes, celebration only)

State Machine: VernStateMachine
  Inputs:
    Boolean: isIdle, isListening, isThinking, isSpeaking
    Trigger: celebrate, megaCelebrate, retry
    Number: speakAmplitude (0.0–1.0), listenAmplitude (0.0–1.0)
  
  States:
    IdleState → entries: [isIdle=true]
    ListeningState → entries: [isListening=true]
    ThinkingState → entries: [isThinking=true]
    SpeakingState → entries: [isSpeaking=true]
    CelebrationState → entries: [celebrate trigger]
    MegaCelebrationState → entries: [megaCelebrate trigger]
    EncouragingState → transition auto from ThinkingState (warning signal)
    RetryState → transition auto from ThinkingState (error signal)
    
  Transitions:
    All states → IdleState: when isIdle=true (100ms linear blend)
    IdleState → ListeningState: when isListening=true (200ms ease-out)
    ListeningState → ThinkingState: when isListening=false + isThinking=true (150ms)
    ThinkingState → CelebrationState: on celebrate trigger (instant)
    ThinkingState → EncouragingState: auto after warning set (100ms)
    ThinkingState → RetryState: auto after error set (100ms)
```

---

### 4.3 Rive File: `ui_elements.riv` — Internal Structure

```
Artboard: ProgressBar (400×24 units)
  └── BackTrack (rectangle, static, glass bg)
  └── FillBar (rectangle, animated width via state machine)
  └── ShimmerLayer (animated clip + opacity)
  State Machine: ProgressBarMachine
    Input Number: fillPercent (0–100)
    Input Trigger: levelUp

Artboard: XPBubble (160×60 units)
  └── BubbleBackground (glass rounded rect)
  └── XPText (+5 XP) (text, static — set via Rive text run API)
  └── AnimationController: pop scale + float up (triggered externally)

Artboard: MicRing (200×200 units)
  └── IdleRing (static)
  └── ListeningRing (pulsing stroke)
  └── ProcessingRing (rotating dash stroke)  
  └── SuccessRing (burst animation)
  └── ErrorRing (red flash + fade)
  State Machine: MicRingMachine
    Input: String micState ("idle"|"listening"|"processing"|"success"|"error")
```

---

### 4.4 Naming Conventions

**Artboards:** PascalCase, noun-first (`VernMascot`, `ProgressBar`, `MicRing`)
**Layers/Groups:** PascalCase, descriptive (`LeftAccent`, `FaceLayer`, `ParticleSystem`)
**Animations:** camelCase verbs (`idleFloat`, `listenLean`, `celebrationBurst`)
**State Machines:** PascalCase + `Machine` suffix (`VernStateMachine`, `MicRingMachine`)
**Inputs — Booleans:** `is` prefix camelCase (`isListening`, `isIdle`)
**Inputs — Triggers:** camelCase verb (`celebrate`, `retry`)
**Inputs — Numbers:** camelCase descriptive (`speakAmplitude`, `fillPercent`)

---

### 4.5 Flutter Rive Integration Code Pattern

```dart
// Load and initialize VERN mascot
late RiveAnimationController _vernController;
late StateMachineController _smController;
late SMIBool _isListening;
late SMIBool _isThinking;
late SMITrigger _celebrate;
late SMINumber _speakAmplitude;

void _onVernInit(Artboard artboard) {
  _smController = StateMachineController.fromArtboard(
    artboard, 
    'VernStateMachine'
  )!;
  artboard.addController(_smController);
  
  _isListening = _smController.findInput<bool>('isListening') as SMIBool;
  _isThinking = _smController.findInput<bool>('isThinking') as SMIBool;
  _celebrate = _smController.findInput<bool>('celebrate') as SMITrigger;
  _speakAmplitude = _smController.findInput<double>('speakAmplitude') as SMINumber;
}

// Trigger listening state
void startListening() {
  resetAllStates();
  _isListening.value = true;
}

// Trigger after STT/eval complete feedback
void showSuccess() {
  resetAllStates();
  _celebrate.fire();
}

// Update speaking amplitude in real-time
void updateSpeakAmplitude(double amplitude) {
  _speakAmplitude.value = amplitude;
}
```

---

### 4.6 Animation Trigger Reference Table

| User Action | Mascot State | Mic Animation | Screen Animation | Haptic |
|---|---|---|---|---|
| Open lesson screen | `idle` | idle glow | slide up | none |
| Tap mic button | `listening` | listening pulse ring | waveform fade in | medium |
| Release mic | `thinking` | processing rotate ring | bars freeze | none |
| Gemini returns SUCCESS | `celebrating` | success burst ring | XP pop + overlay | success pattern |
| Gemini returns WARNING | `encouraging` | amber flash ring | warning overlay | light |
| Gemini returns ERROR | `sad` → `encouraging` | red shake ring | error overlay | error pattern |
| Lesson complete (all turns) | `celebrating` | none | celebration screen | success heavy |
| Perfect lesson score | `excited` | confetti burst | achievement overlay | success long |
| New streak record | `excited` | none | achievement overlay | success long |
| XP level up | `celebrating` | gradient ring flash | level up banner | success medium |
| ElevenLabs audio plays | `speaking` | none | none | none |
| Audio ends | `idle` | none | none | none |

---

*End of PRD 4: Animations & Motion Specification*
