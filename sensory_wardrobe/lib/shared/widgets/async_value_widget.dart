import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

/// A generic wrapper that handles loading / error / data states for any
/// [AsyncValue<T>], reducing boilerplate in every screen that uses Riverpod.
///
/// Usage:
/// ```dart
/// AsyncValueWidget<List<ClothingItemModel>>(
///   value: ref.watch(wardrobeItemsProvider),
///   data: (items) => WardrobeList(items: items),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loadingWidget;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          ),
      error: (error, _) => _ErrorView(message: error.toString()),
      data: data,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMid,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Slim loading overlay, useful for mutations (save, backup, etc.)
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x55000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
