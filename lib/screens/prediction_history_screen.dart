import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/prediction_model.dart';

class PredictionHistoryScreen extends StatelessWidget {
  const PredictionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<PredictionModel>(context);

    // تهيئة تاريخ اليوم
    final dateFormat = DateFormat('dd MMM yyyy hh:mm a'); // تنسيق التاريخ

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body:
          model.predictionHistory.isEmpty
              ? Center(
                child: Text(
                  'No prediction history yet.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: model.predictionHistory.length,
                itemBuilder: (context, index) {
                  final historyItem = model.predictionHistory[index];
                  final formattedDate =
                      DateTime.tryParse(historyItem['date']) != null
                          ? dateFormat.format(
                            DateTime.parse(historyItem['date']),
                          )
                          : historyItem['date'];

                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${historyItem['team1']} vs ${historyItem['team2']}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date: $formattedDate',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Your Prediction: ${historyItem['userPrediction']}',
                            style: GoogleFonts.poppins(
                              color: Colors.lightBlueAccent,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'App Prediction: ${historyItem['appPrediction']}',
                            style: GoogleFonts.poppins(
                              color: Colors.yellowAccent,
                              fontSize: 12,
                            ),
                          ),
                          if (historyItem['actualResult'] != null)
                            Text(
                              'Actual Result: ${historyItem['actualResult']}',
                              style: GoogleFonts.poppins(
                                color: Colors.greenAccent,
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            'Correct: ${historyItem['correct'] ? 'Yes' : 'No'}',
                            style: GoogleFonts.poppins(
                              color:
                                  historyItem['correct']
                                      ? Colors.green
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
