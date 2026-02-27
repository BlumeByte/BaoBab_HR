import 'dart:math' as math;

import 'package:flutter/material.dart';

class StatItem {
  const StatItem(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class PieSliceData {
  const PieSliceData({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;
}

class ModuleScreenScaffold extends StatelessWidget {
  const ModuleScreenScaffold({
    super.key,
    required this.title,
    required this.description,
    this.stats = const [],
    this.pieData = const [],
    this.highlights = const [],
    this.primaryAction,
  });

  final String title;
  final String description;
  final List<StatItem> stats;
  final List<PieSliceData> pieData;
  final List<String> highlights;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(description),
                  ],
                ),
              ),
              if (primaryAction != null) primaryAction!,
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stats
                  .map(
                    (item) => SizedBox(
                      width: 220,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(item.icon),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.value, style: Theme.of(context).textTheme.titleLarge),
                                  Text(item.label),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (pieData.isNotEmpty || highlights.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pieData.isNotEmpty)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Distribution', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            SizedBox(height: 220, child: _SimplePieChart(data: pieData)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (pieData.isNotEmpty && highlights.isNotEmpty) const SizedBox(width: 12),
                if (highlights.isNotEmpty)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Highlights', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            ...highlights.map(
                              (text) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.check_circle_outline),
                                title: Text(text),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SimplePieChart extends StatelessWidget {
  const _SimplePieChart({required this.data});

  final List<PieSliceData> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, slice) => sum + slice.value);
    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _PieChartPainter(data: data, total: total),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data
                .map(
                  (slice) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, color: slice.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${slice.label} (${((slice.value / total) * 100).toStringAsFixed(0)}%)'),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({required this.data, required this.total});

  final List<PieSliceData> data;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.4;
    var start = -math.pi / 2;

    for (final slice in data) {
      final sweep = (slice.value / total) * (2 * math.pi);
      final paint = Paint()..color = slice.color;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, true, paint);
      start += sweep;
    }

    canvas.drawCircle(center, radius * 0.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => oldDelegate.data != data;
}
