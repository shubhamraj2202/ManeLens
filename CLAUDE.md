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
| Build Number | 1 |
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

| Pack | Credits | India ₹ | Japan ¥ | US $ |
|------|---------|---------|---------|------|
| Starter | 10 | 199 | 299 | 2.99 |
| Standard ⭐ | 30 | 499 | 799 | 7.99 |
| Pro | 100 | 1,499 | 2,399 | 19.99 |

Plus 3 free credits on first install. Margin math: Standard pack @ $7.99 → ~$6.79 net (15% small biz) → ~$1.20 API cost → ~$5.60 profit/pack.

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

**Last Updated:** 2026-05-18
**Current State:** SESSION 0 PASS — prompt v1 validated 100% across all 3 criteria (50/50 images). Docs updated to reflect `aurax-api` backend rename.
**What's Working:**
- All 9 screens: Onboarding (3 animated slides), Home (style grid + search + category chips + FAB), Style Detail (hero image + photo upload + collapsible tips + CTA), Custom Prompt (text area + FlowLayout suggestion chips), Generating (orbiting particle animation + rotating tips + progress bar), Result (draggable before/after slider + action bar + feedback), Paywall (3 credit packs + BEST VALUE badge), History (card grid + empty state), Settings (grouped iOS list + toggles + segmented picker)
- Design system: `DesignSystem.swift` with brand tokens (purple #7C3AED, pink #EC4899), `PrimaryButton`, `CreditPill`, `CategoryChip`, `ScreenNav`
- Shared components: `HairFaceView`, `StyleCardView`, `PhotoUploadZone`, `PhotoPickerSheet`, `BeforeAfterSlider`
- `@Observable AppState` wiring credits, photo state, history, selected style
- `HairStyle` catalog (6 styles), enum-based navigation state machine
- Session 0: 50/50 API calls · Identity 100% · Realism 100% · Background 100% · prompt v1 LOCKED
- Auth: `x-goog-api-key` header · Parsing: `inlineData` (camelCase) + `inline_data` (snake_case)
- Docs: All references to `mane-worker`/`hairlens-worker` updated to `aurax-api` across README, CLAUDE.md, AGENT.md, SESSION_00_VALIDATION.md
- App icon: SVG converted to 1024×1024 PNG, set in `AppIcon.appiconset`
- GitHub remote: connected to `github.com/shubhamraj2202/ManeLens`

**Known Issues:** None blocking. SourceKit cross-file errors resolve at Xcode build time (normal).
**Next Step:** Session 5 — Cloudflare Worker scaffold (`src/index.ts`, `src/prompts.ts`, `src/gemini.ts`, `wrangler.toml`). Rate limiting + Gemini call only; StoreKit receipt validation deferred to Session 6.

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

### Other (lower priority)
- Real-time AR live preview (ARKit + on-device hair segmentation)
- Multi-face support
- Hair color picker UI (separate from style)
- Salon B2B mode — consultation tool for stylists, web companion
- Localized App Store listings: Hindi, Japanese, English
