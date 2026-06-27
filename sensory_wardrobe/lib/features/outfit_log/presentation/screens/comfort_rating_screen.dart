import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

/// P4.0 — Post-wear comfort rating (1–5, with sub-scores for texture/pressure/temperature).
class ComfortRatingScreen extends ConsumerStatefulWidget {
  const ComfortRatingScreen({super.key});

  @override
  ConsumerState<ComfortRatingScreen> createState() =>
      _ComfortRatingScreenState();
}

class _ComfortRatingScreenState extends ConsumerState<ComfortRatingScreen> {
  int _overallScore = 3;
  int _textureScore = 3;
  int _pressureScore = 3;
  int _temperatureScore = 3;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color _scoreColor(int score) {
    switch (score) {
      case 1:
        return AppColors.comfortVeryLow;
      case 2:
        return AppColors.comfortLow;
      case 3:
        return AppColors.comfortMid;
      case 4:
        return AppColors.comfortHigh;
      case 5:
        return AppColors.comfortVeryHigh;
      default:
        return AppColors.textMid;
    }
  }

  Widget _buildScoreRow(
      String label, int score, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label)),
        Expanded(
          child: Slider(
            value: score.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: _scoreColor(score),
            label: score.toString(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            score.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _scoreColor(score),
            ),
          ),
        ),
      ],
    );
  }

  void _saveRating() {
    // TODO: dispatch comfort rating to provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Comfort')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How did today\'s outfit feel?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            _buildScoreRow(
              'Overall Comfort',
              _overallScore,
              (v) => setState(() => _overallScore = v),
            ),
            const Divider(),
            _buildScoreRow(
              'Texture',
              _textureScore,
              (v) => setState(() => _textureScore = v),
            ),
            _buildScoreRow(
              'Pressure / Fit',
              _pressureScore,
              (v) => setState(() => _pressureScore = v),
            ),
            _buildScoreRow(
              'Temperature',
              _temperatureScore,
              (v) => setState(() => _temperatureScore = v),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'What felt uncomfortable? What worked well?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRating,
                child: const Text('Save Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
