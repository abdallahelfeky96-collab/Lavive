# Vegesea — Banners, Offers & Product Shop (Flutter)

Flutter app for **Lavive / Vegesea** — a banners/offers + product catalogue app with an
in-app Cart, promo codes, and full deep-link routing on **Android (App Links)** and
**iOS (Universal Links)**.

## Table of contents

- [Tech stack](#tech-stack)
- [Getting started](#getting-started)
- [Run the app](#run-the-app)
- [Deep links](#deep-links)
- [Build a release (Play Store / App Store)](#build-a-release-play-store--app-store)
- [Play Console upload (version 1.0.18 / mapping.txt)](#play-console-upload-version-1018--mappingtxt)
- [Project layout](#project-layout)
- [Troubleshooting](#troubleshooting)
- [Release history](#release-history)

---

## Tech stack

- **Flutter 3.44** (stable) · Dart 3
- State management: `flutter_bloc` + `short_navigation` (go_router-style `Go.to`)
- Networking: `http` + `json_serializable` models
- `app_links` for App Links / Universal Links + persistent promo code via `shared_preferences`
- Android: **R8 (minify/shrink enabled in release)** + Play App Signing (upload key `vegesea.jks`)
- Firebase: Remote Config, Messaging, Analytics; Pusher; Localization (`flutter_localization`)

---

## Getting started

```bash
# 1. Clone
git clone <repo-url> vegesea
cd vegesea

# 2. Get dependencies
flutter pub get

# 3. (Android release builds only) create android/key.properties +
#    drop android/app/vegesea.jks (release keystore; NOT committed).
```

> **Android release signing** needs `android/key.properties` + `android/app/vegesea.jks`
> (the committed `key.properties` template shows expected keys; the real one is git-ignored).
> Debug builds work out of the box with `signingConfigs.debug`.

---

## Run the app

```bash
flutter pub get
flutter run                 # debug, any connected device/emulator
```

Warm reload:
```bash
flutter run --hot   # press "r"
```

---

## Deep links

| Platform | Mechanism | Configured in |
|---|---|---|
| **Android** | App Links (`assetlinks.json` w/ autoVerify) | `android/app/src/main/AndroidManifest.xml` |
| **iOS** | Universal Links (AASA + Associated Domains) | `ios/Runner/Runner.entitlements`, `Info.plist` |

Hosts: `lavive.chottu.link` (`lavive://` legacy) + `go.lavive.app`, `offer.lavive.app`,
`shop.lavive.app`, `box.lavive.app`.

### Routing map

| URL | Goes to |
|---|---|
| `https://…/b/{id}` or `?banner_id=` | Banners / Offers detail (`SlidingDetails`) |
| `https://…/p/{id}` or `?product_id=` | Product detail (`ProductScreen`) |
| `https://…/c/{id}` or `?category_id=` | Category grid (`SubCategoriesGrid`) |
| `https://…/cart` or `?promo=` in path | Cart tab (+ promo applied when first product added) |
| legacy `lavive://product/…` etc. | Same targets via custom scheme |
| anything else / root domain | Home tab (fallback) |

Cold start (`getInitialLink`) **and** warm start (`uriLinkStream`) are both handled, with
deduplication (a link delivered by both `app_links` and the attribution SDK opens once).

**Note:** for production, host `assetlinks.json` (Android) and `apple-app-site-association`
(iOS) at the domain root so verification passes — those live on the server, not in the repo.

---

## Build a release (Play Store / App Store)

### Android (Google Play)

```bash
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```

With R8 enabled, the build also emits the **mapping file** you keep safe for
deobfuscating crash reports:

```
build/app/outputs/mapping/release/mapping.txt
```

R8 is configured to **keep the Flutter engine + plugins + JSON model entry points** so
obfuscation is safe to be on (see `android/app/proguard-rules.pro`), while still producing
a real `mapping.txt` + line numbers.

### iOS (App Store) — requires macOS

```bash
flutter build ios --release
flutter build ipa   # archive/uploadable .ipa
```

> iOS builds **cannot** run on Windows — use a Mac. Both the Dart router and the
> platform config (entitlements/associated domains) are in the repo; the Xcode
> build itself is macOS-only.

---

## Play Console upload (version 1.0.18 / mapping.txt)

Current release: **`1.0.18+18`** (versionCode 18, SHA1 upload key `58:C7:16:88:1B:E3:F5:C0:E2:4F:BF:19:C1:98:A9:D6:7D:91:4A:DA`).

Manual steps:

1. **Upload the AAB** — `flutter build appbundle --release`, go to
   **Play Console → Release → Production → Create new release → Upload**,
   pick `build/app/outputs/bundle/release/app-release.aab`.
2. **Attach the mapping file** — Play shows *"no mapping file / deobfuscation file"*
   if you skip this. Upload `build/app/outputs/mapping/release/mapping.txt`
   (App Bundle Explorer → Deobfuscation) so crash reports deobfuscate with
   line numbers on Play.
3. Add release notes, then **Start rollout to Production** (or Internal testing first).

### If you get "Upload key signature mismatch"

```
Expected fingerprint SHA1: 58:C7:…
Received: E8:7D:… (debug keystore)
```

That means the AAB was signed with Flutter's **debug** keystore (the `key.properties`
pointed at a missing `storeFile`, so Gradle fell back to `signingConfigs.debug`).
Fix: make `android/key.properties` point at your real `vegesea.jks` in
`android/app/`, clean, and rebuild:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Then re-upload. Your app keeps its same upload key (Play's registered fingerprint
`58:C7:…`), so no console reset needed.

---

## Project layout

```
lib/
├── cubits/            # BLoC cubits (banners, products, cart, …)
├── layout/
│   ├── home/          # root shell, products/home, banner SlidingDetails
│   └── product_screen/
├── models/            # json_serializable data models (banner, product, …)
├── services/          # deep_link_service, get_banners_service, get_one_product_service …
└── shared/            # shared widgets, navigation helpers, constants
android/
└── app/
    ├── build.gradle       # R8 minified release + vegesea.jks signing
    ├── key.properties     # (git-ignored) keystore pointers/passwords
    └── proguard-rules.pro # Flutter keep rules + mapping line numbers
```

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `ERROR: Missing classes … while running R8` | These are **optional** Play-Core / deferred-download refs in the Flutter engine. They're covered in `android/app/proguard-rules.pro` (`-dontwarn com.google.android.play.core.**`); standard behavior — R8 succeeds and emits `mapping.txt`. |
| Store rejects AAB: wrong signing fingerprint | See [signature section](#if-you-get-upload-key-signature-mismatch) above. |
| Deep link opens nothing on a device | Confirm the AAB is signed/uploaded, host `assetlinks.json` / `apple-app-site-association`, and test with `adb shell am start -a android.intent.action.VIEW -d "<url>"`. |

---

## Release history

| Version | Notes |
|---|---|
| **1.0.18+18** | R8 (minify/shrink) enabled → real `mapping.txt` for Play deobfuscation. |
| 1.0.17+17 | Rolled-back release marker (signing fix landed in 1.0.18). |
| 1.0.16+16 | … (prior history) |
