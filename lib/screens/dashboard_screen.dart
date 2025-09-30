import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/weight_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../controllers/app_settings_controller.dart';
import '../models/user_profile.dart';
import '../models/weight_entry.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  double _calculateMinY(List<WeightEntry> entries, double targetWeight) {
    if (entries.isEmpty) return 0;
    final minWeight = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final minValue = minWeight < targetWeight ? minWeight : targetWeight;
    return (minValue - 2).clamp(0, double.infinity);
  }

  double _calculateMaxY(List<WeightEntry> entries, double targetWeight) {
    if (entries.isEmpty) return 0;
    final maxWeight = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final maxValue = maxWeight > targetWeight ? maxWeight : targetWeight;
    return maxValue + 2;
  }

  @override
  Widget build(BuildContext context) {
    final weightController = Get.find<WeightController>();
    final userProfileController = Get.find<UserProfileController>();
    final appSettingsController = Get.find<AppSettingsController>();

    final primary = appSettingsController.appSettings.value.primaryColor;

    return Scaffold(
      // Custom header like mock (no standard AppBar)
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() {
              final latest = weightController.latestEntry;
              final change = weightController.weightChange;
              final unit = userProfileController.userProfile.value.unit == WeightUnit.kg ? "kg" : "lb";
              final lastLogged = latest != null
                  ? 'Last Logged: ${DateFormat('MMM d, h:mm a').format(latest.dateTime)}'
                  : 'No entries yet';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'WeightWise',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        latest != null ? '${latest.weight.toStringAsFixed(1)} $unit' : '--',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (change != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    change < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${change > 0 ? "+" : ""}${change.toStringAsFixed(1)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 12),
                          Text(
                            lastLogged,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            // BMI Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final profile = userProfileController.userProfile.value;
                final latest = weightController.latestEntry;
                double? bmi;
                String category = '';
                Color tagColor = Colors.blue;
                if (latest != null && profile.height > 0) {
                  final heightM = profile.height / 100;
                  bmi = latest.weight / (heightM * heightM);
                  if (bmi < 18.5) {
                    category = 'Underweight';
                    tagColor = Colors.blue;
                  } else if (bmi < 25) {
                    category = 'Normal Weight';
                    tagColor = Colors.green;
                  } else if (bmi < 30) {
                    category = 'Overweight';
                    tagColor = Colors.orange;
                  } else {
                    category = 'Obese';
                    tagColor = Colors.red;
                  }
                }
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      'BMI: ${bmi != null ? bmi.toStringAsFixed(1) : "--"}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      category.isNotEmpty ? category : 'Set height to calculate BMI',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category.isNotEmpty ? category : '--',
                        style: TextStyle(
                          color: tagColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            // Target Weight Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final profile = userProfileController.userProfile.value;
                final latest = weightController.latestEntry;
                final away = latest != null ? (latest.weight - profile.targetWeight) : null;
                final unit = profile.unit == WeightUnit.kg ? "kg" : "lb";
                final text = away != null
                    ? 'You are ${away.abs().toStringAsFixed(1)} ${unit} ${away > 0 ? "above" : "away from"} your goal!'
                    : 'Set your target weight in Settings.';
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      'Target: ${profile.targetWeight.toStringAsFixed(1)} $unit',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(text),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            // Mini Chart Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final entries = weightController.getEntriesForLastDays(30);
                final profile = userProfileController.userProfile.value;
                if (entries.isEmpty) {
                  return Card(
                    child: SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'No weight data for the last 30 days',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last 30 Days', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 140,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: const FlTitlesData(
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                // Target weight (dotted) drawn at absolute Y value:
                                if (profile.targetWeight > 0)
                                  LineChartBarData(
                                    spots: [
                                      FlSpot(0, profile.targetWeight),
                                      FlSpot((entries.length - 1).toDouble(), profile.targetWeight),
                                    ],
                                    isCurved: false,
                                    color: Colors.grey.withOpacity(0.6),
                                    barWidth: 1,
                                    dashArray: const [5, 5],
                                    belowBarData: BarAreaData(show: false),
                                    dotData: const FlDotData(show: false),
                                  ),
                                LineChartBarData(
                                  spots: entries.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final weightEntry = entry.value;
                                    return FlSpot(index.toDouble(), weightEntry.weight);
                                  }).toList(),
                                  isCurved: true,
                                  color: primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 3,
                                        color: primary,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ],
                              minY: _calculateMinY(entries, profile.targetWeight),
                              maxY: _calculateMaxY(entries, profile.targetWeight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          final unit = userProfileController.userProfile.value.unit == WeightUnit.kg ? "kg" : "lb";
          final result = await showDialog<double>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log New Weight'),
              content: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight ($unit)',
                  hintText: 'Enter your weight',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text);
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    }
                  },
                  child: const Text('Log'),
                ),
              ],
            ),
          );
          if (result != null) {
            weightController.addWeightEntry(
              WeightEntry(
                dateTime: DateTime.now(),
                weight: result,
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
