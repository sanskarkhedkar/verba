# PRD 3: UI/UX SPECIFICATION
**Product:** Verba — AI Language Learning + Translation App  
**Version:** 1.0  
**Status:** Execution Ready  
**Last Updated:** April 2026  

---

## DESIGN SYSTEM FOUNDATION

### Color Palette

```
PRIMARY GRADIENT:
  Start: #4F46E5 (Indigo 600)
  End:   #7C3AED (Violet 600)
  Usage: Primary buttons, progress bars, accents, CTA backgrounds

BACKGROUND SYSTEM:
  bg_primary:    #0A0A0F   (Near-black — main screens)
  bg_surface:    #13131A   (Cards, bottom sheets)
  bg_elevated:   #1C1C28   (Input fields, elevated cards)
  bg_overlay:    rgba(255,255,255,0.05) (Glassmorphism surface)

TEXT SYSTEM:
  text_primary:   #FFFFFF   (Headlines, primary content)
  text_secondary: #A8A8C0   (Subtext, captions, labels)
  text_tertiary:  #5C5C7A   (Placeholders, disabled states)
  text_accent:    #818CF8   (Links, highlighted text)

SEMANTIC COLORS:
  success:  #10B981   (Correct answer feedback)
  warning:  #F59E0B   (Partial/almost feedback)
  error:    #EF4444   (Wrong answer feedback)
  info:     #3B82F6   (Info states)

GLASSMORPHISM:
  glass_bg:     rgba(255,255,255,0.06)
  glass_border: rgba(255,255,255,0.12)
  glass_blur:   12px (BackdropFilter)
```

### Typography — Bricolage Grotesque

```
Display XL: Bricolage Grotesque, 40sp, Weight 800, Line height 1.15
Display L:  Bricolage Grotesque, 32sp, Weight 700, Line height 1.2
Heading 1:  Bricolage Grotesque, 28sp, Weight 700, Line height 1.25
Heading 2:  Bricolage Grotesque, 24sp, Weight 600, Line height 1.3
Heading 3:  Bricolage Grotesque, 20sp, Weight 600, Line height 1.35
Body L:     Bricolage Grotesque, 18sp, Weight 400, Line height 1.5
Body M:     Bricolage Grotesque, 16sp, Weight 400, Line height 1.5
Body S:     Bricolage Grotesque, 14sp, Weight 400, Line height 1.5
Caption:    Bricolage Grotesque, 12sp, Weight 400, Line height 1.4
Button:     Bricolage Grotesque, 16sp, Weight 600, Letter spacing: 0.2
```

### Spacing System
```
xs: 4px | sm: 8px | md: 16px | lg: 24px | xl: 32px | 2xl: 48px | 3xl: 64px
```

### Border Radius
```
xs: 8px  (chips, small elements)
sm: 12px (buttons)
md: 16px (cards)
lg: 24px (bottom sheets, large cards)
xl: 32px (full-rounded containers)
circle: 50% (mic button, avatars)
```

### Elevation / Shadow
```
shadow_sm: 0 2px 8px rgba(0,0,0,0.3)
shadow_md: 0 4px 20px rgba(0,0,0,0.4)
shadow_glow_blue: 0 0 24px rgba(79,70,229,0.3)   (active mic, CTAs)
shadow_glow_green: 0 0 24px rgba(16,185,129,0.3)  (success states)
```

### Glassmorphism Component Spec
```
Container:
  color: rgba(255,255,255,0.06)
  border: 1px solid rgba(255,255,255,0.12)
  borderRadius: 16–24px
  backdropFilter: blur(12px)
  
Use on: Translation result cards, lesson cards, bottom sheets,
        achievement celebrations, paywall option cards.
```

---

## 1. ONBOARDING FLOW — 15 SCREENS (COMPLETE SPECIFICATION)

### Global Onboarding Rules
- Progress indicator: thin line at top, fills screen by screen (not visible on screen 1)
- "Back" behavior: swipe right or tap back icon (never system back on paywall)
- All screens: Dark bg_primary background
- Entry animation per screen: Slide up + fade in (300ms)
- Skip button: Small text link in top-right on screens 3–6 only

---

### SCREEN 1: WELCOME

**Layout:** Full-screen, centered content
**No progress bar on this screen**

```
┌──────────────────────────────────┐
│                                  │
│     [Verba Logo + wordmark]      │
│     Lottie: Mascot idle wave     │
│                                  │
│                                  │
│  ┌────────────────────────────┐  │
│  │  Start Speaking [Language] │  │
│  │       Today — Free         │  │
│  └────────────────────────────┘  │
│                                  │
│  [Select your language]          │
│  ┌────────┐ ┌────────┐ ┌──────┐ │
│  │🇩🇪 DE │ │🇪🇸 ES │ │🇫🇷 FR│ │
│  └────────┘ └────────┘ └──────┘ │
│  ┌────────┐ ┌────────┐ ┌──────┐ │
│  │🇯🇵 JP │ │🇰🇷 KR │ │ More │ │
│  └────────┘ └────────┘ └──────┘ │
│                                  │
│  ┌──────────────────────────────┐│
│  │     Get Started →            ││
│  └──────────────────────────────┘│
│                                  │
│  Already have an account? Log in │
└──────────────────────────────────┘
```

**Components:**
- Verba logo: SVG wordmark, gradient text (left-right: indigo → violet)
- Lottie mascot: 120×120px, idle wave animation (loops)
- Headline: `Display L` — "Start Speaking [Language] Today — Free"
- Language grid: 6 chips, rounded 40px, selected state = gradient fill
- CTA: Full-width gradient button (48dp height)
- Login link: `Body S`, `text_secondary` color

**State:** Language selected → store in local state → CTA becomes active

---

### SCREEN 2: LANGUAGE SELECTION (FULL)

**Layout:** Full search + grid list
**Progress bar: 7%**

```
┌──────────────────────────────────┐
│ ← [Back]         [    2/15    ] │
│                                  │
│  Which language do you want      │
│  to learn?                       │
│                                  │
│  ┌──────────────────────────┐    │
│  │ 🔍  Search languages...  │    │
│  └──────────────────────────┘    │
│                                  │
│  POPULAR                         │
│  ┌──────┐ ┌──────┐ ┌──────┐     │
│  │🇩🇪 DE│ │🇪🇸 ES│ │🇫🇷 FR│     │
│  │German│ │Span. │ │French│     │
│  └──────┘ └──────┘ └──────┘     │
│  ┌──────┐ ┌──────┐ ┌──────┐     │
│  │🇯🇵 JP│ │🇰🇷 KR│ │🇮🇹 IT│     │
│  │Japan.│ │Korean│ │Ital. │     │
│  └──────┘ └──────┘ └──────┘     │
│                                  │
│  ALL LANGUAGES (A–Z list)        │
│  [Scrollable list...]            │
│                                  │
│  ┌──────────────────────────────┐│
│  │     Continue →               ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Exact Copy:**
- Headline: `Heading 1` — "Which language do you want to learn?"
- Section labels: `Caption` uppercase, `text_secondary`
- Language chips: Flag emoji + full language name below, 80×80px cards, rounded 16px
- Selected: gradient border 2px + gradient background at 15% opacity

---

### SCREEN 3: SKILL LEVEL

**Progress bar: 14%**

```
┌──────────────────────────────────┐
│ ←              3/15              │
│                                  │
│  What's your [German] level?     │
│                                  │
│  ┌──────────────────────────────┐│
│  │ 🌱 Complete Beginner         ││
│  │ I don't know any [German]    ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 📗 Know a Few Words          ││
│  │ I know greetings & basics    ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 📘 Elementary               ││
│  │ Can handle simple sentences  ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 📙 Intermediate             ││
│  │ Can have basic conversations ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 📕 Advanced                  ││
│  │ Comfortable but not fluent   ││
│  └──────────────────────────────┘│
│                                  │
│  [Auto-advance on selection]     │
└──────────────────────────────────┘
```

**Behavior:** Single tap on option → immediate auto-advance to next screen (no CTA button needed)
**Selected state:** Gradient background + white checkmark on right, 500ms highlight then advance

---

### SCREEN 4: MOTIVATION

**Progress bar: 21%**

```
┌──────────────────────────────────┐
│ ←              4/15              │
│                                  │
│  Why are you learning            │
│  [German]?                       │
│  Choose your main reason         │
│                                  │
│  ✈️  Travel & Adventure          │
│  💼  Work & Career               │
│  ❤️  Family & Relationships      │
│  🧠  Personal Challenge          │
│  🎓  School / Academia           │
│  🌎  Connect with Culture        │
│  🤝  Moving / Living Abroad      │
│                                  │
│  [Auto-advance on selection]     │
└──────────────────────────────────┘
```

**Layout:** Vertical list of large tap targets (56dp height each), emoji + text, full-width, glass card per item

---

### SCREEN 5: DAILY GOAL

**Progress bar: 28%**

```
┌──────────────────────────────────┐
│ ←              5/15              │
│                                  │
│  How much time can you           │
│  practice each day?              │
│                                  │
│  "Even 5 minutes daily beats     │
│   1 hour once a week."           │
│                                  │
│  ┌──────────────────────────────┐│
│  │   ⚡ 5 min · Casual Learner  ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│ ← RECOMMENDED (badge)
│  │   🎯 10 min · Regular        ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │   🔥 15 min · Committed      ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │   🚀 20 min · Intensive      ││
│  └──────────────────────────────┘│
│                                  │
└──────────────────────────────────┘
```

**Components:**
- Quote: `Body S`, italic, `text_secondary`
- Options: tap cards (like Screen 3), auto-advance on selection
- "RECOMMENDED" badge: small gradient pill on the 10-min option

---

### SCREEN 6: FOCUS AREA

**Progress bar: 35%**

```
┌──────────────────────────────────┐
│ ←              6/15              │
│                                  │
│  What do you most want to        │
│  improve?                        │
│  Select all that apply           │
│                                  │
│  ┌──────────┐ ┌──────────┐       │
│  │ 🎤       │ │ 📝       │       │
│  │ Speaking │ │ Writing  │       │
│  └──────────┘ └──────────┘       │
│  ┌──────────┐ ┌──────────┐       │
│  │ 👂       │ │ 📖       │       │
│  │Listening │ │ Reading  │       │
│  └──────────┘ └──────────┘       │
│  ┌──────────┐ ┌──────────┐       │
│  │ 🗣️       │ │ 🌍       │       │
│  │ Vocab    │ │ Culture  │       │
│  └──────────┘ └──────────┘       │
│                                  │
│  ┌──────────────────────────────┐│
│  │     Continue →               ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Multi-select grid:** 2 columns, 120×120dp each, toggle selection
**Selected state:** Gradient border + gradient fill at 15%
**CTA:** Enabled when ≥1 selected

---

### SCREEN 7: CONFIDENCE GRAPH

**Progress bar: 42%**

```
┌──────────────────────────────────┐
│ ←              7/15              │
│                                  │
│  Here's where most               │
│  [Goal] learners start           │
│                                  │
│   Confidence Level               │
│  ┌──────────────────────────────┐│
│  │         ╭──────────────      ││
│  │        ╱  Verba Users        ││
│  │   ────╱                      ││
│  │  Typical apps                ││
│  │──────────────────────────────││
│  │  Week 1  Week 2  Month 1     ││
│  └──────────────────────────────┘│
│                                  │
│  💡 Verba users report feeling  │
│     confident after just 2 weeks│
│                                  │
│  ┌──────────────────────────────┐│
│  │     That's Me! →             ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Animation:** Line chart animates in on screen enter (draw from left to right, 1.5s)
**Chart colors:** Verba line = gradient stroke; typical apps = `text_tertiary` dashed line

---

### SCREEN 8: SPEED COMPARISON

**Progress bar: 49%**

```
┌──────────────────────────────────┐
│ ←              8/15              │
│                                  │
│  Verba's AI speaks               │
│  with you, not at you            │
│                                  │
│  ┌──────────┐  ┌───────────────┐ │
│  │  📱 Text │  │  🎤 Speaking  │ │
│  │   apps   │  │  with Verba   │ │
│  │          │  │               │ │
│  │ 6 months │  │  6 weeks      │ │
│  │ to hold a│  │  to hold a    │ │
│  │ conversation  │  conversation  │ │
│  └──────────┘  └───────────────┘ │
│                                  │
│  ⚡ The speaking method: proven  │
│  by research to be 4x faster     │
│                                  │
│  ┌──────────────────────────────┐│
│  │     Let's Do It →            ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Animation:** Counter animation on "6 months" vs "6 weeks" — numbers count down on enter

---

### SCREEN 9: PLAN LOADER

**Progress bar: 56%**

```
┌──────────────────────────────────┐
│                                  │
│     Building your personal       │
│     [German] plan...             │
│                                  │
│   [Lottie: AI processing / dots] │
│                                  │
│  ✅ Analyzing your goals...      │
│  ✅ Finding your level...        │
│  ✅ Creating your lesson path... │
│  ⏳ Personalizing vocabulary...  │
│  ⏳ Setting daily targets...     │
│                                  │
│   [Progress ring: 80% complete] │
│                                  │
└──────────────────────────────────┘
```

**Timing:** Each checklist item animates in with 600ms delay
**Total Screen Duration:** 4 seconds, then auto-advance
**This creates Firebase Anonymous Auth** silently in background

---

### SCREEN 10: OUTCOME PREVIEW

**Progress bar: 63%**

```
┌──────────────────────────────────┐
│ ←              10/15             │
│                                  │
│  In 30 days, you'll be able to: │
│                                  │
│  ┌──────────────────────────────┐│
│  │ 🗺️ Navigate [Germany] alone  ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 🛒 Shop, eat, order          ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 👋 Introduce yourself        ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │ 💬 Hold basic conversations  ││
│  └──────────────────────────────┘│
│                                  │
│  ✨ Powered by your [Travel]     │
│     goal and [10 min/day] plan  │
│                                  │
│  ┌──────────────────────────────┐│
│  │     Sounds good! →           ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Outcome items:** Dynamic based on motivation selected on Screen 4

---

### SCREEN 11: SOCIAL PROOF

**Progress bar: 70%**

```
┌──────────────────────────────────┐
│ ←              11/15             │
│                                  │
│  Join 2M+ people speaking        │
│  with confidence                 │
│                                  │
│  ⭐⭐⭐⭐⭐  4.9 · 12,400 reviews  │
│                                  │
│  ┌──────────────────────────────┐│
│  │ "I was terrified to speak    ││
│  │  German. After 3 weeks with  ││
│  │  Verba, I ordered dinner in  ││
│  │  Berlin. I cried." 🥹        ││
│  │                              ││
│  │  — Priya R., ⭐⭐⭐⭐⭐         ││
│  └──────────────────────────────┘│
│                                  │
│  [Horizontal scroll: 3 cards]    │
│  [Card 2] [Card 3]               │
│                                  │
│  🏆 #1 Language App in India     │
│  🏆 App Store Editors' Choice    │
│                                  │
│  ┌──────────────────────────────┐│
│  │     I'm Ready →              ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Testimonial cards:** Glassmorphism cards, horizontal PageView, 3 testimonials

---

### SCREEN 12: NOTIFICATIONS OPT-IN

**Progress bar: 77%**

```
┌──────────────────────────────────┐
│ ←              12/15             │
│                                  │
│   🔔                             │
│   [Lottie: gentle bell animation]│
│                                  │
│  Never miss a practice           │
│  session                         │
│                                  │
│  Learners who practice daily     │
│  are 5x more likely to reach     │
│  their goal                      │
│                                  │
│  ┌──────────────────────────────┐│
│  │ 📅 Remind me daily at:       ││
│  │ [Time picker: 08:00 AM]      ││
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │     Turn On Reminders ✓      ││
│  └──────────────────────────────┘│
│                                  │
│         Maybe Later (skip)       │
└──────────────────────────────────┘
```

**Behavior:** "Turn On Reminders" → requests FCM permission → saves notification_time
**Time picker:** native iOS/Android time picker, default: 8:00 AM

---

### SCREEN 13: NAME INPUT

**Progress bar: 84%**

```
┌──────────────────────────────────┐
│ ←              13/15             │
│                                  │
│  What should we call you?        │
│                                  │
│                                  │
│  ┌──────────────────────────────┐│
│  │  Your first name...          ││
│  └──────────────────────────────┘│
│                                  │
│  Your name appears in your       │
│  lessons and achievements        │
│                                  │
│                                  │
│                                  │
│  ┌──────────────────────────────┐│
│  │     Continue →               ││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Input field:** Glass background, 56dp height, auto-focus on enter
**CTA:** Enabled when ≥2 characters entered

---

### SCREEN 14: AUTHENTICATION

**Progress bar: 91%**

```
┌──────────────────────────────────┐
│ ←              14/15             │
│                                  │
│  Hi [Name]! Save your            │
│  progress forever                │
│                                  │
│  Create your free account        │
│  to keep your plan safe          │
│                                  │
│  ┌──────────────────────────────┐│
│  │ G  Continue with Google      ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │   Continue with Apple        ││
│  └──────────────────────────────┘│
│                                  │
│  ─────────── or ──────────────   │
│                                  │
│  ┌──────────────────────────────┐│
│  │  Your email address          ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │  Create password             ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │     Create Account →         ││
│  └──────────────────────────────┘│
│                                  │
│  By continuing, you agree to     │
│  our Terms & Privacy Policy      │
└──────────────────────────────────┘
```

**Auth buttons:** Google = white bg, black text; Apple = black bg, white text
**On success:** All onboarding data written to Firestore → advance to Screen 15

---

### SCREEN 15: PAYWALL

**No progress bar — this is a standalone conversion screen**

```
┌──────────────────────────────────┐
│  [Close ×]                       │
│                                  │
│  [Lottie: celebration/sparkle]   │
│                                  │
│  Your personalized [German]      │
│  plan is ready, [Name]!          │
│                                  │
│  ⭐ Unlimited lessons             │
│  ⭐ AI speaking coach            │
│  ⭐ Pronunciation feedback       │
│  ⭐ Translation tools            │
│  ⭐ Works offline                 │
│                                  │
│  ╔══════════════════════════════╗ │
│  ║  ANNUAL   BEST VALUE  -60%  ║ │
│  ║  $59.99/year  (~$5/month)   ║ │
│  ║  [Try 7 days free]          ║ │
│  ╚══════════════════════════════╝ │
│  ┌──────────────────────────────┐│
│  │  MONTHLY  $9.99/month        ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │  LIFETIME  $149.99 once      ││
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │  Start 7-Day Free Trial →    ││
│  └──────────────────────────────┘│
│                                  │
│  ↓ Continue with limited access  │
│                                  │
│  Cancel anytime · No commitment  │
│  Terms · Privacy · Restore       │
└──────────────────────────────────┘
```

**Annual card:** Elevated, gradient border glow, "BEST VALUE" badge in gradient
**Monthly + Lifetime:** Glass cards, unselected initially
**CTA copy:** Changes based on selected plan

---

## 2. HOME SCREEN

### Tab Bar Structure (Bottom Navigation)
```
[ Learn ]  [ Speak ]  [ Tools ]  [ Profile ]
  Book      Mic icon   Translate   Person
```

**Active tab:** Icon + label in gradient color; inactive = `text_tertiary`

---

### 2.1 LEARN TAB (Home)

```
┌──────────────────────────────────┐
│  Good morning, [Name] ☀️         │
│  [German] · Level A2            │
│                                  │
│  ┌──────────────────────────────┐│
│  │  🔥 [N]-day streak           ││
│  │  [XP progress bar]           ││
│  │  [N] / 500 XP to B1         ││
│  └──────────────────────────────┘│
│                                  │
│  TODAY'S LESSON                  │
│  ┌──────────────────────────────┐│
│  │  🎯 German Greetings         ││
│  │  Practice 7 phrases          ││
│  │  ~8 min                      ││
│  │                              ││
│  │  [Start Lesson →]            ││
│  └──────────────────────────────┘│
│                                  │
│  CONTINUE LEARNING               │
│  [Horizontal scroll: lesson cards]│
│  ┌────────┐ ┌────────┐ ┌───────┐ │
│  │Numbers │ │Colors  │ │Food   │ │
│  └────────┘ └────────┘ └───────┘ │
│                                  │
│  YOUR PROGRESS                   │
│  [Mini chart: 7-day accuracy]    │
│  [Words learned: 47]             │
│                                  │
│  RECENT ACHIEVEMENT              │
│  🏆 "First Step" - Completed 5   │
│     lessons                      │
└──────────────────────────────────┘
```

---

### 2.2 SPEAK TAB

```
┌──────────────────────────────────┐
│  Speaking Lab                    │
│                                  │
│  ┌──────────────────────────────┐│
│  │  🎤 Quick Speaking Practice  ││
│  │  Tap to start a 3-min drill  ││
│  │  [Start →]                   ││
│  └──────────────────────────────┘│
│                                  │
│  OR PRACTICE A PHRASE            │
│  ┌──────────────────────────────┐│
│  │  Type or paste any phrase... ││
│  └──────────────────────────────┘│
│  [Practice This Phrase →]        │
│                                  │
│  CONVERSATION SIMULATOR 🔒       │
│  ┌──────────────────────────────┐│
│  │  Practice real conversations ││
│  │  Premium feature             ││
│  │  [Try Free →]               ││
│  └──────────────────────────────┘│
│                                  │
│  YOUR SPEAKING STATS             │
│  Accuracy avg: 78% ↑             │
│  Best streak: 14 days            │
│  Total practice: 4h 32m          │
└──────────────────────────────────┘
```

---

### 2.3 TOOLS TAB

```
┌──────────────────────────────────┐
│  Translation Tools               │
│                                  │
│  ┌───────────┐ ┌───────────┐     │
│  │ 🎤 Voice  │ │ ✏️ Text   │     │
│  │ Translate │ │ Translate │     │
│  └───────────┘ └───────────┘     │
│  ┌───────────┐ ┌───────────┐     │
│  │ 📷 Image  │ │ 👥 Face-  │     │
│  │ Translate │ │ to-Face   │     │
│  └───────────┘ └───────────┘     │
│                                  │
│  ─────  QUICK TRANSLATE  ─────   │
│  ┌──────────────────────────────┐│
│  │  English → German      🔄    ││
│  │                              ││
│  │  Type here...                ││
│  │                              ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │  [Translation appears here] ││
│  │  🔊 [Practice This]         ││
│  └──────────────────────────────┘│
│                                  │
│  PHRASEBOOK                      │
│  [Recent saved phrases]          │
│  "Guten Morgen" 🔊               │
│  "Danke schön" 🔊                │
└──────────────────────────────────┘
```

---

## 3. LESSON UI — DETAILED SPECIFICATION

### 3.1 Lesson Header
```
┌──────────────────────────────────┐
│ [×] Close            [2/7]       │
│ ████████░░░░░░░░░░░░░░░░  (28%)  │ ← Progress bar
└──────────────────────────────────┘
```

### 3.2 Turn Layout (Speaking)
```
┌──────────────────────────────────┐
│                                  │
│  [Mascot: idle/ears perked]      │
│                                  │
│  ─────── AI TUTOR SAYS ──────── │
│                                  │
│  "Now try saying good morning   │
│   in German:"                    │
│                                  │
│  ┌──────────────────────────────┐│
│  │                              ││
│  │     Guten Morgen             ││ ← Target phrase, Display L
│  │                              ││
│  │  GOO-ten MOR-gen             ││ ← Phonetic guide, italic Body M
│  │                              ││
│  └──────────────────────────────┘│
│                                  │
│  🔊 [Listen again]               │
│                                  │
│                                  │
│        ┌───────────┐             │
│        │     🎤    │             │ ← Mic button (80dp circle)
│        │  Tap here │             │
│        └───────────┘             │
│                                  │
│        Hold to speak             │
│                                  │
└──────────────────────────────────┘
```

### 3.3 Mic Button States
```
IDLE:      80dp circle, glass bg, mic icon white, subtle pulse glow
LISTENING: 80dp circle, gradient bg, waveform replaces icon, shadow_glow_blue
PROCESSING:80dp circle, gradient bg, rotating ring around circle
SUCCESS:   80dp circle, success green bg, checkmark icon, shadow_glow_green
WARNING:   80dp circle, warning amber bg, tilde icon
ERROR:     80dp circle, error red bg → shimmer animate → back to idle
```

### 3.4 Waveform Display
```
During recording:
  - 5 vertical bars centered below mic button
  - Bars animate with audio amplitude (FFT visualization)
  - Bar colors: gradient from primary to accent
  - Height range: 8dp (silence) to 48dp (peak)
  - Animation: smooth interpolation at 30fps
```

### 3.5 Feedback States

**SUCCESS State:**
```
┌──────────────────────────────────┐
│  [Mascot: celebration dance]     │
│                                  │
│  ✅  Perfect!                    │  ← Heading 1, success green
│                                  │
│  "You nailed the G sound!"       │  ← Body M
│                                  │
│  +5 XP  ●●●●●● (12 XP today)    │  ← XP animation pop
│                                  │
│  [Next →]        [Replay]        │
└──────────────────────────────────┘
```

**WARNING State:**
```
┌──────────────────────────────────┐
│  [Mascot: thoughtful/encouraging]│
│                                  │
│  ⚠️  Almost there!              │
│                                  │
│  "Try rounding your lips for    │
│   the 'u' in Morgen"            │
│                                  │
│        ┌─────────┐   ┌─────────┐│
│        │  Retry  │   │  Next → ││
│        └─────────┘   └─────────┘│
└──────────────────────────────────┘
```

**ERROR State:**
```
┌──────────────────────────────────┐
│  [Mascot: gentle shake head]     │
│                                  │
│  ❌  Let's try that again       │
│                                  │
│  Listen to the correct way:     │
│   🔊 [Normal speed]             │
│   🐢 [Slow mode]                │
│                                  │
│        [Try Again]               │
└──────────────────────────────────┘
```

---

## 4. TRANSLATION UI

### 4.1 Text Translation Screen
```
┌──────────────────────────────────┐
│ Translation    [🎤] [📷] [⋯]    │
│                                  │
│ ┌─────────────────────────────┐  │
│ │ English                  ↕  │  │
│ │ ─────────────────────       │  │
│ │ Good morning, how are you?  │  │
│ │                             │  │
│ └─────────────────────────────┘  │
│                                  │
│ ┌─────────────────────────────┐  │
│ │ German                      │  │
│ │ ─────────────────────       │  │
│ │ Guten Morgen, wie geht es   │  │
│ │ Ihnen?                      │  │
│ │                             │  │
│ │ [🔊] [📋 Copy] [⭐ Save]    │  │
│ │                             │  │
│ │ ┌─────────────────────────┐ │  │
│ │ │ 🎤 Practice This Phrase │ │  │ ← Bridge CTA
│ │ └─────────────────────────┘ │  │
│ └─────────────────────────────┘  │
│                                  │
│ RECENT TRANSLATIONS              │
│ "Danke schön" · German           │
│ "Bonjour" · French               │
└──────────────────────────────────┘
```

**Result card:** Glassmorphism, appears with slide-up animation (200ms)
**Practice CTA:** Always visible below translation result, gradient border

### 4.2 Voice Translation Screen
```
┌──────────────────────────────────┐
│ ← Voice Translation              │
│                                  │
│ English → German          [🔄]   │
│                                  │
│                                  │
│   ┌───────────────────────────┐  │
│   │                           │  │
│   │   "Good morning, how      │  │
│   │    are you?"              │  │ ← STT result (animates in)
│   │                           │  │
│   └───────────────────────────┘  │
│                                  │
│   ┌───────────────────────────┐  │
│   │                           │  │
│   │   Guten Morgen, wie       │  │
│   │   geht es Ihnen?          │  │ ← Translation (glass card)
│   │                           │  │
│   │   [🔊] [📋] [Practice]    │  │
│   └───────────────────────────┘  │
│                                  │
│                                  │
│       [       🎤        ]        │ ← Large mic "Speak to translate"
│                                  │
└──────────────────────────────────┘
```

---

## 5. NAVIGATION STRUCTURE

### Tab Bar (Persistent)
```
[ 📚 Learn ] [ 🎤 Speak ] [ 🌐 Tools ] [ 👤 Profile ]
```

### Push Navigation Flows
```
Learn Tab
  └── Today's Lesson → [Lesson Screen]
       └── Lesson Complete → [Celebration Screen]
            └── [Back to Learn tab]
  └── Browse Lessons → [Lesson List]
       └── Tap Lesson → [Lesson Screen]

Speak Tab
  └── Quick Practice → [Lesson Screen (drill mode)]
  └── Conversation Mode → [Conversation Screen] (Premium gate)

Tools Tab
  └── Text Translation → [Translation Screen] (inline, same tab)
  └── Voice Translation → [Voice Translation Screen]
  └── Image Translation → [Camera → OCR Screen]
  └── Face-to-Face → [Conversation Translation Screen]
  └── Phrasebook → [Phrasebook Screen]
       └── Pack → [Pack Detail Screen]
            └── Phrase → [Practice Mini Lesson]

Profile Tab
  └── Settings → [Settings Screen]
  └── Progress → [Progress Detail Screen]
  └── Achievements → [Achievements Screen]
  └── Subscription → [Paywall / Manage]
```

### Modal Overlays (Stack on top, not tab navigation)
- Paywall → modal full-screen from any point
- Achievement unlock → modal celebration overlay
- Streak at risk → bottom sheet notification
- Practice bridge CTA → bottom sheet from Tools

---

*End of PRD 3: UI/UX Specification*
