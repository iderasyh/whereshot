import 'package:flutter/material.dart';
import 'package:whereshot/models/detection_result.dart';
import 'package:whereshot/theme/app_theme.dart';
import 'package:whereshot/widgets/detection_card.dart';

class HistoryList extends StatelessWidget {
  final List<DetectionResult> history;
  final Function(DetectionResult)? onDelete;
  final Function(DetectionResult)? onTap;
  
  const HistoryList({
    super.key,
    required this.history,
    this.onDelete,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.m),
          child: GestureDetector(
            onTap: onTap != null ? () => onTap!(item) : null,
            child: DetectionCard(
              detection: item,
              onDelete: onDelete != null ? () => onDelete!(item) : null,
            ),
          ),
        );
      },
    );
  }
} 