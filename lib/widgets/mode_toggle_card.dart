import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class ModeToggleCard extends StatelessWidget {
  final String currentMode;

  const ModeToggleCard({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context) {
    final isAutomatic = currentMode == 'AUTOMATIC';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greenPale,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.greenDeep.withValues(alpha:0.07),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MODE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.greenBright,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'AUTOMATIC',
                  label: Text('Automatic'),
                  icon: Icon(Icons.smart_toy_outlined),
                ),
                ButtonSegment(
                  value: 'MANUAL',
                  label: Text('Manual'),
                  icon: Icon(Icons.touch_app_outlined),
                ),
              ],
              selected: {currentMode},
              onSelectionChanged: (selection) {
                FirebaseService.setMode(selection.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.greenDeep;
                  }
                  return null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppTheme.greenMid;
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAutomatic
                ? 'AI controls all actuators'
                : 'Full manual control enabled',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.greenBright,
                ),
          ),
        ],
      ),
    );
  }
}
