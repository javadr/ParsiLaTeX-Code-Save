# ParsiLaTeX Code Save
A Firefox ADD-ONS which saves the code section of the [ParsiLaTeX](https://qa.parsilatex.com) by double-clicking.
It also supports StackExchange Network.

# Introduction

[ParsiLaTeX](https://parsilatex.com) group supports  Persian users of TeX/LaTeX by preparing packages, slides, books, and some other stuff around how to typeset with TeX/LaTeX in Persian. It targets people from Iran, Afghanistan, and Tajikistan who write in Persian scripts. One of the facilities that [ParsiLaTeX](https://parsilatex.com) provides for their users is a Question and Answer site similar to [StackExchange](https://tex.stackexchange.com) but the communication language there is Persian. As you know, the Q&A site includes lots of code blocks in their question or answer parts. The process of copying the code text would be very time-consuming and this `firefox extension` tries to address this issue. 


# Installation

- **Firefox**: go to the [ParsiLaTeX Code Save ADD-ONS page](https://addons.mozilla.org/en-US/firefox/addon/parsilatex-code-save/) and click on **Add to Firefox**.
- **Chrome**: go to the [ParsiLaTeX Code Save page on the Chrome Web Store](https://chromewebstore.google.com/detail/parsilatex-code-save/edaclfjppagddmnhmkkiphbmjkcgklha) and click on **Add to Chrome**. 

# Using the extension in Firefox

- **Recommended**: install the signed add-on from the [AMO page](https://addons.mozilla.org/en-US/firefox/addon/parsilatex-code-save/) linked above.
- **From a GitHub release**: download `parsilatex-code-save-<version>.xpi` from the [Releases page](https://github.com/javadr/ParsiLaTeX-Code-Save/releases). These builds are **unsigned**, so on stable Firefox you cannot install them directly; either:
  - use Firefox **Developer Edition / Nightly / ESR** and set `xpinstall.signatures.required` to `false` in `about:config`, then drag the `.xpi` onto `about:addons`, or
  - open `about:debugging#/runtime/this-firefox`, click **Load Temporary Add-on** and select `src/manifest.json` — no signing needed, but the add-on disappears when Firefox is closed.
- **Build it yourself**: run `make xpi` in this directory to produce `web-ext-artifacts/parsilatex-code-save-<version>.xpi`, then install it as above.

# Using the extension in Chrome / Chromium (Chrome, Edge, Brave, Vivaldi)

Chrome cannot install the Firefox `.xpi` directly — load the unpacked source instead:

1. Open `chrome://extensions`.
2. Enable **Developer mode** (top-right toggle).
3. Click **Load unpacked** and select the `src/` folder from this repository.
4. Open a site listed under `content_scripts.matches` in `src/manifest.json` (e.g. `parsilatex.com` or any StackExchange site) and double-click a code block to copy it.

Notes:
- Chrome silently ignores the `browser_specific_settings` block, so the same `src/` folder works in both browsers.
- A loaded-unpacked extension stays active after a Chrome restart as long as the folder is not moved or deleted.
- The extension is Manifest V3, so it also works in other Chromium-based browsers the same way. 


# Courtesy to [Martin Schmelzer](https://addons.mozilla.org/en-US/firefox/user/13904961/?utm_source=firefox-browser&utm_medium=firefox-browser&utm_content=addons-manager-user-profile-link)
This code is a fork from [StackExchange Copy to Clipboard](https://addons.mozilla.org/en-US/firefox/addon/stackexchangecopytoclipboard/) with just some modifications. 

