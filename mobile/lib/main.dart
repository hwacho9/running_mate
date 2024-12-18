import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:running_mate/firebase_options.dart';
import 'package:running_mate/nav_page.dart';
import 'package:running_mate/provider/running_status_provider.dart';
import 'package:running_mate/screens/auth/login_view.dart';
import 'package:running_mate/screens/tracks/my_tracks_view.dart';
import 'package:running_mate/screens/running/run_view.dart';
import 'package:running_mate/screens/running/running_result_view.dart';
import 'package:running_mate/services/track_service.dart';
import 'package:running_mate/services/user_record_service.dart';
import 'package:running_mate/services/user_service.dart';
import 'package:running_mate/services/user_stats_service.dart';
import 'package:running_mate/viewmodels/home_view_model.dart';
import 'package:running_mate/viewmodels/my_tracks_view_model.dart';
import 'package:running_mate/viewmodels/profile_view_model.dart';
import 'package:running_mate/viewmodels/run_view_model.dart';
import 'package:running_mate/viewmodels/running_result_view_model.dart';
import 'package:running_mate/viewmodels/running_view_model.dart';
import 'package:running_mate/viewmodels/track_edit_view_model.dart';
import 'viewmodels/auth_view_model.dart'; // AuthViewModel import

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
        ChangeNotifierProvider(
          create: (_) => RunningStatusProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RunViewModel(Trackservice()),
        ),
        ChangeNotifierProvider(
          create: (_) => MyTracksViewModel(
            Trackservice(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RunningViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              RunningResultViewModel(UserRecordService(), Trackservice()),
          child: RunningResultView(
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            coordinates: const [],
            totalDistance: 0.0,
            pauseTime: const Duration(seconds: 0),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            UserStatsService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TrackEditViewModel(
            Trackservice(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            UserService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const NavPage(),
          '/my-routes': (context) => const MyTracksView(),
          '/login': (context) => LoginView(),
          '/run': (context) => const RunView(),
        },
      ),
    );
  }
}
