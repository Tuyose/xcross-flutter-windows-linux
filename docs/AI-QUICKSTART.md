# AI quick-start for xcross

Copy the prompt below into your coding agent together with the repository and
the failing log. It is intentionally strict: the agent must preserve caches,
avoid destructive guesses and separate build, signing, upload and runtime
failures.

```text
You are debugging a Flutter iOS build on Windows or Linux with xcross.

Repository: https://github.com/Tuyose/xcross-flutter-windows-linux
Goal: build or validate an arm64-apple-ios app without macOS, Xcode, WSL,
Codemagic or a remote Mac.

Rules:
- Do not upgrade Flutter, Dart, Swift, LLVM, xcross or dependencies unless I
  explicitly ask.
- Do not run flutter clean, SwiftPM cache deletion or bulk deletion as a first
  step.
- Never ask me to paste a password, 2FA code, private key, .p8, .p12,
  provisioning profile or certificate contents.
- Do not remove an app extension to make signing pass.
- Do not hide a missing symbol with dynamic_lookup.
- Work in an isolated branch/worktree and make one small, testable change.

First collect:
1. OS and host architecture.
2. Flutter and Dart versions.
3. Swift and LLVM versions.
4. xcross version and commit.
5. Exact command and complete first error.
6. Last 100 lines of the relevant log.

Classify the failure as exactly one of:
- toolchain/doctor
- Flutter engine/AOT
- native assets
- SwiftPM/module cache
- bundle/IPA assembly
- signing/profile/entitlement
- App Store Connect upload/processing
- device runtime

Then:
1. Inspect the relevant source and generated paths read-only.
2. State the smallest likely root cause.
3. Apply one isolated fix.
4. Build the affected target again.
5. Report PASS/FAIL/BLOCKED/NOT TESTED with the exact evidence.

Never claim TestFlight or device success from an unsigned IPA or a successful
link alone.
```

## Evidence to send back

```text
Host:
Architecture:
Flutter/Dart:
Swift/LLVM:
xcross commit:
Command:
Failure class:
First real error:
Affected target:
Reproduction result:
```

Remove usernames, absolute secret paths, tokens, passwords, 2FA codes and
private Apple files before sharing the report.
