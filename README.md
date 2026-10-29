# Progress Apps — website

A dark, fluorescent landing page for **Progress Apps**: a growing gallery of useful Android apps that are being released free for everyone.

The first featured release is [AutoWall](https://github.com/owaiskhan-ash/Automatic-wallpaper-changer), an automatic wallpaper changer for Android.

## Design

- Thin, compact typography using self-hosted Inter Tight
- Near-black background with fluorescent lime, cyan, pink and orange accents
- Custom CSS hero artwork and AutoWall UI preview (no remote image requests)
- Minimal responsive interface for mobile
- Accessible focus states, semantic landmarks and reduced-motion support
- Custom Progress Apps wordmark and favicon

## Run locally

The site is plain HTML and CSS with no build step or dependencies.

```sh
python3 -m http.server 3000
```

Then open <http://localhost:3000>.

## Files

```text
index.html      page structure and copy
styles.css      layout, artwork, animation, and responsive design
assets/         self-hosted font, licence, and favicon
```

## App links

The AutoWall download button points to the stable `releases/latest/download/AutoWall.apk` URL. Version information currently reflects v1.1.0 (Android 8.0+, approximately 7 MB).
