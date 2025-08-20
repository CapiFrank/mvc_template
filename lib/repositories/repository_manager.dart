// repository_manager.dart
import 'package:mvc_template/utils/model.dart';

import 'json_repository.dart';
import 'repository.dart';

class RepositoryManager {
  static final Map<String, Repository> _repositories = {};

  static Repository<T> get<T extends Model<T>>(
    String table,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (!_repositories.containsKey(table)) {
      _repositories[table] = JsonRepository<T>("db.json", fromJson);
    }
    return _repositories[table] as Repository<T>;
  }
}
