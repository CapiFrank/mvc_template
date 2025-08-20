abstract class Repository<T> {
  Future<List<T>> all(T model);
  Future<T?> find(T model);
  Future<List<T>> where(bool Function(T) where, T model);
  Future<T?> firstWhere(bool Function(T) where, T model);
  Future<bool> exists(bool Function(T) where, T model);
  Future<List<T>> orderBy(
    Comparable Function(T) key,
    T model, {
    bool descending = false,
  });
  Future<List<T>> limit(int count, T model);
  Future<int> count(T model);

  void create(T item);
  Future<void> update(String id, T newItem);
  Future<void> delete(String id, T model);
}
