import 'package:mvc_template/controllers/user_controller.dart';
import 'package:mvc_template/views/components/info_card.dart';
import 'package:mvc_template/views/layouts/scroll_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mvc_template/utils/utilities.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  UserViewState createState() => UserViewState();
}

class UserViewState extends State<UserView> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserController>().index();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserController userController = context.watch<UserController>();
    final userList = userController.users;
    if (userController.isLoading) return loadingProgress();
    return ScrollLayout(
      toolbarHeight: 280,
      isEmpty: userList.isEmpty,
      showEmptyMessage: true,
      bodyChild: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final user = userList[index];
          return InfoCard(title: Text(user.name), children: [Text(user.email)]);
        }, childCount: userList.length),
      ),
    );
  }
}
