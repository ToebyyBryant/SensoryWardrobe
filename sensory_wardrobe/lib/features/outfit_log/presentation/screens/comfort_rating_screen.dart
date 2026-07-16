import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/outfit_log_providers.dart';
import '../../data/models/comfort_rating_model.dart';

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
  bool _isSaving = false;

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

  Future<void> _saveRating() async {
    final profile = ref.read(activeProfileProvider);
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in required.')),
      );
      return;
    }

    final logs = ref.read(outfitLogsProvider).valueOrNull ?? [];
    final logIdFromQuery = GoRouterState.of(context).uri.queryParameters['logId'];

    String? outfitLogId = logIdFromQuery;
    if (outfitLogId == null && logs.isNotEmpty) {
      outfitLogId = logs.first.id;
    }

    if (outfitLogId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log an outfit before rating comfort.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final rating = ComfortRatingModel(
        id: now.microsecondsSinceEpoch.toString(),
        outfitLogId: outfitLogId,
        userId: profile.id,
        overallScore: _overallScore,
        textureScore: _textureScore,
        pressureScore: _pressureScore,
        temperatureScore: _temperatureScore,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        ratedAt: now,
      );

      await ref.read(comfortRatingsProvider.notifier).saveRating(rating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comfort rating saved.')),
        );
        context.go('/history');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save rating: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                onPressed: _isSaving ? null : _saveRating,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
