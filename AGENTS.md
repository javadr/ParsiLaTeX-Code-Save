# AGENTS.md

Firefox/Chrome WebExtension (Manifest V3) — "ParsiLaTeX Code Save": a content script that copies code chunks to the clipboard on double-click. Dependency-free: `sectoc.js` is the only script, no jQuery or other bundled library. No package manager, no test suite. CI exists: `.github/workflows/release.yml` builds the xpi (via `make xpi`) and cuts a GitHub release when `src/manifest.json`'s version is bumped on `main`.

## Layout

- `src/` — everything the xpi contains: `manifest.json`, `sectoc.js` (all logic, ~150 lines of plain JS), `sectoc.css`, `icons/`, and `.web-extension-id` (web-ext state, gitignored but needed for stable AMO identity `{9ccf0f94-0133-468d-8803-b55d6781cc79}` — same id as `browser_specific_settings.gecko.id`)
- Root: `README.md`, `LICENSE`, `privacy.html`, `AGENTS.md`, `Makefile`, `.gitignore`, `.github/workflows/release.yml` (`Makefile` + `src/` are what the AMO source zip ships)
- `web-ext-artifacts/` — build output, gitignored

## Build

- `make` or `make xpi` — builds `web-ext-artifacts/parsilatex-code-save-<version>.xpi` using plain `zip`; no npm/node needed. The xpi filename embeds the version read from `src/manifest.json` (via python3), so bumping `version` there changes the output name.
- `make check` — verifies the packaged file list and manifest JSON; run before build if you touched the file set.
- `make lint` / `make build` — need `web-ext` (`npm install --global web-ext`), not installed by default.
- `make sign WEB_EXT_API_KEY=... WEB_EXT_API_SECRET=...` — AMO signing flow (background: `sign` and `links.md` in the parent folder).

## Conventions / gotchas

- Packaging is file-name-based: `SOURCES` in the Makefile is the single source of truth — both zip recipes use `$(PAYLOAD)`, which is derived from it (`src/` prefix stripped, individual icons collapsed to `icons/`). Add a new file to `SOURCES` only. Keep `manifest.json` at the xpi root (the zip runs from inside `src/`). CI must not duplicate the list: `.github/workflows/release.yml` calls `make xpi`.
- The extension is shipped as a fork of "StackExchange Copy to Clipboard" (Martin Schmelzer) — keep the courtesy header in `sectoc.js`.
- No third-party or vendored JS: delegation, class toggling and the clipboard calls are done by hand. jQuery was removed in 0.2.6 — shipping the minified bundle tripped 3 AMO `UNSAFE_VAR_ASSIGNMENT` warnings on `innerHTML` and carried CVE-2020-11022/CVE-2020-11023 below 3.5.0. Re-adding any library means a `SOURCES` entry, a `content_scripts.js` entry, and a new `web-ext lint` baseline.
- Match patterns live in `src/manifest.json` `content_scripts.matches`; adding a site means editing that list. Current set: `qa.parsilatex.com` plus the main StackExchange network domains (`*.stackexchange.com`, `*.stackoverflow.com`, `*.askubuntu.com`, `*.superuser.com`, `*.serverfault.com`, `*.mathoverflow.net`, `*.stackapps.com`). A `*.domain` pattern already covers the bare domain, so never list both. `code-save/` sibling (deleted) once had extra matches (towardsdatascience, gmail) — the canonical set is the `ParsiLaTeX-Code-Save` one.
- Parent dir `ParsiLaTeXCodeSave/` is NOT a git repo; only `ParsiLaTeX-Code-Save/` is (remote: `javadr/ParsiLaTeX-Code-Save`, branch `main`). Loose `.xpi` files and notes in the parent are legacy build outputs.
- `src/.web-extension-id` must stay (don't delete): it pins the AMO extension ID for signing.
- No git commit/push unless asked.

## Verification

There are no tests. Verify with `make check`, then `make xpi` + `unzip -l web-ext-artifacts/*.xpi` (manifest.json at root, 3 files + `icons/` with 2 icons), and optionally `web-ext lint` — it must report 0 errors and 0 warnings; any `UNSAFE_VAR_ASSIGNMENT` means a minified third-party bundle crept back in. `node --check src/sectoc.js` catches syntax errors without a test runner.
