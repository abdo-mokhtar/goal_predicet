import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/prediction_model.dart';
import '../widgets/match_card.dart';
import 'score_screen.dart';
import 'profile_screen.dart';
import 'prediction_history_screen.dart';

class MatchesScreen extends StatefulWidget {
  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    _MatchesContent(),
    ScoreScreen(),
    PredictionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.sports_soccer, color: Colors.greenAccent, size: 28),
            const SizedBox(width: 10),
            Text(
              'GoalPredict',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Provider.of<PredictionModel>(
                context,
                listen: false,
              ).fetchFinishedMatches();
            },
            tooltip: 'Refresh Results',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              Provider.of<PredictionModel>(
                context,
                listen: false,
              ).fetchMatches(forceFetch: true);
            },
            tooltip: 'Refresh Matches',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: Colors.white12, height: 1),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
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
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                _pageController.jumpToPage(index);
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.greenAccent,
            unselectedItemColor: Colors.grey[500],
            selectedFontSize: 12,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_soccer),
                label: 'Matches',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_border),
                label: 'Score',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PredictionModel>(
      builder: (context, model, child) {
        if (model.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: model.matchesByDay.length,
                itemBuilder: (context, dayIndex) {
                  final day = model.matchesByDay.keys.elementAt(dayIndex);
                  final matches = model.matchesByDay[day]!;
                  final formattedDay = _formatDay(day);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        unselectedWidgetColor: Colors.white70,
                      ),
                      child: ExpansionTile(
                        iconColor: Colors.greenAccent,
                        collapsedIconColor: Colors.white,
                        childrenPadding: EdgeInsets.symmetric(vertical: 6),
                        title: Text(
                          formattedDay,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        children:
                            matches.map((match) {
                              final index = model.matches.indexOf(match);
                              return MatchCard(match: match, index: index);
                            }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDay(String day) {
    try {
      final parsedDate = DateTime.parse(day);
      return DateFormat('EEEE, d MMM').format(parsedDate);
    } catch (e) {
      return day;
    }
  }
}
