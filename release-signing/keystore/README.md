# Release signing keystore

`progress-tracker.p12` is the key every GitHub release APK is signed with. Keep it: Android
only installs an update over an existing app when the signature matches, so losing or
replacing this file means everyone has to uninstall before installing a newer build.

| Setting | Value |
| --- | --- |
| File | `keystore/progress-tracker.p12` (PKCS#12) |
| Alias | `progress-tracker` |
| Store + key password | `ProgressTracker-Release-2026` |
| Key | RSA 4096, valid until 2056 |
| Certificate SHA-256 | `ed7678147bc47773954d20929cf37191311137f29cbb2546d06addc29432af9e` |

The key is committed on purpose: this is a free, sideloaded app and the repository has no
CI secrets. That is stricter than the previous setup — release APKs used to be signed with
the *public Android debug key*, which anyone can recreate — but it does mean the key is not
a secret. If you would rather keep it out of the repo:

```sh
# 1. Add these as repository secrets
gh secret set RELEASE_KEYSTORE_BASE64 < <(base64 -w0 keystore/progress-tracker.p12)
gh secret set RELEASE_STORE_PASSWORD --body 'ProgressTracker-Release-2026'
gh secret set RELEASE_KEY_ALIAS --body 'progress-tracker'
gh secret set RELEASE_KEY_PASSWORD --body 'ProgressTracker-Release-2026'

# 2. In the workflow, before the build:
#    echo "$RELEASE_KEYSTORE_BASE64" | base64 -d > keystore/progress-tracker.p12
```

`app/build.gradle` reads the signing values from `RELEASE_STORE_FILE`,
`RELEASE_STORE_PASSWORD`, `RELEASE_KEY_ALIAS` and `RELEASE_KEY_PASSWORD` when those
environment variables are set, so either route works without editing the build file.

To check an installed or downloaded APK:

```sh
apksigner verify --print-certs Progress-tracker-v1.2.1.apk
```
