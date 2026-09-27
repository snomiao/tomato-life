# Chrome Web Store

Current item ID: `fdpgimhoidilfibpfjbeglepdeedffno` (created 2026-09-27 as a new item)

- Public listing (live once review passes): <https://chromewebstore.google.com/detail/fdpgimhoidilfibpfjbeglepdeedffno>
- Dashboard package page: <https://chrome.google.com/webstore/devconsole/b952b326-9677-4ccf-9ed7-ddce0f28dc4f/fdpgimhoidilfibpfjbeglepdeedffno/edit/package>
- Publisher ID: `b952b326-9677-4ccf-9ed7-ddce0f28dc4f` (snomiao@gmail.com)

Old item ID: `kkacpbmkhbljebmpcopjlgfgbgeokbhn` (still linked from the README). It no longer serves a version to Chrome, probably taken down with the MV2 extensions.

## Submissions

### 1.4.2 — submitted 2026-09-27

Status: submitted for review as a new item, `fdpgimhoidilfibpfjbeglepdeedffno`.

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
- Privacy policy: <https://github.com/snomiao/tomato-life/blob/main/docs/PRIVACY.md>. The dashboard requires the URL even though the extension collects no data.
- Distribution: free, public, all regions.

## How to submit a new version

1. Bump `version` in `src/manifest.json`. The store rejects a version that isn't higher than the current one.
2. Push a `v*` tag. The `.github/workflows/chrome-web-store.yml` workflow runs `bun scripts/release-extension.ts`, which zips `src/`, uploads it and submits it for review.

To release from a local machine instead, set `CWS_SERVICE_ACCOUNT_KEY` (the JSON key) or `CWS_ACCESS_TOKEN` and run `bun scripts/release-extension.ts`. Add `--no-publish` to upload a draft without submitting it, or `--status` to only print the item status. The same flags can be passed when starting the workflow by hand (Actions → Chrome Web Store → Run workflow). `bun build-extension.ts` alone builds `dist/TomatoLife.zip`.

### API access

- Chrome Web Store API v2, enabled in the gcloud project `snomiao`.
- Service account `tomato-life-cws@snomiao.iam.gserviceaccount.com`; it must be added under **Account** in the developer dashboard (one service account per publisher).
- Its JSON key is the GitHub secret `CWS_SERVICE_ACCOUNT_KEY` (key ID `a0ab8350f704fd882475bf10502ad20c1c3c5000`, created 2026-09-27). No local copy is kept; to rotate, create a new key and run `gh secret set CWS_SERVICE_ACCOUNT_KEY < key.json`, then delete the old key.
- The API can only update an existing item. A new item has to be created on the dashboard, which rechrome can't open because Chrome blocks extensions on `chrome.google.com`.

### Store listing

The upload kit in `store/` has the listing text, permission justifications and store images. Serve the repo root (e.g. `python -m http.server 8765`) and open <http://127.0.0.1:8765/store/>. Screenshots are rendered from `store/shots/*.html` with headless Chrome.
