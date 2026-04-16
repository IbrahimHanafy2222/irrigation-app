import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/detection_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section label
            Text(
              'Live sensors',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 10),

            // 2x2 sensor card grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio:
                  1.1, // Decreased from 1.4 to provide more vertical space
              children: [
                SensorCard(
                  label: 'Soil moisture',
                  stream: FirebaseService.soilMoisture,
                  unit: '%',
                  icon: Icons.water_drop_outlined,
                  iconColor: Colors.blue,
                ),
                SensorCard(
                  label: 'Temperature',
                  stream: FirebaseService.temperature,
                  unit: '°C',
                  icon: Icons.thermostat_outlined,
                  iconColor: Colors.orange,
                ),
                SensorCard(
                  label: 'Water level',
                  stream: FirebaseService.waterLevel,
                  unit: '%',
                  icon: Icons.water_outlined,
                  iconColor: Colors.teal,
                ),
                SensorCard(
                  label: 'Current draw',
                  stream: FirebaseService.current,
                  unit: 'A',
                  icon: Icons.bolt_outlined,
                  iconColor: Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // AI Detection section
            Text(
              'AI detection',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 10),
            const DetectionCard(),

            const SizedBox(height: 24),

            // Last updated indicator
            StreamBuilder<double>(
              stream: FirebaseService.temperature,
              builder: (context, snapshot) {
                return Text(
                  snapshot.connectionState == ConnectionState.waiting
                      ? 'Connecting to Firebase...'
                      : 'Live — updates every 5s',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
