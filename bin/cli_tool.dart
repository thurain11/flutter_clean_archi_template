import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty ||
      arguments.contains('--help') ||
      arguments.contains('-h')) {
    _printUsage();
    return;
  }

  final rawFeatureName = arguments.first;
  final projectDirPath =
      _parseOption(arguments, '-p', '--project') ?? Directory.current.path;
  final outputDir = _parseOption(arguments, '-o', '--output') ?? projectDirPath;
  final onConflict = _parseOption(arguments, '--on-conflict') ?? 'skip';
  final projectDir = Directory(projectDirPath);

  final featureSnake = _toSnakeCase(rawFeatureName);
  final featurePascal = _toPascalCase(rawFeatureName);

  if (!projectDir.existsSync()) {
    stderr.writeln('Project path not found: "$projectDirPath"');
    exitCode = 64;
    return;
  }

  final toolRoot = await _resolveToolRoot();
  final brickPath = '${toolRoot.path}/bricks/clean_feature';
  final masonCachePath = '${toolRoot.path}/.mason-cache';
  Directory(masonCachePath).createSync(recursive: true);
  final masonEnv = <String, String>{
    ...Platform.environment,
    'MASON_CACHE': masonCachePath,
    'HOME': projectDir.path,
  };

  if (!Directory(brickPath).existsSync()) {
    stderr.writeln('Cannot find brick template at: $brickPath');
    exitCode = 66;
    return;
  }

  if (featureSnake.isEmpty) {
    stderr.writeln('Invalid feature name: "$rawFeatureName"');
    exitCode = 64;
    return;
  }

  final configFile = File(
    '${Directory.systemTemp.path}/mason_${featureSnake}_${DateTime.now().microsecondsSinceEpoch}.json',
  );

  final config = <String, String>{
    'feature_name': rawFeatureName,
    'feature_snake': featureSnake,
    'feature_pascal': featurePascal,
  };

  await configFile.writeAsString(jsonEncode(config));

  try {
    final masonYaml = File('${projectDir.path}/mason.yaml');
    if (!masonYaml.existsSync()) {
      stdout.writeln('Initializing Mason in: ${projectDir.path}');
      final initResult = await Process.run(
        'mason',
        ['init'],
        workingDirectory: projectDir.path,
        environment: masonEnv,
      );
      _printProcessResult(initResult);
      if (initResult.exitCode != 0) {
        exitCode = initResult.exitCode;
        return;
      }
    }

    await Process.run(
      'mason',
      ['remove', 'clean_feature'],
      workingDirectory: projectDir.path,
      environment: masonEnv,
    );

    stdout.writeln('Registering clean_feature brick...');
    final addResult = await Process.run(
      'mason',
      ['add', 'clean_feature', '--path', brickPath],
      workingDirectory: projectDir.path,
      environment: masonEnv,
    );
    _printProcessResult(addResult);
    if (addResult.exitCode != 0) {
      exitCode = addResult.exitCode;
      return;
    }

    stdout.writeln('Resolving local Mason bricks...');
    final getResult = await Process.run(
      'mason',
      ['get'],
      workingDirectory: projectDir.path,
      environment: masonEnv,
    );
    _printProcessResult(getResult);
    if (getResult.exitCode != 0) {
      exitCode = getResult.exitCode;
      return;
    }

    stdout.writeln('Generating feature "$featureSnake"...');
    final makeResult = await Process.run(
      'mason',
      [
        'make',
        'clean_feature',
        '--config-path',
        configFile.path,
        '--output-dir',
        outputDir,
        '--on-conflict',
        onConflict,
      ],
      workingDirectory: projectDir.path,
      environment: masonEnv,
    );
    _printProcessResult(makeResult);
    if (makeResult.exitCode != 0) {
      exitCode = makeResult.exitCode;
      return;
    }

    stdout.writeln('Done. Generated in: $outputDir/lib/features/$featureSnake');
  } finally {
    if (await configFile.exists()) {
      await configFile.delete();
    }
  }
}

void _printProcessResult(ProcessResult result) {
  if ((result.stdout as String).trim().isNotEmpty) {
    stdout.write(result.stdout);
  }
  if ((result.stderr as String).trim().isNotEmpty) {
    stderr.write(result.stderr);
  }
}

String? _parseOption(List<String> args, String short, [String? long]) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == short || (long != null && args[i] == long)) {
      if (i + 1 < args.length) {
        return args[i + 1];
      }
    }
  }
  return null;
}

Future<Directory> _resolveToolRoot() async {
  final packageUri = await Isolate.resolvePackageUri(
    Uri.parse('package:cli_tool/cli_tool.dart'),
  );

  final searchRoots = <Directory>[
    if (packageUri != null) File.fromUri(packageUri).parent,
    File.fromUri(Platform.script).parent,
    Directory.current,
  ];

  for (final root in searchRoots) {
    final found = _searchUpForToolRoot(root);
    if (found != null) {
      return found;
    }
  }

  throw StateError(
    'Unable to locate tool root containing bricks/clean_feature',
  );
}

Directory? _searchUpForToolRoot(Directory start) {
  var current = start.absolute;

  while (true) {
    final brickDir = Directory('${current.path}/bricks/clean_feature');
    if (brickDir.existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }

    current = parent;
  }
}

String _toSnakeCase(String input) {
  final normalized = input
      .trim()
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      )
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '')
      .toLowerCase();
  return normalized;
}

String _toPascalCase(String input) {
  final words = input
      .trim()
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (m) => '${m.group(1)} ${m.group(2)}',
      )
      .split(RegExp(r'[^a-zA-Z0-9]+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      );

  return words.join();
}

void _printUsage() {
  stdout.writeln('''
Clean Architecture Feature Generator

Usage:
  dart run bin/cli_tool.dart <feature_name> [options]

Options:
  -p, --project <path>          Target Flutter project path (default: current directory)
  -o, --output <path>           Output directory (default: project path)
  --on-conflict <strategy>      prompt | overwrite | append | skip (default: skip)
  -h, --help                    Show help

Example:
  dart run bin/cli_tool.dart post
  dart run bin/cli_tool.dart post --project /path/to/flutter_project
  dart run bin/cli_tool.dart user_profile --on-conflict overwrite
''');
}
