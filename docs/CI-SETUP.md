# CI and TestFlight setup

This page is the operational guide for a fork. It separates public build
validation from the private Apple signing and upload step.

## The three lanes

| Lane | Trigger | Runner | Secrets | Result |
| --- | --- | --- | --- | --- |
| Static gates | Push, pull request | GitHub-hosted | None | Architecture, analysis and unit tests |
| Integration | Push, pull request or manual | GitHub-hosted Windows/Linux | Darwin SDK cache only | Flutter/SwiftPM/IPA structural checks |
| TestFlight | Manual dispatch | Your self-hosted Windows/Linux runner | Apple API key and signing material | Signed IPA and App Store Connect processing |

The public integration workflow never receives Apple credentials from a pull
request. The TestFlight workflow is intentionally manual so a public push
cannot spend an Apple upload or expose a private key.

Integration runs are serialized per branch/ref. A running SwiftPM/IPA check is
never cancelled; a newer run waits behind it. GitHub retains one pending run
per concurrency group, so a burst of commits may collapse to the newest
pending commit while the active run is preserved.

## Fork setup

1. Fork the repository and enable Actions for the fork.
2. Clone with submodules:

   ```text
   git clone --recurse-submodules https://github.com/<owner>/<repo>.git
   ```

3. Run `Architecture`, `Unit Tests` and `Integration Tests` on `main`.
4. Warm the Darwin SDK cache from **Actions → Warm Darwin SDK cache → Run
   workflow**. Supply a short-lived, authenticated direct Xcode `.xip` URL.
   The URL must return an XIP archive, not an Apple login page.
5. Run `Integration Tests` again and confirm all four Windows/Linux Flutter
   jobs are green.

The cache workflow consumes the XIP on the hosted runners and deletes the
temporary archive at the end of each job. Do not commit the URL, the XIP, or a
Darwin SDK cache.

## Self-hosted runner

Install a GitHub Actions runner on the Windows or Linux machine that already
has the project-compatible xcross toolchain and Darwin SDK. Add both labels:

```text
self-hosted
xcross-ios
Windows    # use this on Windows
Linux      # use this on Linux
```

The runner must be trusted. Never use a self-hosted runner with unreviewed
pull-request code, because the TestFlight lane can access signing material.

The runner's project directory should contain the Flutter project and should
be able to run these commands before connecting it to Actions:

```text
xcross flutter doctor
xcross flutter build --release --ipa
xcross-testflight --help
```

## App Store Connect secrets

Create repository or environment secrets in **Settings → Secrets and
variables → Actions**. Use the exact names below:

```text
XCROSS_ASC_ISSUER_ID
XCROSS_ASC_KEY_ID
XCROSS_ASC_PRIVATE_KEY_CONTENT
XCROSS_ASC_APP_ID              # optional when the client resolves it by Bundle ID
```

`XCROSS_ASC_PRIVATE_KEY_CONTENT` is the complete text of the `.p8` file. It is
written only to the runner's temporary directory and removed in the final
workflow step. Never put the `.p8` file, Apple Distribution certificate,
private key, provisioning profile, or App Group data in Git.

The App Store Connect API key authorizes the upload. The IPA still needs valid
Apple Distribution signatures before the upload step. For an app extension,
the host app and every `.appex` need their own matching Bundle ID/profile and
entitlements; the extension must not be removed to bypass signing.

## Running the manual workflow

Open **Actions → Self-hosted TestFlight → Run workflow** and select:

| Input | Typical value |
| --- | --- |
| `host` | `Windows` or `Linux` |
| `project_path` | `.` or the project directory on the runner |
| `build` | `true` for a fresh IPA |
| `upload` | `true` to call App Store Connect |
| `wait` | `true` to wait for `VALID` |

To upload an already signed IPA, set `build=false` and provide `ipa_path`
relative to `project_path`.

The workflow uses `cancel-in-progress: false`. If a build or upload is active,
the next run waits in the queue and starts afterward. This prevents two runs
from racing on the same build number or producing a misleading duplicate
upload.

## Evidence and limits

Record each stage separately:

```text
Build: PASS/FAIL
Apple preflight: PASS/FAIL
Main app signature: PASS/FAIL
Extension signatures: PASS/FAIL/N/A
Upload reservation: PASS/FAIL
Upload commit: PASS/FAIL
App Store Connect processing: VALID/FAIL
Physical iPhone smoke test: PASS/FAIL/NOT TESTED
```

`VALID` means App Store Connect accepted and processed the binary. It is not a
device-runtime test. Camera, Firebase, MLKit, widgets and other native
features still require a real iPhone test.

## Keeping the fork healthy

- Keep Flutter, Swift, LLVM and Darwin SDK versions pinned in CI.
- Keep `cancel-in-progress: false` for build/upload workflows.
- Use cache keys that include host OS, architecture and SDK/toolchain version.
- Do not run `flutter clean` or delete SwiftPM caches as a first response.
- Update the README and compatibility matrix whenever a real project adds
  plugin evidence.
