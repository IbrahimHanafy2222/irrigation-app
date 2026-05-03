import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorCard extends StatefulWidget {
  final String label;
  final Stream<double> stream;
  final String unit;
  final IconData icon;
  final Color iconColor;

  const SensorCard({
    super.key,
    required this.label,
    required this.stream,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<SensorCard> createState() => _SensorCardState();
}

class _SensorCardState extends State<SensorCard> {
  final List<double> _history = [];
  double? _currentValue;
  StreamSubscription<double>? _sub;
  static const int _maxHistory = 20;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen((value) {
      setState(() {
        _currentValue = value;
        _history.add(value);
        if (_history.length > _maxHistory) _history.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 14, color: widget.iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _currentValue == null
              ? const Text('—', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currentValue!.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        widget.unit,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: _history.length < 2
                ? const SizedBox.shrink()
                : LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            _history.length,
                            (i) => FlSpot(i.toDouble(), _history[i]),
                          ),
                          isCurved: true,
                          color: widget.iconColor,
                          barWidth: 1.5,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, barData) =>
                                spot == barData.spots.last,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: widget.iconColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
