import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class DetectionCard extends StatelessWidget {
  const DetectionCard({super.key});

  Color _colorForConfidence(double confidence) {
    if (confidence >= 0.80) return Colors.green;
    if (confidence >= 0.60) return Colors.orange;
    return Colors.red;
  }

  Color _colorForClass(String className) {
    switch (className) {
      case 'Healthy':
        return Colors.green;
      case 'Early_Blight':
        return Colors.orange;
      case 'Late_Blight':
        return Colors.red;
      case 'Pest':
        return Colors.purple;
      case 'Nutrient_Deficiency':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService.latestDetection,
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final className = data['class']?.toString() ?? 'No detection yet';
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
        final classColor = _colorForClass(className);
        final confColor = _colorForConfidence(confidence);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha:0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest AI detection',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: classColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    className,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${(confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: confColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confidence,
                        backgroundColor: confColor.withValues(alpha:0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(confColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
