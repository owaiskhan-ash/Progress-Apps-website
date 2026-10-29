# Progress Apps — website

A single-app landing page for [Papertrail](https://github.com/owaiskhan-ash/Project-Progress-Widget),
a minimal Android project tracker with a transparent home-screen widget.

Static HTML, CSS and a few lines of JS. No build step, no dependencies.

```
index.html      the page
styles.css      all styling
assets/         favicon + self-hosted font
```

## Run locally

Any static server works, for example:

```sh
python3 -m http.server 3000
```

Then open <http://localhost:3000>.

## Deploy

The page is plain static files, so it can be served directly by GitHub Pages
(branch → root) or any static host.

## Notes

- Download links point to the latest GitHub release (`v1.1.0` at the time of writing).
  Update them when a new release is tagged.
- Type is [Inter Tight](https://fonts.google.com/specimen/Inter+Tight), self-hosted as a
  single 44 KB variable `woff2` at weights 200–400 (SIL OFL, licence included in `assets/`).
  The page makes no third-party requests.
- The ring in the widget preview is drawn with inline SVG; the 68% arc animates once on load
  and is skipped under `prefers-reduced-motion`.
