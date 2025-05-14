import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Match {
  final String id;
  final String team1;
  final String team2;
  final String date;
  final String prediction;
  String? userPrediction;
  final String? actualResult;
  double? winProbability;
  String? formattedDate;
  String? team1Logo;
  String? team2Logo;

  Match({
    required this.id,
    required this.team1,
    required this.team2,
    required this.date,
    required this.prediction,
    this.userPrediction,
    this.actualResult,
    this.winProbability,
    this.team1Logo,
    this.team2Logo,
  }) {
    formattedDate = _formatDate(date);
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('EEEE, d MMM', 'en_US').add_jm().format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'team1': team1,
    'team2': team2,
    'date': date,
    'prediction': prediction,
    'userPrediction': userPrediction,
    'actualResult': actualResult,
    'winProbability': winProbability,
    'team1Logo': team1Logo,
    'team2Logo': team2Logo,
  };

  factory Match.fromJson(Map<String, dynamic> json) => Match(
    id: json['id'],
    team1: json['team1'],
    team2: json['team2'],
    date: json['date'],
    prediction: json['prediction'],
    userPrediction: json['userPrediction'],
    actualResult: json['actualResult'],
    winProbability: json['winProbability']?.toDouble(),
    team1Logo: json['team1Logo'],
    team2Logo: json['team2Logo'],
  );
}

class PredictionModel with ChangeNotifier {
  List<Match> _matches = [];
  bool _isLoading = false;
  int _score = 0;
  DateTime? _lastFetchTime;
  List<Map<String, dynamic>> _predictionHistory = [];

  final String _apiHost = 'https://api.football-data.org/v4';
  final String _apiToken = '2cac3307c25f4d6e9f0385903648d1ea';

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  int get score => _score;
  List<Map<String, dynamic>> get predictionHistory => _predictionHistory;

  Map<String, List<Match>> get matchesByDay {
    Map<String, List<Match>> groupedMatches = {};
    for (var match in _matches) {
      String day = match.date.split('T')[0];
      if (!groupedMatches.containsKey(day)) groupedMatches[day] = [];
      groupedMatches[day]!.add(match);
    }
    return Map.fromEntries(
      groupedMatches.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  PredictionModel() {
    _loadPredictions();
    fetchMatches();
  }

  Future<void> _loadPredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? matchesJson = prefs.getString('matches');
    final String? historyJson = prefs.getString('prediction_history');
    final String? lastFetch = prefs.getString('last_fetch_time');

    if (matchesJson != null) {
      final List<dynamic> matchesData = jsonDecode(matchesJson);
      _matches = matchesData.map((data) => Match.fromJson(data)).toList();
      _score = prefs.getInt('score') ?? 0;
      if (lastFetch != null) {
        _lastFetchTime = DateTime.parse(lastFetch);
      }
    }

    if (historyJson != null) {
      final List<dynamic> historyData = jsonDecode(historyJson);
      _predictionHistory = historyData.cast<Map<String, dynamic>>();
    }

    notifyListeners();
  }

  Future<void> _savePredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = jsonEncode(
      _matches.map((match) => match.toJson()).toList(),
    );
    final historyJson = jsonEncode(_predictionHistory);
    await prefs.setString('matches', matchesJson);
    await prefs.setString('prediction_history', historyJson);
    await prefs.setInt('score', _score);
    await prefs.setString('last_fetch_time', DateTime.now().toIso8601String());
  }

  Future<void> fetchMatches({bool forceFetch = false}) async {
    if (!forceFetch && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inHours < 24) {
        _updateMatchesForWeek();
        return;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final dateFrom = DateFormat('yyyy-MM-dd').format(now);
      final dateTo = DateFormat(
        'yyyy-MM-dd',
      ).format(now.add(Duration(days: 7)));

      final response = await http.get(
        Uri.parse(
          '$_apiHost/matches?status=SCHEDULED&dateFrom=$dateFrom&dateTo=$dateTo',
        ),
        headers: {'X-Auth-Token': _apiToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesData = data['matches'];

        if (matchesData.isEmpty) {
          _matches = [
            Match(
              id: '1',
              team1: 'No matches',
              team2: 'found',
              date: 'N/A',
              prediction: '',
            ),
          ];
        } else {
          final newMatches =
              matchesData.map((match) {
                final homeTeam = match['homeTeam']['name'];
                final awayTeam = match['awayTeam']['name'];
                final matchDate = match['utcDate'];
                final id = match['id'].toString();
                final homeTeamLogo = match['homeTeam']['crest'];
                final awayTeamLogo = match['awayTeam']['crest'];
                final existingMatch = _matches.firstWhere(
                  (m) => m.id == id,
                  orElse:
                      () => Match(
                        id: '',
                        team1: '',
                        team2: '',
                        date: '',
                        prediction: '',
                      ),
                );
                return Match(
                  id: id,
                  team1: homeTeam,
                  team2: awayTeam,
                  date: matchDate,
                  prediction: homeTeam,
                  userPrediction: existingMatch.userPrediction,
                  winProbability: 0.5,
                  team1Logo: homeTeamLogo,
                  team2Logo: awayTeamLogo,
                );
              }).toList();

          _matches = newMatches.cast<Match>();
          _lastFetchTime = DateTime.now();
        }

        _updateMatchesForWeek();
        _updateScoreAutomatically();
        await _savePredictions();
      } else {
        _matches = [
          Match(
            id: '1',
            team1: 'Error',
            team2: 'Status ${response.statusCode}',
            date: 'N/A',
            prediction: '',
          ),
        ];
      }
    } catch (e) {
      _matches = [
        Match(
          id: '1',
          team1: 'Error',
          team2: e.toString(),
          date: 'N/A',
          prediction: '',
        ),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  void _updateMatchesForWeek() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final weekFromNow = now.add(Duration(days: 7));
    final weekFromNowFormatted = DateFormat('yyyy-MM-dd').format(weekFromNow);

    _matches.removeWhere((match) {
      final matchDay = match.date.split('T')[0];
      return matchDay.compareTo(today) < 0;
    });

    final currentDays = matchesByDay.keys.toList();
    if (currentDays.length < 7) {
      final lastDay = currentDays.isNotEmpty ? currentDays.last : today;
      final nextDay = DateTime.parse(lastDay).add(Duration(days: 1));
      final nextDayFormatted = DateFormat('yyyy-MM-dd').format(nextDay);
      _fetchAdditionalDay(nextDayFormatted, weekFromNowFormatted);
    }

    notifyListeners();
  }

  Future<void> _fetchAdditionalDay(String dateFrom, String dateTo) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_apiHost/matches?status=SCHEDULED&dateFrom=$dateFrom&dateTo=$dateTo',
        ),
        headers: {'X-Auth-Token': _apiToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesData = data['matches'];

        final newMatches =
            matchesData.map((match) {
              final homeTeam = match['homeTeam']['name'];
              final awayTeam = match['awayTeam']['name'];
              final matchDate = match['utcDate'];
              final id = match['id'].toString();
              final homeTeamLogo = match['homeTeam']['crest'];
              final awayTeamLogo = match['awayTeam']['crest'];
              final existingMatch = _matches.firstWhere(
                (m) => m.id == id,
                orElse:
                    () => Match(
                      id: '',
                      team1: '',
                      team2: '',
                      date: '',
                      prediction: '',
                    ),
              );
              return Match(
                id: id,
                team1: homeTeam,
                team2: awayTeam,
                date: matchDate,
                prediction: homeTeam,
                userPrediction: existingMatch.userPrediction,
                winProbability: 0.5,
                team1Logo: homeTeamLogo,
                team2Logo: awayTeamLogo,
              );
            }).toList();

        _matches.addAll(newMatches.cast<Match>());
        _updateScoreAutomatically();
        await _savePredictions();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> fetchFinishedMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_apiHost/matches?status=FINISHED'),
        headers: {'X-Auth-Token': _apiToken},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesData = data['matches'];

        for (var matchData in matchesData) {
          final matchId = matchData['id'].toString();
          final actualResult =
              matchData['score']['winner'] == 'HOME_TEAM'
                  ? matchData['homeTeam']['name']
                  : matchData['score']['winner'] == 'AWAY_TEAM'
                  ? matchData['awayTeam']['name']
                  : 'Draw';

          final matchIndex = _matches.indexWhere(
            (match) => match.id == matchId,
          );
          if (matchIndex >= 0) {
            _matches[matchIndex] = Match(
              id: _matches[matchIndex].id,
              team1: _matches[matchIndex].team1,
              team2: _matches[matchIndex].team2,
              date: _matches[matchIndex].date,
              prediction: _matches[matchIndex].prediction,
              userPrediction: _matches[matchIndex].userPrediction,
              actualResult: actualResult,
              winProbability: _matches[matchIndex].winProbability,
              team1Logo: _matches[matchIndex].team1Logo,
              team2Logo: _matches[matchIndex].team2Logo,
            );
          }
        }

        _updateScoreAutomatically();
        await _savePredictions();
      }
    } catch (e) {
      // Handle error silently
    }

    _isLoading = false;
    notifyListeners();
  }

  void updatePrediction(int index, String prediction) {
    _matches[index].userPrediction = prediction;

    final existingIndex = _predictionHistory.indexWhere(
      (item) => item['matchId'] == _matches[index].id,
    );

    final newHistoryItem = {
      'matchId': _matches[index].id,
      'team1': _matches[index].team1,
      'team2': _matches[index].team2,
      'date': _matches[index].date,
      'userPrediction': prediction,
      'appPrediction': _matches[index].prediction,
      'actualResult': _matches[index].actualResult,
      'correct': _matches[index].actualResult == prediction,
      'team1Logo': _matches[index].team1Logo,
      'team2Logo': _matches[index].team2Logo,
    };

    if (existingIndex >= 0) {
      _predictionHistory[existingIndex] = newHistoryItem;
    } else {
      _predictionHistory.add(newHistoryItem);
    }

    _updateScoreAutomatically();
    _savePredictions();
    notifyListeners();
  }

  void _updateScoreAutomatically() {
    int newScore = 0;
    for (var match in _matches) {
      if (match.userPrediction != null &&
          match.actualResult != null &&
          match.userPrediction == match.actualResult) {
        newScore += 3;
      }
    }

    _score = newScore;

    for (var historyItem in _predictionHistory) {
      final match = _matches.firstWhere(
        (m) => m.id == historyItem['matchId'],
        orElse:
            () => Match(id: '', team1: '', team2: '', date: '', prediction: ''),
      );
      if (match.actualResult != null) {
        historyItem['correct'] =
            historyItem['userPrediction'] == match.actualResult;
      }
    }

    _savePredictions();
    notifyListeners();
  }

  void updateScore(int index) {
    final match = _matches[index];
    if (match.userPrediction != null &&
        match.actualResult != null &&
        match.userPrediction == match.actualResult) {
      _score += 3;
    }
    _savePredictions();
    notifyListeners();
  }
}
