# Chrome Web Store

Old listing (linked from the README): <https://chrome.google.com/webstore/detail/tomato-life/kkacpbmkhbljebmpcopjlgfgbgeokbhn>

Developer dashboard: <https://chrome.google.com/webstore/devconsole> (snomiao@gmail.com)

## Submissions

### 1.4.2 — submitted 2026-09-27

Status: submitted for review.

Dashboard message:

> Your extension was submitted for review. You may check the status on the developer dashboard home page.
>
> Items staged to be published later will expire 30 days after they have passed review.

What changed:

- Migrated to Manifest V3 for real: a service worker (`src/worker.js`) wakes every minute via `chrome.alarms` and plays the chime at :00/:30 (work) and :25/:55 (rest) through an offscreen document (`src/offscreen.html`). Before this the chime only played while the popup was open.
- Toolbar badge shows minutes left: red for work, green for rest.
- Permissions: `alarms`, `offscreen` (replaced the unused `background`).
- `homepage_url` now points to the GitHub repo (`snomiao.com/tomato-life` returned 404).
- Removed the MV2 leftovers `src/background.html` and `src/background.js`.

Listing details:

- Category: Productivity → Workflow & Planning; language: English.
- Privacy policy: <https://github.com/snomiao/tomato-life/blob/master/docs/PRIVACY.md>. The dashboard requires the URL even though the extension collects no data.
- Distribution: free, public, all regions.

## How to submit a new version

1. Bump `version` in `src/manifest.json`.
2. Build the zip. On Windows use the system `tar.exe`, because `bun build-extension.ts` (cross-zip) writes backslash paths like `assets\Tomato.png`, which Chrome can't resolve:

   ```sh
   cd src && /c/Windows/System32/tar.exe -a -c -f ../dist/TomatoLife.zip *
   ```

3. The upload kit in `store/` (serve the repo root, e.g. `python -m http.server 8765`, then open <http://127.0.0.1:8765/store/>) has the listing text, permission justifications and store images. Screenshots are rendered from `store/shots/*.html` with headless Chrome.
4. Upload it on the dashboard yourself. Chrome blocks extensions from scripting `chrome.google.com`, so rechrome and other extension-driven automation can't open the dashboard.
