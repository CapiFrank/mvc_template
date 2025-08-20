// ignore_for_file: avoid_print

import 'dart:io';

String getProjectName() {
  final file = File('../../pubspec.yaml'); 
  if (!file.existsSync()) {
    throw Exception("⚠️ No se encontró pubspec.yaml en el directorio actual.");
  }
  final lines = file.readAsLinesSync();
  for (final line in lines) {
    if (line.startsWith('name:')) {
      return line.split(':').last.trim();
    }
  }
  throw Exception("⚠️ No se pudo obtener el nombre del proyecto en pubspec.yaml");
}

String camelCaseToSnakeCase(String input) {
  return input.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
    return '${match.group(1)}_${match.group(2)?.toLowerCase()}';
  }).toLowerCase();
}

String pluralize(String word) {
  if (word.endsWith('y')) {
    return '${word.substring(0, word.length - 1)}ies';
  } else if (RegExp(r'(s|x|z|ch|sh)$').hasMatch(word)) {
    return '${word}es';
  }
  return '${word}s';
}

String lowerCamelCase(String input) {
  return input[0].toLowerCase() + input.substring(1);
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print("⚠️  Debes especificar el nombre del controlador.");
    exit(1);
  }

  String modelName = arguments[0]; // Ej: User
  String modelVar = lowerCamelCase(modelName); // user
  String collectionName = pluralize(modelVar); // users
  String fileName = '${camelCaseToSnakeCase(modelName)}_controller.dart'; // user_controller.dart
  String projectName = getProjectName();

  String controllerContent = '''
import 'package:$projectName/utils/controller.dart';
import 'package:$projectName/models/${camelCaseToSnakeCase(modelName)}.dart';
import 'package:$projectName/utils/utilities.dart';

class ${modelName}Controller extends Controller {
  final List<$modelName> _$collectionName = [];

  List<$modelName> get $collectionName => List.unmodifiable(_$collectionName);

  Future<void> index() async {
    setLoading(true);
    try {
      _$collectionName.clear();
      _$collectionName.addAll(await $modelName().all());
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> store({
    required String id,
    // 👉 Agrega aquí más atributos según tu modelo
  }) async {
    setLoading(true);
    try {
      final $modelVar = $modelName(id: id);
      await $modelVar.create();
      _$collectionName.insert(0, $modelVar);
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> update({
    required String id,
    // 👉 Agrega aquí más atributos opcionales
  }) async {
    setLoading(true);
    try {
      final $modelVar = await $modelName(id: id).find();
      if ($modelVar == null) {
        throw Exception("⚠️ $modelName with id \$id not found");
      }
      // 👉 Aplica actualizaciones sobre $modelVar
      await $modelVar.update();

      final index = _$collectionName.indexWhere((u) => u.id == id);
      if (index != -1) {
        _$collectionName[index] = $modelVar;
      }
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> destroy({required String id}) async {
    setLoading(true);
    try {
      final $modelVar = $modelName(id: id);
      await $modelVar.delete();
      _$collectionName.removeWhere((u) => u.id == id);
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }
}
''';

  Directory('lib/controllers').createSync(recursive: true);
  File('lib/controllers/$fileName').writeAsStringSync(controllerContent);

  print("✅ Controlador creado: lib/controllers/$fileName");
}
