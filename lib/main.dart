import 'package:flutter/material.dart';
import 'package:goal_predicet/screens/prediction_history_screen.dart';
import 'package:goal_predicet/screens/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen .dart';
import 'screens/matches_screen.dart';
import 'screens/score_screen.dart';
import 'screens/profile_screen.dart';
import 'models/prediction_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PredictionModel>(
          create: (context) => PredictionModel(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'GoalPredict',
          theme: themeProvider.themeData,
          initialRoute: isLoggedIn ? '/matches' : '/loginscreen',
          routes: {
            '/loginscreen': (context) => LoginScreen(),
            '/matches': (context) => MatchesScreen(),
            '/score': (context) => ScoreScreen(),
            '/profile': (context) => ProfileScreen(),
            '/history': (context) => PredictionHistoryScreen(),
          },
        );
      },
    );
  }
}
