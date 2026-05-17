# Hair Lens - AI

iOS app for previewing hairstyles on your photo using AI. Upload a selfie, pick a style from the curated catalog or describe one in your own words, and get a photorealistic preview where **only your hair changes — your face stays exactly the same**.

Built for the underserved iOS markets in India and Japan, with templates weighted toward Indian wedding looks and Japanese salon styles.

## How it works

1. Take or upload a front-facing selfie
2. Pick a style template, write a custom description, or upload a **reference photo** to copy that exact look
3. App generates a preview via Gemini 2.5 Flash Image (Nano Banana)
4. Before/after slider — save, share, regenerate

Identity preservation is the whole product. Most competitors fail at this, leaving outputs that look like filters or wigs. Hair Lens - AI uses a hardened prompt template tuned across an internal regression set to keep faces unchanged.

**Coming in V2:** Beard styling — apply barber-grade beard transformations (clean shave, box beard, goatee, and more) independently or alongside hair changes.

## Tech stack

- **iOS:** Swift, SwiftUI, SwiftData, Vision, StoreKit 2 — iOS 18.0+
- **Backend:** Cloudflare Workers (TypeScript) + KV
- **AI:** Google Gemini 2.5 Flash Image API
- **Zero third-party dependencies** on the client — Apple frameworks only

## Architecture

iOS app → Cloudflare Worker proxy → Gemini API.

The Worker handles rate limiting, StoreKit 2 receipt validation, credit ledger, and prompt assembly. **API keys never touch the device.**

See `CLAUDE.md` for full architecture and service-level detail.

## Pricing

Credit-based, no subscription. 3 free generations on first install.

| Pack | Credits | India ₹ | Japan ¥ | US $ |
|------|---------|---------|---------|------|
| Starter | 10 | 199 | 299 | 2.99 |
| Standard | 30 | 499 | 799 | 7.99 |
| Pro | 100 | 1,499 | 2,399 | 19.99 |

## Build

Requires Xcode 16+, iOS 18 SDK, physical device. Apple Developer team `48BYR3J82W`.

1. Clone this repo and the sibling `mane-worker` repo
2. Open `Mane.xcodeproj`
3. Set the Worker URL in `Services/APIClient.swift`
4. Select your device, build, run

## Project docs

- `CLAUDE.md` — architecture, services, design system, rules (read first)
- `AGENT.md` — Claude Code session protocol + 12 strict rules
- `SESSION_00_VALIDATION.md` — the go/no-go prompt regression gate

## License

Proprietary. © Shubham Raj. All rights reserved.
