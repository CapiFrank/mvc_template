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

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    exit(1);
  }

  String modelName = arguments[0].trim();
  if (modelName.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(modelName)) {
    exit(1);
  }

  String collectionName = camelCaseToSnakeCase(pluralize(modelName));
  String fileName = camelCaseToSnakeCase(modelName);
  String projectName = getProjectName();

  // Crear el contenido del modelo basado en el nombre
  String modelContent =
      '''
import 'package:$projectName/utils/model.dart';

class $modelName extends Model {
String text;

  $modelName(
      {super.id,
      this.text = ""
      });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }

  @override
  $modelName fromJson(Map<String, dynamic> json) {
    return $modelName(
        id: json['id'],
        text: json['text']);
  }

  static $modelName fromDoc(id, data) {
    return $modelName(
        id: id,
        text: data['text']);
  }

  @override
  String get table => "$collectionName";
}
''';

  // Crear un archivo en el directorio lib/models (o en el lugar que prefieras)
  Directory('lib/models').createSync(recursive: true);
  File('lib/models/$fileName.dart').writeAsStringSync(modelContent);
}
