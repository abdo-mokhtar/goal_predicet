import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prediction_model.dart'; // استيراد PredictionModel

class ProfileScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/loginscreen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Consumer<PredictionModel>(
          builder: (context, model, child) {
            // حساب عدد التوقعات الصحيحة وإجمالي التوقعات
            final predictionHistory = model.predictionHistory;
            final totalPredictions = predictionHistory.length;
            final correctPredictions =
                predictionHistory
                    .where((prediction) => prediction['correct'] == true)
                    .length;
            // حساب الـ Accuracy
            final accuracy =
                totalPredictions > 0
                    ? (correctPredictions / totalPredictions * 100)
                        .toStringAsFixed(1)
                    : '0.0';

            return Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green[600],
                  child: Text(
                    'U',
                    style: TextStyle(
                      fontSize: 45,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 25),
                Card(
                  color: Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.bar_chart,
                            color: Colors.greenAccent,
                          ),
                          title: Text(
                            'Accuracy',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Text(
                            '$accuracy%',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Divider(color: Colors.grey[700]),
                        ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          ),
                          title: Text(
                            'Correct Predictions',
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Text(
                            '$correctPredictions/$totalPredictions',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
