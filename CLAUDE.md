# Hair Lens - AI — Claude Code Project Instructions

## Read This First — Every Session

You are building **Hair Lens - AI** — a native iOS app that previews hairstyles on a user's photo using Google's **Gemini 2.5 Flash Image (Nano Banana)**. The user uploads a selfie, picks a curated style template or writes a custom prompt, and gets a photorealistic edit where **only the hair changes** — facial identity is preserved.

**Competitive moat:**
1. **Decision-grade identity preservation** (most competitors look like wigs/filters)
2. **Style catalog weighted to Indian wedding + Japanese salon looks** — two underserved iOS markets

**Before doing ANYTHING:**
1. Read this file completely
2. Read `AGENT.md` for the 12 non-negotiable rules
3. Read the file you are about to edit
4. Understand existing architecture before changing it

**After completing ANY task:**
1. Update Session Status below — date, state, what's working, known issues
2. `git commit` and `git push`
3. State what was built, files changed, next step

---

## Project Identity

| Field | Value |
|-------|-------|
| App Name | Hair Lens - AI |
| Bundle ID | `com.aurax.ai.shubh.mane` |
| Min iOS | 18.0 |
| Marketing Version | 1.0 |
| Build Number | 3 (Xcode Cloud manages the real build number automatically) |
| Dev Team | 48BYR3J82W |
| Devices | iPhone + iPad |
| Worker Repo | `aurax-api` (sibling repo) |
| Model | Gemini 2.5 Flash Image (Nano Banana) |
| Pricing assumption | $0.039/image, $0.0195/image batch tier |

---

## Architecture Overview

Single iOS target + remote Cloudflare Worker proxy. **No extensions, no app groups, no IPC.** Far simpler than OverlayLens — keep it that way.

```
┌────────────────────────────────────────────────────────────┐
│                  Main App (Hair Lens - AI iOS)                 │
│  MainTabView → Style / History / Settings                   │
│                                                             │
│  StylePickerView → InputView → GeneratingView → ResultView  │
│                                                             │
│  FaceValidator   (Vision — face count, area, pose)          │
│  ImageProcessor  (1024px long edge, JPEG q=0.8)             │
│  APIClient       (POST to Cloudflare Worker)                │
│  CreditManager   (@Observable, StoreKit 2)                  │
│  HistoryStore    (SwiftData @Model)                         │
└──────────────────────┬─────────────────────────────────────┘
                       │ HTTPS POST (JPEG base64 + style/prompt)
┌──────────────────────▼─────────────────────────────────────┐
│             Cloudflare Worker (proxy + gate)                │
│  - Rate limit per device (KV)                               │
│  - Credit deduction (StoreKit receipt validation)           │
│  - Build prompt from style template + user description      │
│  - Call Gemini API                                          │
│  - Refund credit on failure                                 │
└──────────────────────┬─────────────────────────────────────┘
                       ▼
              Google Gemini 2.5 Flash Image API
```

### Generation Pipeline

```
User picks photo → FaceValidator.validate()
  → Fail: actionable error (no face / blurry / multi-face / extreme angle)
  → Pass: ImageProcessor.prepare() — resize, compress
  → User picks style template OR writes prompt
  → APIClient.generate(image, styleId, customPrompt?)
  → Worker: rate limit → credit gate → buildHairPrompt → Nano Banana → return image
  → HistoryStore.save(Generation)
  → ResultView shows before/after slider
```

---

## Targets

### 1. Hair Lens - AI (single iOS target)

| Folder | Files | Purpose |
|--------|-------|---------|
| App/ | HairLensApp.swift, AppState.swift | Entry, global state |
| Models/ | Generation.swift, HairStyle.swift, StyleCatalog.swift | SwiftData + bundled catalog |
| Services/ | APIClient.swift, FaceValidator.swift, ImageProcessor.swift, CreditManager.swift | Core logic |
| Views/Home/ | StylePickerView.swift, StyleCardView.swift | Catalog browse |
| Views/Input/ | InputView.swift, CustomPromptView.swift | Photo + prompt setup |
| Views/Result/ | GeneratingView.swift, ResultView.swift, BeforeAfterSlider.swift | Output |
| Views/History/ | HistoryView.swift, GenerationDetailView.swift | Past generations |
| Views/Paywall/ | PaywallView.swift, CreditPackCard.swift | Credit purchase |
| Views/Settings/ | SettingsView.swift | Restore, terms, privacy |
| Resources/ | StyleCatalog.json | Bundled 30-entry catalog |

### 2. aurax-api (Cloudflare Worker repo — github.com/shubhamraj2202/aurax-api)

- `src/index.ts` — router only (POST /hair/generate, /veggie/analyze, /chat)
- `src/middleware/cors.ts` — CORS headers shared across all routes
- `src/middleware/ratelimit.ts` — per-device KV rate limiting shared across all routes
- `src/providers/gemini.ts` — Nano Banana client
- `src/providers/openrouter.ts` — OpenRouter client stub (multi-model, future)
- `src/routes/hair/` — Hair Lens generate handler + buildHairPrompt() + STYLE_LIBRARY
- `src/routes/veggie/` — VeggieLens stub (501)
- `src/routes/chat/` — Chat stub (501)
- `src/types.ts` — shared Env, ApiError, GenerateResponse interfaces
- `wrangler.toml` — KV namespace + secrets bindings (`GEMINI_API_KEY`, `APPLE_SHARED_SECRET`)

---

## Key Services

### APIClient
- Single endpoint: `POST https://aurax-api.<account>.workers.dev/hair/generate`
- Body: `{ deviceId, receipt, imageBase64, styleId?, customPrompt? }`
- Response: `{ image: base64, mimeType, creditsRemaining }` or `{ error: code, message }`
- Timeout: 30s (Nano Banana typically 6–12s)
- Retries: 0 (cost discipline — let the user retry manually)

### FaceValidator
- `VNDetectFaceRectanglesRequest` + `VNDetectFaceLandmarksRequest`
- Rules: exactly 1 face, face area ≥ 8% of image, eyes detected, yaw/pitch ≤ 25°
- Returns `.valid` or `.invalid(reason: String)` with user-facing copy

### ImageProcessor
- Resize to 1024px long edge (Core Graphics)
- JPEG compress at 0.8 quality
- Return base64 string

### CreditManager (`@Observable`)
- StoreKit 2 product IDs: `credits_10`, `credits_30`, `credits_100`
- First-install free credits: 3
- Server (Worker) is source of truth; app caches last known balance for UI
- Restore via `Transaction.currentEntitlements`

### HistoryStore (SwiftData)
```swift
@Model class Generation {
  var id: UUID
  var createdAt: Date
  var styleId: String?
  var customPrompt: String?
  var originalImage: Data  // JPEG
  var resultImage: Data    // JPEG
}
```

### buildHairPrompt() — Worker side, **the moat**

```ts
function buildHairPrompt(styleId?: string, custom?: string): string {
  const styleDesc = styleId ? STYLE_LIBRARY[styleId] : custom!;
  return `Transform ONLY the hair in this photograph to: ${styleDesc}

STRICT PRESERVATION REQUIREMENTS:
- Keep the person's face, facial features, skin tone, age, gender, and identity EXACTLY identical
- Do not alter eyes, nose, mouth, jawline, facial hair, or expression in any way
- Keep the background, clothing, lighting direction, color temperature, and camera angle unchanged
- Match the new hairstyle's shadows, highlights, and shine to the original photo's lighting
- Render a natural, realistic hairline where hair meets forehead, ears, and neck
- Preserve the original photo's resolution, grain, and photographic style

The output must look like a real unedited photograph of this exact person with this hairstyle — not an AI generation, not a filter, not a wig overlay.`;
}
```

**Do not modify this without rerunning the Session 0 validation test.**

---

## Project-Specific Rules (extends the 12 in AGENT.md)

13. **Never log or persist API keys** — Worker owns all credentials.
14. **Always validate face before API call** — every prevented bad request saves $0.04.
15. **Cache generations locally** — never re-call API for the same (image, prompt) pair within a session.
16. **Refund credits on API failure** — Worker refunds; app trusts server balance after each call.
17. **No on-device hair generation** — Vision/CoreML quality won't compete. Validation only.
18. **Style catalog is bundled JSON, not server-fetched** — V1 ships frozen. Updates ship via App Store.
19. **The prompt template is the moat** — `buildHairPrompt()` cannot change without re-running Session 0 regression on the canonical 10-selfie set.
20. **Compress before upload** — 1024px JPEG q=0.8. Never send raw camera output (saves bandwidth + latency + cost).
21. **Do not manually increment build numbers.** Xcode Cloud manages build numbers dynamically during archiving. Your local codebase will purposefully remain at a static, low number (e.g., 3) while TestFlight shows the true incremented number (e.g., 33). This is Apple's recommended best practice to keep your Git history clean of "bump build" commits.

---

## Design System

### Theme
- Light/white background (`systemGroupedBackground`)
- Accent: system pink/coral (differentiates from OverlayLens blue)
- Cards: white, 16pt corner, subtle shadow (`black 0.04, radius 8, y: 2`)

### Style Grid
- 2-column grid of style cards
- Card: thumbnail (sample model render) + style name + category tag (`Wedding` / `Salon` / `Casual` / `Bold`)
- Tap → InputView with style pre-selected

### Result View
- Horizontal before/after slider (drag divider)
- Bottom action row: `[Share] [Save] [Regenerate] [Copy Prompt]`
- "Regenerate" deducts another credit

### Paywall
- Triggered when credits hit 0 mid-session
- 3 packs as cards; "Best Value" tag on Standard (30 credits)
- "Restore Purchase" link at bottom

### Generating State
- Centered animated illustration (SF Symbol `wand.and.stars` with pulse)
- Subcopy: "Styling your hair… ~10 seconds"
- No progress bar (API has no progress signal)

---

## Pricing (V1)

| Pack | Product ID | Credits | India ₹ | Japan ¥ | US $ | Cost/use |
|------|-----------|---------|---------|---------|------|----------|
| Try It | credits_5 | 5 | 99 | 150 | 0.99 | $0.20 |
| Starter | credits_20 | 20 | 299 | 300 | 1.99 | $0.10 |
| Standard ⭐ | credits_60 | 60 | 499 | 750 | 4.99 | $0.08 |
| Pro | credits_200 | 200 | 999 | 1,500 | 9.99 | $0.05 |

Plus 3 free credits on first install. Pricing rationale: one bad haircut costs ₹1000 and takes 3 months to grow out — 20 previews at ₹299 is a bargain. Entry at ₹99/$0.99 removes "is it worth it?" friction. Margin math: Standard @ $4.99 → ~$4.24 net → ~$2.34 Gemini cost (60 × $0.039) → ~$1.90 profit/pack. Pro @ $9.99 → ~$8.49 net → ~$7.80 Gemini cost → ~$0.69 profit (volume play).

---

## Known Issues & Decisions

### Resolved (pre-V1)
- _None yet — fresh project_

### Active / Watch Out For
- Nano Banana **fails ~10% on faces with sunglasses, hats, or heavy occlusion** — FaceValidator should reject these
- Gemini can return **safety blocks** on some prompts — Worker must surface a specific error code so the app shows "Style not supported, try another"
- StoreKit 2 receipt validation needs the **shared secret** from App Store Connect, separate from the Gemini API key
- Apple commission affects pricing — model assumes 15% (small business program)

---

## Session Status

**Last Updated:** 2026-05-27
**Current State:** SESSION 16 IN PROGRESS — Worker `/hair/analyse` endpoint complete and committed (not pushed). Profiles + Hair Timeline feature fully designed with implementation prompt written. Face Analyser partial iOS (model + APIClient + FaceAnalysisView created, not yet wired into ContentView/HomeView — paused for design pivot).

**What's Working:**
- Full generate pipeline working end-to-end on real device
- All 4 IAPs (credits_5/20/60/200) loading correctly on real device from App Store Connect sandbox — DO NOT set StoreKit config in Xcode scheme (iOS 26 simulator bug causes 0 products)
- StoreKit purchase flow works on device with sandbox account
- PaywallView: all 4 packs showing, safeAreaInset bottom CTA, no empty gap
- ResultView: before/after slider 4/5 portrait ratio, ✂️ emoji, Save→exportToPhotos, Love it→AppStore review, share removed from nav
- SettingsView: Appearance section with System/Light/Dark segmented theme picker; Privacy/Terms → GitHub Pages URLs
- CustomPromptView: header padding fixed (56pt top)
- StyleDetailView: navBar in VStack flow (face fully visible in hero, 4:3 ratio), swipeable carousel, fullscreen tap, photo preview
- StyleCardView: category chip exactly top-left, NEW badge exactly top-right (frame maxWidth/maxHeight fix)
- Theme: ThemeMode enum in AppState (persisted UserDefaults), `.preferredColorScheme()` on root; all design system colors now UIColor adaptive (systemBackground, label, separator, etc.)
- HomeView: Male/Female filter chips alongside category chips
- HistoryView: Edit mode with multi-select, "Delete (N)" + "Clear All" toolbar buttons
- HairStyle catalog: 20 styles (6 original + 14 new) with gender field — Male/Female/Unisex
- **Sample Images Integration:** 39 out of 40 high-quality, photorealistic sample images fully integrated into Assets.xcassets and HairStyle.swift:
  - 8 male styles (16 images): `indian_groom_slick`, `french_crop_fade`, `classic_pompadour`, `man_bun`, `disconnected_undercut`, `buzz_cut`, `textured_quiff`, `ivy_league` — ALL 2/2 completed
  - 11 female/unisex styles (23 images): `wolf_cut`, `indian_wedding_updo`, `beach_blonde_waves`, `balayage_highlights`, `curtain_bangs`, `pixie_cut`, `classic_bob`, `braided_bridal_updo`, `long_straight`, `side_swept_bangs`, `platinum_blonde` — ALL 2/2 completed, `reception_waves` has 1/2 completed (waiting on quota reset for sample_reception_waves_2)
- **Legal Pages:** Completed and pushed to `shubhamraj2202.github.io` (`hairLens-privacy.html`, `hairLens-terms.html`, `hairLens-support.html`)

**iOS 26 SDK / StoreKit notes:**
- Local .storekit config file returns 0 products on iOS 26 simulator — known bug. Use real device + App Store Connect sandbox for IAP testing
- All iOS 26 SDK breaking changes already fixed (see commit history)
- SourceKit cross-file errors are always false alarms with PBXFileSystemSynchronizedRootGroup
- All IAPs created in App Store Connect (credits_5 / credits_20 / credits_60 / credits_200)

**PENDING BEFORE SUBMISSION — Session 12:**

CODE FIXES (new bugs found in Session 11 device testing):
1. **StyleDetailView hero face cut off** — hero uses `.ignoresSafeArea(edges: .top)` + opaque white nav bar overlay; nav bar covers ~110pt of the 16:9 hero so only the person's collar/chest shows. Fix: remove `.ignoresSafeArea(edges: .top)`, place nav bar in normal VStack flow, let hero start below nav bar. File: `StyleDetailView.swift`
2. **HomeView style card label alignment** — category chip must be exactly at TOP-LEFT corner, NEW badge exactly at TOP-RIGHT corner. Currently NEW badge drifts toward center-left when no category is long enough to push the Spacer. Fix: ensure HStack Spacer correctly separates the two; use `.frame(maxWidth: .infinity, alignment: .leading)` on category side. File: `StyleCardView.swift`

CONTENT (once Gemini images are ready):
3. Add remaining 23 sample PNGs (female styles) to Assets.xcassets imagesets + populate sampleImages arrays in HairStyle.swift — see prompt in session notes
4. Create `hairLens-privacy.html` on https://github.com/shubhamraj2202/shubhamraj2202.github.io
5. Create `hairLens-terms.html`
6. Complete IAP metadata in App Store Connect (price + localization + screenshot per product)
7. App Store screenshots — 1320×2868 (6.9") and 1179×2556 (6.3")
8. Archive → Upload → TestFlight → add shubhamraj2202@gmail.com as internal tester

**StyleDetailView hero fix — root cause:**
```swift
// Current (broken): ScrollView ignores safe area, nav bar overlay is opaque white
ScrollView { VStack { heroArea ... } }
    .ignoresSafeArea(edges: .top)
.overlay(alignment: .top) { navBar.background(Color.hairBg) }

// Fix: normal VStack layout, nav bar first, hero below
VStack(spacing: 0) {
    navBar  // positioned naturally, no overlay
    ScrollView { VStack { heroArea ... } }
}
// heroArea aspect ratio: change 16/9 → 4/3 to show more of the face
```

**StyleCardView label fix — desired UX:**
- Category chip ("Wedding", "Salon"): exactly at TOP-LEFT corner, tight to edge
- NEW badge: exactly at TOP-RIGHT corner, tight to edge
- Style name: stays at bottom-left as before
- Both badges in the same HStack row with a Spacer between them

**Legal URLs (already wired in SettingsView.swift, just need HTML pages):**
- Privacy: https://shubhamraj2202.github.io/hairLens-privacy.html
- Terms: https://shubhamraj2202.github.io/hairLens-terms.html

**Complete Bug List from Sessions 8–11:**
| # | View | Bug | Status |
|---|------|-----|--------|
| 1 | ResultView | "scissors" renders as text | FIXED ✅ |
| 2 | ResultView | Share button duplicated | FIXED ✅ |
| 3 | ResultView | Slider crops face | FIXED ✅ |
| 4 | ResultView | Save button did nothing | FIXED ✅ |
| 5 | ResultView | "Love it" did nothing | FIXED ✅ |
| 6 | StyleDetailView | Nav bar dark over hero | FIXED ✅ |
| 7 | CustomPromptView | Header hidden | FIXED ✅ |
| 8 | PaywallView | Empty gap below cards | FIXED ✅ |
| 9 | SettingsView | Non-functional toggles | FIXED ✅ |
| 10 | SettingsView | Danger Zone confusing | FIXED ✅ |
| 11 | HomeView | Grid not scrollable | FIXED ✅ |
| 12 | HomeView | No Male/Female filter | FIXED ✅ |
| 13 | HistoryView | No delete/clear all | FIXED ✅ |
| 14 | StyleDetailView | Tap photo re-opens picker | FIXED ✅ |
| 15 | StyleCards | No real sample photos | PARTIAL ✅ (9 male styles done, 11 female pending images) |
| 16 | StyleDetailView | Hero face cut off by nav bar | FIXED ✅ |
| 17 | StyleCardView | Badge alignment (category top-left, NEW top-right) | FIXED ✅ |

**Session 13 additions (all committed, all building):**
- Hero image + photo box unified to 240pt height — visually consistent
- StyleDetailView nav: ellipsis removed for custom styles; all styles show plain heart
- Home grid long-press context menu: Favorite (all), Edit + Delete (custom only)
- Card height 165 → 190pt so style name always visible
- Edit custom style: CustomPromptView editingStyle param, AppState.updateCustomStyle, Screen.editCustomStyle — long-press Edit pre-fills name/prompt/images
- Onboarding Continue button fix: .white variant used Color.hairText (white in dark mode) → hardcoded dark purple
- Removed "Continue without account" from onboarding slide 3
- iCloud KV: ManeLens.entitlements + CODE_SIGN_ENTITLEMENTS wired in pbxproj
- iCloud KV credit persistence: survives reinstall (NSUbiquitousKeyValueStore + UserDefaults belt-and-suspenders)
- iCloud KV for favorites, custom styles metadata, history metadata — all sync to iCloud
- Crash fix: index out of range in sample image remove (stale ForEach offset guard)
- Logo: replaced 💇 emoji with wand.and.stars SF Symbol (white + glow on gradient)

**iCloud KV note:** Entitlements file created + pbxproj wired. User must also check "Key-value storage" under iCloud in Xcode → Signing & Capabilities to activate provisioning profile sync.

**Session 15 changes (committed):**
- PaywallView dark mode: unselected card bg `Color.hairBg` → `Color.hairBgOff`, bottom gradient `.white` → `Color.hairBg`
- Home category persistence: `homeSelectedCategory` + `homeSearchText` moved from `HomeView @State` → `AppState`
- `IMAGE_PROMPTS.md` created: all 60 multi-angle prompts with Antigravity instructions

**Session 16 changes (committed, NOT pushed):**
- Worker `POST /hair/analyse` endpoint: `callGeminiAnalyse()` in gemini.ts uses gemini-2.0-flash (text-only, cheap ~$0.0001) with vision input → returns JSON `{faceShape, undertone, eyeColour, hairColour, recommendations[5]}`. `src/routes/hair/analyse.ts` created. Wired in `index.ts`. Same rate-limit + credit gate as generate. Committed in aurax-api repo (f5facc1).
- Partial Face Analyser iOS (NOT wired into app yet — paused for design pivot):
  - `Models/FaceAnalysis.swift` — FaceAnalysisResult + StyleRecommendation Decodable structs
  - `Services/APIClient.swift` — `analyse(photo:)` method + `analyseURL` constant added
  - `AppState.swift` — `faceAnalysisError: String?` added
  - `Views/FaceAnalysisView.swift` — entry screen with photo picker + CTA (not in Screen enum yet)
- Profiles + Hair Timeline feature: fully designed, implementation prompt written and ready to paste into a new Claude Code session
- Claude Design export (`Hair Lens - AI.html`) fetched and read — 9 existing screens match current implementation

**PENDING BEFORE SUBMISSION:**
1. IAP metadata in App Store Connect (price + localization + screenshot for credits_5/20/60/200)
2. App Store screenshots — 1320×2868 (6.9") and 1179×2556 (6.3")
3. Archive → Upload → TestFlight → add shubhamraj2202@gmail.com as internal tester
4. Wire _3/_4/_5 images into `HairStyle.swift` once Antigravity generates them

**V2 — Profiles + Hair Timeline (implementation prompt ready, start fresh session):**
- Full spec: PersonProfile model, TimelineEntry, ProfilesStore, 6 new views, ContentView wiring, generation flow integration, Face Analyser wired into profiles
- Worker: `/hair/analyse` already done and deployed-ready
- iOS Face Analyser partial files already created (see Session 16 changes above) — next session should complete wiring into ContentView + HomeView

**Next Step:** Session 17 — paste Profiles+Timeline implementation prompt into fresh Claude Code session. Then IAP metadata + screenshots + TestFlight.

**IMPORTANT — Session 17 start ritual:**
User will provide a Claude Design export URL (like `https://api.anthropic.com/v1/design/h/...`).
Fetch it using WebFetch, decompress (it's a .tar.gz), extract, read README.md + chats/ + project files BEFORE implementing anything. The design files are the source of truth for all new screen layouts, colors, and interactions. Implement pixel-perfectly in SwiftUI matching the HTML/CSS prototype.


---

## Future Features (V2+)

### Reference Photo Style Matching
Upload an inspiration photo (e.g. a celebrity or magazine cut) and the app extracts the style and applies it to the user's selfie.
- **UX:** Second optional photo upload zone on Style Detail + Custom Prompt screens, labelled "Add reference photo"
- **Worker:** When `referenceImageBase64` is present, `buildHairPrompt()` switches to a two-image prompt: image 1 = user selfie, image 2 = reference, instruction = "copy the exact hairstyle from image 2 onto the person in image 1"
- **Gemini:** Nano Banana supports multi-image input — pass both inline_data parts in the same `contents` array
- **Pricing:** Same credit cost (1 credit) — single Gemini call regardless of input count
- **Constraint:** Validate reference photo has detectable hair via Vision before sending (prevents wasted API calls)
- **File changes when implemented:** `CustomPromptView.swift`, `StyleDetailView.swift`, `PhotoUploadZone.swift` (add `referencePhoto` mode), `APIClient.swift` (add `referenceImageBase64` param), `prompts.ts` on Worker

### Beard Styling
Apply barber-grade beard style transformations independently of (or alongside) hair changes.
- **UX:** New "Beard" category chip on Home screen; style cards show beard preview renders; beard toggle on Style Detail ("Style beard too?")
- **Prompt variant:** Separate `buildBeardPrompt()` on Worker — identical preservation rules but targets facial hair region only. When both hair + beard are requested, a combined prompt targets both regions in one call
- **Catalog additions:** 5 initial beard styles — Clean Shave, Short Box Beard, Full Beard, Goatee, Designer Stubble
- **FaceValidator:** Add `VNDetectFaceLandmarksRequest` check for lower-face landmark coverage (chin, jaw) before beard calls
- **Constraint:** `buildBeardPrompt()` must go through same Session 0–style regression before shipping (5 beard styles × 10 selfies with beards/stubble)
- **File changes when implemented:** `HairStyle.swift` (add `StyleType: hair | beard | both`), `StyleCatalog.swift`, `prompts.ts` (add `buildBeardPrompt()`), `StyleDetailView.swift` (beard toggle), `FaceValidator.swift`

### AI Face Analyser (V2 — HIGH PRIORITY)
Analyse the user's selfie using Gemini vision to detect face shape, skin undertone, eye colour, and current hair colour — then recommend the 5 best styles from the catalog for their specific features.

- **UX flow:** New "Analyse My Face" button on HomeView header (wand icon) → user uploads/takes selfie → animated "Analysing…" screen with step-by-step progress bars (scanning eye & skin tones → detecting hair colour type → analysing undertone → identifying best styles) → results screen showing top 5 recommended styles with explanation cards ("Your oval face suits…")
- **Analysing screen:** Progress bars per step (like competitor HairApp), face preview in oval crop at top, each step animates in sequence
- **Results screen:** Ranked style cards with a % match badge, short personalised reason per style ("Your warm undertone pairs perfectly with balayage"), tap → goes straight to StyleDetailView
- **Worker:** New endpoint `POST /hair/analyse` — sends selfie base64, Gemini returns JSON: `{ faceShape, undertone, eyeColour, hairColour, recommendedStyleKeys[] }`
- **Gemini prompt:** "Analyse this portrait. Return JSON with: faceShape (oval/round/square/heart/oblong), skinUndertone (warm/cool/neutral), eyeColour, currentHairColour, top5StyleKeys from this list: [catalog keys]. Explain each recommendation in one sentence."
- **On-device:** Use Vision `VNDetectFaceRectanglesRequest` to confirm face present before sending — same validation as generate flow
- **Credit cost:** 1 credit per analysis (same as generation — one Gemini call)
- **New files:** `FaceAnalysisView.swift`, `AnalysingView.swift`, `FaceAnalysisResultView.swift`, `src/routes/hair/analyse.ts` on Worker
- **New Screen cases:** `Screen.faceAnalysis`, `Screen.analysingFace`, `Screen.faceAnalysisResult(FaceAnalysisResult)`

### Reference Photo Style Matching
Upload an inspiration photo (e.g. a celebrity or magazine cut) and the app extracts the style and applies it to the user's selfie.
- **UX:** Second optional photo upload zone on Style Detail + Custom Prompt screens, labelled "Add reference photo"
- **Worker:** When `referenceImageBase64` is present, `buildHairPrompt()` switches to a two-image prompt
- **File changes when implemented:** `CustomPromptView.swift`, `StyleDetailView.swift`, `PhotoUploadZone.swift`, `APIClient.swift`, `prompts.ts`

### Beard Styling
Apply barber-grade beard style transformations independently of (or alongside) hair changes.
- **Catalog additions:** 5 initial beard styles — Clean Shave, Short Box Beard, Full Beard, Goatee, Designer Stubble
- **File changes when implemented:** `HairStyle.swift`, `StyleCatalog.swift`, `prompts.ts`, `StyleDetailView.swift`, `FaceValidator.swift`

### Other (lower priority)
- Real-time AR live preview (ARKit + on-device hair segmentation)
- Multi-face support
- Hair color picker UI (separate from style)
- Salon B2B mode — consultation tool for stylists, web companion
- Localized App Store listings: Hindi, Japanese, English
