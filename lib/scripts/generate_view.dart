// ignore_for_file: avoid_print

import 'dart:io';

/// Convierte un nombre en CamelCase a snake_case
String camelCaseToSnakeCase(String input) {
  return input.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
    return '${match.group(1)}_${match.group(2)?.toLowerCase()}';
  }).toLowerCase();
}

/// Convierte un nombre en PascalCase a lowerCamelCase
String lowerCamelCase(String input) {
  if (input.isEmpty) return input;
  return input[0].toLowerCase() + input.substring(1);
}

/// Obtiene automáticamente el nombre del proyecto desde pubspec.yaml
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

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print("⚠️ Debes especificar el nombre de la vista. Ejemplo: dart make_view.dart User");
    exit(1);
  }

  String viewName = arguments[0]; // Ej: User
  String snakeCaseName = camelCaseToSnakeCase(viewName); // user
  String lowerCamelName = lowerCamelCase(viewName); // user
  String projectName = getProjectName();

  // Contenido de la vista moderna
  String viewContent = '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:$projectName/controllers/${snakeCaseName}_controller.dart';
import 'package:$projectName/views/components/info_card.dart';
import 'package:$projectName/views/layouts/scroll_layout.dart';
import 'package:$projectName/utils/utilities.dart';

class ${viewName}View extends StatefulWidget {
  const ${viewName}View({super.key});

  @override
  ${viewName}ViewState createState() => ${viewName}ViewState();
}

class ${viewName}ViewState extends State<${viewName}View> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<${viewName}Controller>().index();
    });
  }


  @override
  Widget build(BuildContext context) {
    ${viewName}Controller ${lowerCamelName}Controller = context.watch<${viewName}Controller>();
    final ${snakeCaseName}List = ${lowerCamelName}Controller.${pluralize(lowerCamelName)};
    if (${lowerCamelName}Controller.isLoading) return loadingProgress();
    return ScrollLayout(
      toolbarHeight: 280,
      isEmpty: ${snakeCaseName}List.isEmpty,
      showEmptyMessage: true,
      bodyChild: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final $lowerCamelName = ${snakeCaseName}List[index];
          return InfoCard(
            title: Text($lowerCamelName.text),
          );
        }, childCount: ${snakeCaseName}List.length),
      ),
    );
  }
}
''';

  // Crear el archivo en lib/views
  Directory('lib/views').createSync(recursive: true);
  File('lib/views/${snakeCaseName}_view.dart').writeAsStringSync(viewContent);

  print("✅ Vista creada: lib/views/${snakeCaseName}_view.dart");
}

/// Función simple para pluralizar (puedes mejorarla si quieres)
String pluralize(String word) {
  if (word.endsWith('y')) {
    return '${word.substring(0, word.length - 1)}ies';
  } else if (RegExp(r'(s|x|z|ch|sh)$').hasMatch(word)) {
    return '${word}es';
  }
  return '${word}s';
}
