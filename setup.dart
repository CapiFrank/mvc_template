import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    print("⚠️  Usa: dart setup.dart <nombre_proyecto>");
    exit(1);
  }

  final projectName = args[0];
  final currentDir = Directory.current;

  print("🚀 Configurando proyecto '$projectName'...");

  // 1. Renombrar carpetas de Android/iOS
  await _replaceInFiles(currentDir, 'my_template', projectName);

  // 2. Cambiar nombres de paquetes en pubspec.yaml
  await _replaceInFile(File('pubspec.yaml'), 'my_template', projectName);

  print("✅ Proyecto renombrado con éxito.");
}

Future<void> _replaceInFiles(Directory dir, String from, String to) async {
  await for (var entity in dir.list(recursive: true)) {
    if (entity is File) {
      if (entity.path.endsWith('.dart') ||
          entity.path.endsWith('.yaml') ||
          entity.path.endsWith('.gradle') ||
          entity.path.endsWith('.xml')) {
        await _replaceInFile(entity, from, to);
      }
    }
  }
}

Future<void> _replaceInFile(File file, String from, String to) async {
  final content = await file.readAsString();
  if (content.contains(from)) {
    final newContent = content.replaceAll(from, to);
    await file.writeAsString(newContent);
    print("✏️  Modificado: ${file.path}");
  }
}
