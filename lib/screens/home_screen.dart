import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickStats(),
                const SizedBox(height: 24),
                Text(
                  'How it works',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  context,
                  '🌿',
                  'AI plant monitoring',
                  'A camera and MobileNetV2 model scan your plants continuously, '
                      'detecting disease, pests, and nutrient deficiency before they spread.',
                ),
                _buildInfoCard(
                  context,
                  '💧',
                  'Precision irrigation',
                  'An X-Y gantry delivers water exactly where needed. AI detections '
                      'trigger targeted protocols automatically — no human input required.',
                ),
                _buildInfoCard(
                  context,
                  '🛡',
                  'Safety-first control',
                  'Four safety features protect against dry-run, overwatering, overcurrent, '
                      'and overheating. Safety always overrides AI and manual commands.',
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      color: AppTheme.greenDeep,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SMART IRRIGATION SYSTEM',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.greenLight,
                  letterSpacing: 0.12,
                ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: Colors.white),
              children: const [
                TextSpan(text: 'Growing smarter,\n'),
                TextSpan(
                  text: 'wasting less.',
                  style: TextStyle(
                    color: Color(0xFF7dcca0),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'AI-powered precision irrigation that monitors, decides, and acts — '
            'so your crops thrive with every drop.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha:0.6),
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.greenBright.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.greenLight.withValues(alpha:0.4),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.greenLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'System online — all sensors active',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.greenLight,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      ('4', 'Live sensors'),
      ('94%', 'AI confidence'),
      ('4', 'Safety checks'),
      ('2s', 'Control latency'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio:
          1.8, // Decreased ratio to give the cards more vertical space
      children: stats
          .map(
            (s) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.greenDeep.withValues(alpha:0.07),
                  width: 0.5,
                ),
              ),
              child: FittedBox(
                // Added FittedBox to gracefully scale text down if it's slightly too big
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.$1,
                        style: const TextStyle(
                          fontFamily: 'DMSerifDisplay',
                          fontSize: 26,
                          color: AppTheme.greenMid,
                        ),
                      ),
                      Text(
                        s.$2,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.greenBright,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInfoCard(
    BuildContext ctx,
    String emoji,
    String title,
    String body,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.greenDeep.withValues(alpha:0.07),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.greenPale,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0a1a10),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7a9a84),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
