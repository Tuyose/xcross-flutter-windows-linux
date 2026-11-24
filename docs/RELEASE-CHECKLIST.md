# Release checklist

Use this checklist before publishing a new xcross distribution release.

## Source and tests

- [ ] `git status` contains only intended changes.
- [ ] No `.p8`, `.p12`, `.pfx`, `.mobileprovision`, private key, Xcode archive
      or private SDK cache is tracked.
- [ ] `dart analyze` passes.
- [ ] Package tests pass on the supported host matrix.
- [ ] Integration Tests pass on Windows x64, Windows ARM64, Linux x64 and
      Linux ARM64 when the Darwin cache is available.
- [ ] Skipped macOS/simulator checks are labelled as skipped, not reported as
      device evidence.

## Version and release

Update the workspace and package version together, then create an annotated
version tag:

```powershell
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

The release workflow builds and publishes Windows x64/ARM64 and Linux
x64/ARM64 archives, generates `SHA256SUMS.txt`, and attaches build provenance
when the tag is pushed.

## TestFlight is separate

Do not make TestFlight an implicit part of a public release tag. Run the
manual self-hosted workflow only after:

- the Apple Distribution signatures and extension profiles are ready;
- the build number is higher than the last uploaded build;
- the App Store Connect secrets are configured in GitHub, not in Git;
- the runner is trusted and labelled `xcross-ios`.

Report App Store Connect `VALID` and physical-device testing as separate
results.
