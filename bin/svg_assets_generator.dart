import 'package:svg_assets_generator/svg_assets_generator.dart';

///
/// Generate Command:
/// dart run svg_assets_generator
///
Future<void> main(List<String> args) async {
  try {
    final generator = Generator();
    await generator.generate();
  } on GeneratorException catch (e) {
    exitWithError(e.message);
  } catch (e) {
    exitWithError('Failed to generate svg files.\n$e');
  }
}
