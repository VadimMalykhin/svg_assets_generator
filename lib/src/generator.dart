import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;

import 'config.dart';
import 'constants.dart';
import 'utils.dart';

final _dartfmt = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
);

class Generator {
  Generator() {
    final pubspecConfig = PubspecConfig();

    _className = defaultClassName;
    if (pubspecConfig.className != null) {
      if (isValidClassName(pubspecConfig.className!)) {
        _className = pubspecConfig.className!;
      } else {
        warning("Config parameter 'class_name' requires valid 'UpperCamelCase' value.");
      }
    }

    _fileName = defaultFileName;
    if (pubspecConfig.fileName != null) {
      _fileName = pubspecConfig.fileName!;
    }

    _sourceDir = defaultSourceDir;
    if (pubspecConfig.sourceDir != null) {
      if (isValidPath(pubspecConfig.sourceDir!)) {
        _outputDir = pubspecConfig.sourceDir!;
      } else {
        warning(
          "Config parameter 'source_dir' requires valid path value (e.g. 'svg', 'svg_assets').",
        );
      }
    }
    _outputDir = defaultOutputDir;
    if (pubspecConfig.outputDir != null) {
      if (isValidPath(pubspecConfig.outputDir!)) {
        _outputDir = pubspecConfig.outputDir!;
      } else {
        warning(
          r"Config parameter 'output_dir' requires valid path value (e.g. 'lib', 'lib\generated').",
        );
      }
    }
  }

  late String _className;
  late String _fileName;
  late String _sourceDir;
  late String _outputDir;

  /// Generate svg files.
  Future<void> generate() async {
    final classBuilder = ClassBuilder()
      ..name = _className
      ..constructors.add(
        Constructor(
          (b) => b
            ..name = '_'
            ..constant = true,
        ),
      );

    final svgFiles = await getSvgFiles(_sourceDir);
    for (final svg in svgFiles) {
      final svgName = formatName(path.basenameWithoutExtension(svg.path));
      final svgSource = formatSource(await File(svg.path).readAsString());

      classBuilder.fields.add(
        Field(
          (b) => b
            ..name = '\$$svgName'
            ..type = refer('String')
            ..static = true
            ..modifier = FieldModifier.constant
            ..assignment = Code("'''\n$svgSource\n'''"),
        ),
      );
    }

    // Build the class
    final library = Library(
      (b) => b..body.add(classBuilder.build()),
    );

    // Generate the Dart code
    final emitter = DartEmitter();
    final generatedCode = library.accept(emitter).toString();

    final formattedCode = _dartfmt.format(generatedCode);

    final saveTo = File(path.join(_outputDir, '$_fileName.dart'));

    await saveTo.writeAsString(template(formattedCode));
  }
}
