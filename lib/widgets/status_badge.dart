import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key});

  Color _colorForState(String state, BuildContext context) {
    switch (state) {
      case 'WARNING':
        return Colors.orange;
      case 'FAULT':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  IconData _iconForState(String state) {
    switch (state) {
      case 'WARNING':
        return Icons.warning_amber_rounded;
      case 'FAULT':
        return Icons.error_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: FirebaseService.systemState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? 'NORMAL';
        final color = _colorForState(state, context);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha:0.4), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconForState(state), size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                state,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
