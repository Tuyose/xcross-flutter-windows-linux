# Contributing

Thanks for helping make cross-platform Flutter/iOS builds reproducible.

## Verification order

Use this order and report every gate as `PASS`, `FAIL`, `BLOCKED` or
`NOT TESTED`:

```text
PLAN → IMPLEMENT → STATIC TEST → HOST INTEGRATION TEST → REPORT
```

For a normal code change:

1. Read the smallest relevant package and workflow files.
2. Make one isolated change.
3. Run formatting, analysis and the affected unit tests.
4. Run the Windows/Linux integration workflow when the toolchain or build path
   changes.
5. Include the exact command, commit, host, toolchain versions and first real
   error in the pull request.

## Safe debugging rules

- Do not use macOS or a remote Mac to claim a Windows/Linux result.
- Do not commit Apple credentials, `.p8`, `.p12`, `.mobileprovision`, private
  keys, Xcode archives or private SDK caches.
- Do not start by deleting Flutter, SwiftPM or toolchain caches. Preserve them
  so the failure is reproducible.
- Do not hide a linker or runtime problem with `dynamic_lookup`.
- Keep source changes small and preserve upstream copyright notices.
- Treat a successful IPA link as a build result, not as proof that every device
  feature works.

## Pull request checklist

- [ ] The change is scoped and the affected files are listed.
- [ ] No secret or proprietary Apple artifact is included.
- [ ] Static checks were run.
- [ ] Relevant Windows/Linux tests were run, or marked `NOT TESTED`.
- [ ] First real error and final evidence are included.
- [ ] README/docs are updated when behavior or setup changes.
