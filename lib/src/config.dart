import 'package:yaml/yaml.dart' as yaml;

import 'config_exception.dart';
import 'utils.dart';

/// pubspec.yaml config reader
class PubspecConfig {
  PubspecConfig() {
    final pubspecFile = getPubspecFile();
    if (pubspecFile == null) {
      throw ConfigException("Can't find 'pubspec.yaml' file.");
    }

    final pubspecFileContent = pubspecFile.readAsStringSync();
    final pubspecYaml = yaml.loadYaml(pubspecFileContent);

    if (pubspecYaml is! yaml.YamlMap) {
      throw ConfigException(
        "Failed to extract config from the 'pubspec.yaml' file.\nExpected YAML map but got ${pubspecYaml.runtimeType}.",
      );
    }

    final flutterConfig = pubspecYaml['svg_assets'];
    if (flutterConfig == null) {
      return;
    }

    _className = flutterConfig['class_name'] is String ? flutterConfig['class_name'] : null;
    _fileName = flutterConfig['file_name'] is String ? flutterConfig['file_name'] : null;
    _sourceDir = flutterConfig['source_dir'] is String ? flutterConfig['source_dir'] : null;
    _outputDir = flutterConfig['output_dir'] is String ? flutterConfig['output_dir'] : null;
  }

  String? _className;
  String? _fileName;
  String? _sourceDir;
  String? _outputDir;

  String? get className => _className;
  String? get fileName => _fileName;
  String? get sourceDir => _sourceDir;
  String? get outputDir => _outputDir;
}
