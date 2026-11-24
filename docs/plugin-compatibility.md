# Plugin compatibility matrix

This matrix separates evidence from assumptions. `proven-with-override` means
the plugin compiled in the Nofpad case study only after an isolated source
override; it is not a promise that an arbitrary version works unchanged.

The machine-readable source is
[`plugin-compatibility.json`](plugin-compatibility.json). Print it locally:

```text
dart tool/plugin_matrix.dart
dart tool/plugin_matrix.dart --markdown
```

## Status meanings

| Status | Meaning |
| --- | --- |
| `proven` | The stated host/target path has CI or reproducible build evidence. |
| `proven-with-override` | The path worked with an explicit, isolated native-source override. |
| `needs-validation` | The entry is documented but no current evidence is attached. |
| `not-tested` | No claim is made. |
| `runtime-risk` | Build/link evidence exists, but a real-device feature test is still required. |

Every new plugin entry should include its host, target, evidence and the exact
override or project used. A successful link is never promoted to runtime
proof automatically.
