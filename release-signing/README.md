# Project tracker v1.2.2 — release + transition fixes

Two things prepared for `owaiskhan-ash/Project-Progress-Widget`, ready to apply:

1. **A real release build.** Published APKs were `assembleDebug` output: signed with the
   *public* Android debug key, flagged `android:debuggable`, named `app-debug.apk`.
2. **Darker, quieter transitions.** The page animation slid 28dp sideways over the default
   *light* window background, so every page change flashed white, and it also replayed on the
   page you were already on — so saving a milestone re-slid the whole screen.

I could not push either change: this session's GitHub token is read-only for that repository
(`git push` and every `gh api` write return 403). Applying takes one command.

## Apply it

```sh
gh repo clone owaiskhan-ash/Project-Progress-Widget
cd Project-Progress-Widget

# review the changes in the working tree first
REPO_DIR=. /path/to/release-signing/apply-release.sh

# commit, push main, and tag v1.2.2 to publish the signed APK
REPO_DIR=. /path/to/release-signing/apply-release.sh --push
```

Pushing `main` builds a signed APK as a workflow artifact; pushing the `v1.2.2` tag publishes
`Progress-tracker-v1.2.2.apk` on a new release.

Build locally instead if you prefer:

```sh
gradle assembleRelease   # app/build/outputs/apk/release/app-release.apk
```

## What's in this folder

| File | Purpose |
| --- | --- |
| `android-release-v1.2.2.patch` | All changes: signing config, workflow, transitions, version bump to `versionCode 10` / `1.2.2` |
| `keystore/progress-tracker.p12` | Release signing key (alias `progress-tracker`, password `ProgressTracker-Release-2026`) |
| `keystore/README.md` | Key details, certificate fingerprint, how to move it into CI secrets |
| `apply-release.sh` | Applies the patch + keystore, then (with `--push`) commits, tags and pushes |
| `preview-v1.2.2.html` | The updated browser preview, so you can feel the new motion before installing anything |

## The transition changes

Page motion:

- Fades in place from **black** instead of sliding sideways: `android:windowBackground` is now
  `#080A07`, which is what caused the white flash. 200ms, decelerate, 6dp rise.
- Plays **only when the page actually changes** — home → create → project. A page is identified
  by a key (`home`, `create`, `project:<id>`); re-rendering the same page is instant and silent.
- Renaming, undo, deadline changes, editing or deleting a milestone: no page transition at all.

Adding a milestone now owns its own moment:

- the page dims to 45% into the dark background and eases back over 320ms;
- the ring animates from the previous percentage to the new one over 520ms instead of snapping;
- the new milestone row fades up 6dp, with a 25ms stagger down the list.

Popups and menus lost their overshoot bounce: 170–190ms scale from 96% → 100% with a
decelerate curve, and the fluorescent dialog animations went from 220ms to 160ms.

## Two things to know

1. **One-time uninstall for existing installs.** v1.2.0 and earlier are signed with a different
   key, so Android will refuse to install v1.2.2 over them ("App not installed"). Uninstall the
   old build first — that also clears its local projects and milestones. From v1.2.2 on, updates
   install normally.
2. **The key is committed on purpose** (your call): no CI secrets needed, and far better than the
   public debug key — but treat it as an identity, not a secret. Back up the `.p12`; losing it
   means requiring an uninstall for every future release. `keystore/README.md` has the commands
   to move it into repository secrets later without touching `app/build.gradle`.

## Website follow-up (not done here)

`index.html` still points at `.../releases/download/v1.1.0/app-debug.apk` and its fineprint says
"debug-signed". Changing it now would break the download until v1.2.2 is published, so it is
left alone. After the release exists, either:

```html
<!-- pinned -->
href="https://github.com/owaiskhan-ash/Project-Progress-Widget/releases/download/v1.2.2/Progress-tracker-v1.2.2.apk"
<!-- or always latest; the workflow now also uploads progress-tracker.apk as a stable name -->
href="https://github.com/owaiskhan-ash/Project-Progress-Widget/releases/latest/download/progress-tracker.apk"
```

plus `<p class="fineprint">v1.2.2 &middot; 95 KB &middot; signed release build &middot; Android 6.0+</p>`.

## Verification status

- Patch applies cleanly to `main` (5610dc1) on a fresh clone — checked, twice.
- `apply-release.sh` dry run on a fresh clone produces the expected file set and `1.2.2` version — checked.
- Workflow is valid YAML with the expected steps; preview JavaScript parses (`node --check`) — checked.
- `MainActivity.java`, `ProgressRing.java` and `PaperDrawable.java` parse as valid Java — checked.
- The Gradle/Android build was **not** run (no JDK or Android SDK here), so the app itself is
  unverified on a device. If the CI run fails, the job's `::error::` lines point at the cause.
