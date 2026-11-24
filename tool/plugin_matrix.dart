import 'dart:convert';
import 'dart:io';

const _allowedStatuses = <String>{
  'proven',
  'proven-with-override',
  'needs-validation',
  'not-tested',
  'runtime-risk',
};

Future<void> main(List<String> arguments) async {
  final markdown = arguments.contains('--markdown');
  final fileArgument = _option(arguments, '--file');
  final file = fileArgument == null
      ? File.fromUri(
          Platform.script.resolve('../docs/plugin-compatibility.json'),
        )
      : File(fileArgument);
  if (!file.existsSync()) {
    stderr.writeln('Compatibility matrix not found: ${file.path}');
    exitCode = 2;
    return;
  }

  final Object? decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map) {
    throw const FormatException('Matrix root must be an object.');
  }
  final root = decoded.cast<String, Object?>();
  final entries = root['entries'];
  if (entries is! List || entries.isEmpty) {
    throw const FormatException(
      'Matrix must contain a non-empty entries list.',
    );
  }

  final rows = <MatrixRow>[];
  for (var index = 0; index < entries.length; index++) {
    final rawValue = entries[index];
    if (rawValue is! Map) {
      throw FormatException('Entry $index is not an object.');
    }
    final raw = rawValue.cast<String, Object?>();
    final name = _requiredString(raw, 'name', index);
    final kind = _requiredString(raw, 'kind', index);
    final status = _requiredString(raw, 'status', index);
    _requiredString(raw, 'evidence', index);
    _requiredString(raw, 'notes', index);
    final hosts = _requiredStrings(raw, 'hosts', index);
    final target = _requiredString(raw, 'target', index);
    if (!_allowedStatuses.contains(status)) {
      throw FormatException('Entry $index has unsupported status "$status".');
    }
    rows.add(
      MatrixRow(
        name: name,
        kind: kind,
        status: status,
        hosts: hosts.join(', '),
        target: target,
      ),
    );
  }

  if (markdown) {
    stdout.write(_markdown(rows));
  } else {
    stdout.write(_plain(rows));
  }
}

String? _option(List<String> arguments, String name) {
  final prefix = '$name=';
  for (final argument in arguments) {
    if (argument.startsWith(prefix)) return argument.substring(prefix.length);
  }
  final index = arguments.indexOf(name);
  if (index >= 0 && index + 1 < arguments.length) return arguments[index + 1];
  return null;
}

String _requiredString(Map<String, Object?> raw, String key, int index) {
  final value = raw[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Entry $index is missing non-empty $key.');
  }
  return value.trim();
}

List<String> _requiredStrings(Map<String, Object?> raw, String key, int index) {
  final value = raw[key];
  if (value is! List || value.isEmpty || value.any((item) => item is! String)) {
    throw FormatException('Entry $index is missing a non-empty $key list.');
  }
  return [
    for (final item in value) (item as String).trim(),
  ].where((item) => item.isNotEmpty).toList();
}

String _plain(List<MatrixRow> rows) {
  final buffer = StringBuffer();
  buffer.writeln('xcross plugin compatibility (${rows.length} entries)');
  for (final row in rows) {
    buffer.writeln(
      '${row.status.padRight(24)} ${row.name} '
      '[${row.hosts} -> ${row.target}]',
    );
  }
  return buffer.toString();
}

String _markdown(List<MatrixRow> rows) {
  final buffer = StringBuffer()
    ..writeln('| Component | Kind | Status | Hosts | Target |')
    ..writeln('| --- | --- | --- | --- | --- |');
  for (final row in rows) {
    buffer.writeln(
      '| ${_cell(row.name)} | ${_cell(row.kind)} | ${_cell(row.status)} | '
      '${_cell(row.hosts)} | ${_cell(row.target)} |',
    );
  }
  return buffer.toString();
}

String _cell(String value) => value.replaceAll('|', r'\|');

// ignore: missing_internal
final class MatrixRow {
  const MatrixRow({
    required this.name,
    required this.kind,
    required this.status,
    required this.hosts,
    required this.target,
  });

  final String name;
  final String kind;
  final String status;
  final String hosts;
  final String target;
}
