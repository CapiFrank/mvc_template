import 'package:mvc_template/controllers/user_controller.dart';
import 'package:mvc_template/views/user_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(create: (context) => UserController(), child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: UserView(),
      ),
    );
  }
}
