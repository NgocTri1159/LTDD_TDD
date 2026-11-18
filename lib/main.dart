import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/admin_category_screen.dart'; 
import 'firebase_options.dart';
import 'views/quiz_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QuizMasterApp());
}

class QuizMasterApp extends StatelessWidget {
  const QuizMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizMaster Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Tạm thời trỏ thẳng vào màn hình Quản lý môn học để test
      home: QuizListScreen(), 
    );
  }
}