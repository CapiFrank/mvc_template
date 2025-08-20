import 'package:mvc_template/utils/model.dart';

class User extends Model<User> {
  @override
  String get table => "users";

  String name;
  String email;

  User({super.id, this.name = "", this.email = ""});

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };

  @override
  User fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: json["name"], email: json["email"]);
}
