import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/prediction_model.dart';

class PredictionScreen extends StatefulWidget {
  final Match match;
  final int index;

  const PredictionScreen({Key? key, required this.match, required this.index})
    : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String? _selectedPrediction;

  @override
  void initState() {
    super.initState();
    _selectedPrediction = widget.match.userPrediction;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Predict Match',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.match.team1} vs ${widget.match.team2}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.match.formattedDate ?? widget.match.date,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              'Select your prediction:',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildPredictionOption(widget.match.team1),
            const SizedBox(height: 12),
            _buildPredictionOption(widget.match.team2),
            const SizedBox(height: 12),
            _buildPredictionOption('Draw'),
            const SizedBox(height: 24),
            if (_selectedPrediction != null)
              Text(
                'You selected: $_selectedPrediction',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.greenAccent,
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed:
                    _selectedPrediction != null
                        ? () {
                          Provider.of<PredictionModel>(
                            context,
                            listen: false,
                          ).updatePrediction(
                            widget.index,
                            _selectedPrediction!,
                          );
                          Navigator.pop(context);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedPrediction == widget.match.userPrediction
                      ? 'Update Prediction'
                      : 'Make Prediction',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionOption(String option) {
    final isSelected = _selectedPrediction == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrediction = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.greenAccent.withOpacity(0.2)
                  : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
