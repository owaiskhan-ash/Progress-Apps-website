# Making the APK a real release build (v1.2.1)

The published APKs were debug builds: CI ran `gradle assembleDebug`, every download was named
`app-debug.apk`, the app was flagged `android:debuggable`, and the signer was the *public*
Android debug key that gets regenerated on each CI runner. This folder holds the fix for
`owaiskhan-ash/Project-Progress-Widget`, ready to apply.

I could not push it: this session's GitHub token has read-only access to that repository
(`git push` and `gh api` writes both return 403). Applying it takes about a minute.

## What's here

| File | Purpose |
| --- | --- |
| `android-release-signing.patch` | Changes to `app/build.gradle`, `.github/workflows/release.yml`, `README.md`, `.gitattributes` |
| `keystore/progress-tracker.p12` | The release signing key (PKCS#12, alias `progress-tracker`, password `ProgressTracker-Release-2026`) |
| `keystore/README.md` | Key details, certificate fingerprint, how to move it to CI secrets later |

## Apply it

```sh
gh repo clone owaiskhan-ash/Project-Progress-Widget
cd Project-Progress-Widget

git checkout main
git apply /path/to/release-signing/android-release-signing.patch
mkdir -p keystore
cp /path/to/release-signing/keystore/* keystore/

git add -A
git commit -m "Sign releases with a real release key and publish v1.2.1"
git push origin main

git tag -a v1.2.1 -m "Project tracker v1.2.1 — signed release APK"
git push origin v1.2.1
```

Pushing `main` runs the build and uploads a signed APK as a workflow artifact; pushing the
`v1.2.1` tag additionally publishes `Progress-tracker-v1.2.1.apk` on a new GitHub release.

## What changes

- `signingConfigs.release` backed by the committed keystore, with every value overridable by
  `RELEASE_STORE_FILE` / `RELEASE_STORE_PASSWORD` / `RELEASE_KEY_ALIAS` /
  `RELEASE_KEY_PASSWORD` so the key can move into repository secrets later without editing code.
- CI builds `assembleRelease`, then fails the job unless `apksigner` confirms a release
  certificate and the APK is *not* debuggable.
- The release asset is `Progress-tracker-v<version>.apk` instead of `app-debug.apk`.
- Version bumped to `versionCode 9` / `versionName '1.2.1'`.

## Two things to know

1. **One-time uninstall for existing installs.** v1.2.0 and earlier are signed with a different
   key, so Android will refuse to install v1.2.1 over them ("App not installed"). Uninstall the
   old build first — that also wipes its local projects and milestones, since data lives in
   app-private storage. From v1.2.1 onward updates install normally.
2. **The key is public.** That was your call, and it is still much better than the debug key
   (which anyone can recreate), but treat it as an identity, not a secret. `keystore/README.md`
   has the commands to move it to repository secrets when you want to. Back the `.p12` up
   somewhere; losing it means requiring an uninstall for every future release.

## After the release exists

The website's download button still points at
`.../releases/download/v1.1.0/app-debug.apk`, and the fineprint says "37 KB · debug-signed".
Once `v1.2.1` is published, update `index.html`:

```html
<a class="button" href="https://github.com/owaiskhan-ash/Project-Progress-Widget/releases/download/v1.2.1/Progress-tracker-v1.2.1.apk">Download the APK …
<p class="fineprint">v1.2.1 &middot; 95 KB &middot; signed release build &middot; Android 6.0+</p>
```

Say the word and I'll make that edit here instead.

## Verification status

- The patch applies cleanly to `main` (5610dc1) — checked against a fresh clone.
- The workflow is valid YAML with the expected steps — checked.
- The keystore was generated locally and round-trips through a PKCS#12 load — checked.
- The Gradle/Android build itself was **not** run here (no JDK, no Android SDK in this sandbox),
  so the first push is the real test. If it fails, the job's `::error::` lines point at the cause.
