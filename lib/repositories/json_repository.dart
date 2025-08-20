import 'dart:convert';
import 'dart:io';

import 'package:mvc_template/utils/model.dart';
import 'package:path_provider/path_provider.dart';
import 'repository.dart';

class JsonRepository<T extends Model<T>> implements Repository<T> {
  final String dbPath;
  final T Function(Map<String, dynamic>) fromJson;
  final bool prettyPrint; // útil en desarrollo

  JsonRepository(
    this.dbPath,
    this.fromJson, {
    this.prettyPrint = false,
  });

  Future<Map<String, dynamic>> _readDb() async {
    final dir = await getExternalStorageDirectory(); 
    final file = File('${dir!.path}/$dbPath');

    if (!await file.exists()) {
      await file.writeAsString(jsonEncode({})); // Inicializar vacío
      return {};
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return {};
    }

    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> _writeDb(Map<String, dynamic> db) async {
    final dir = await getExternalStorageDirectory(); 
    final file = File('${dir!.path}/$dbPath');
    final encoder = prettyPrint
        ? JsonEncoder.withIndent("  ")
        : const JsonEncoder();
    await file.writeAsString(encoder.convert(db));
  }

  Future<List<T>> _loadAll(String table) async {
    final db = await _readDb();
    final data = db[table] as List<dynamic>? ?? [];
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveAll(String table, List<T> items) async {
    final db = await _readDb();
    db[table] = items.map((e) => e.toJson()).toList();
    await _writeDb(db);
  }

  @override
  Future<List<T>> all(T model) => _loadAll(model.table);

  @override
  Future<void> create(T model) async {
    final items = await _loadAll(model.table);
    items.add(model);
    await _saveAll(model.table, items);
  }

  @override
  Future<void> update(String id, T newItem) async {
    final items = await _loadAll(newItem.table);
    final index = items.indexWhere((e) => e.id == id);

    if (index == -1) {
      throw Exception("⚠️ Item with id $id not found in ${newItem.table}");
    }

    items[index] = newItem;
    await _saveAll(newItem.table, items);
  }

  @override
  Future<void> delete(String id, T model) async {
    final items = await _loadAll(model.table);
    final updatedItems = items.where((e) => e.id != id).toList();

    if (items.length == updatedItems.length) {
      throw Exception("⚠️ Item with id $id not found in ${model.table}");
    }

    await _saveAll(model.table, updatedItems);
  }

  @override
  Future<T?> find(T model) async {
    final items = await _loadAll(model.table);
    try {
      return items.firstWhere((item) => item.id == model.id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<T>> where(bool Function(T) test, T model) async {
    final items = await _loadAll(model.table);
    return items.where(test).toList();
  }

  @override
  Future<T?> firstWhere(bool Function(T) test, T model) async {
    final items = await _loadAll(model.table);
    try {
      return items.firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> exists(bool Function(T) test, T model) async {
    final items = await _loadAll(model.table);
    return items.any(test);
  }

  @override
  Future<List<T>> orderBy(
    Comparable Function(T) key,
    T model, {
    bool descending = false,
  }) async {
    final items = await _loadAll(model.table);
    final sorted = [...items]
      ..sort((a, b) =>
          descending ? key(b).compareTo(key(a)) : key(a).compareTo(key(b)));
    return sorted;
  }

  @override
  Future<List<T>> limit(int count, T model) async {
    final items = await _loadAll(model.table);
    return items.take(count).toList();
  }

  @override
  Future<int> count(T model) async {
    final items = await _loadAll(model.table);
    return items.length;
  }
}
