import 'package:mvc_template/utils/controller.dart';

import 'package:mvc_template/models/user.dart';
import 'package:mvc_template/utils/utilities.dart';

class UserController extends Controller{
  final List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  Future<void> index() async {
    setLoading(true);
    try {
      _users.clear();
      _users.addAll(await User().all());
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> store({
    required String id,
    required String name,
    required String email,
  }) async {
    setLoading(true);
    try {
      final user = User(id: id, name: toTitleCase(name), email: email);
      await user.create();
      _users.insert(0, user);
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> update({
    required String id,
    String name = "",
    String email = "",
  }) async {
    setLoading(true);
    try {
      final user = await User(id: id).find();
      if (user == null) {
        throw Exception("⚠️ User with id $id not found");
      }
      if (name.isNotEmpty) user.name = toTitleCase(name);
      if (email.isNotEmpty) user.email = email;
      await user.update();

      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        _users[index] = user;
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
      final user = User(id: id);
      await user.delete();
      _users.removeWhere((u) => u.id == id);
    } catch (e) {
      handleError(e);
    } finally {
      setLoading(false);
    }
  }
}
