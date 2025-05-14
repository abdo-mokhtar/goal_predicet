import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'matches_screen.dart';
import 'score_screen.dart';
import 'prediction_history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MatchesScreen(),
    ScoreScreen(),
    PredictionHistoryScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  final List<IconData> _icons = [
    Icons.sports_soccer,
    Icons.star_border,
    Icons.history,
    Icons.person_outline,
    Icons.settings,
  ];

  final List<String> _labels = [
    'Matches',
    'Score',
    'History',
    'Profile',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '⚽ GoalPredict',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.greenAccent,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () {
              // TODO: Add calendar action
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // TODO: Add profile/settings action
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,

      // ✅ هنا التغيير
      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.85),
              border: const Border(
                top: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.greenAccent,
              unselectedItemColor: Colors.grey[500],
              selectedFontSize: 12,
              unselectedFontSize: 11,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: List.generate(_icons.length, (index) {
                return BottomNavigationBarItem(
                  icon: Icon(_icons[index]),
                  label: _labels[index],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
