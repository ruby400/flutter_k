import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WebViewPlatform.instance;
  try {
    await dotenv.load(fileName: 'assets/.env');
    if (dotenv.env['NAVER_CLIENT_ID'] == null ||
        dotenv.env['NAVER_CLIENT_SECRET'] == null ||
        dotenv.env['VWORLD_API_KEY'] == null) {
      throw Exception('API 키 누락');
    }
  } catch (e) {
    runApp(ErrorApp(error: 'Failed to load .env: $e'));
    return;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '장소 검색 앱',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Center(child: Text(error))));
  }
}
