import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:running_mate/firebase_options.dart';
import 'package:running_mate/nav_page.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/profile/my_routes_page.dart';
import 'package:running_mate/screens/running/run_page.dart';
import 'viewmodels/auth_viewmodel.dart'; // AuthViewModel import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel()..loadCurrentUser(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const NavPage(),
          '/my-routes': (context) => MyRoutesPage(),
          '/login': (context) => LoginView(),
          '/run': (context) => const RunPage(),
        },
      ),
    );
  }
}
