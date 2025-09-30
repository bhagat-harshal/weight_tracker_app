import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/weight_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../controllers/app_settings_controller.dart';
import '../models/weight_entry.dart';
import '../models/user_profile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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

    // Filter options (segmented)
    final filters = [
      {'label': '1W', 'days': 7},
      {'label': '1M', 'days': 30},
      {'label': '3M', 'days': 90},
      {'label': '6M', 'days': 180},
      {'label': '1Y', 'days': 365},
      {'label': 'All Time', 'days': null},
    ];
    final RxInt selectedFilter = 5.obs; // Default to "All Time"

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chart card
            Obx(() {
              List<WeightEntry> entries;
              final filter = filters[selectedFilter.value];
              if (filter['days'] != null) {
                entries = weightController.getEntriesForLastDays(filter['days'] as int);
              } else {
                entries = weightController.weightEntries;
              }
              final profile = userProfileController.userProfile.value;
              final primary = appSettingsController.appSettings.value.primaryColor;

              if (entries.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(filters[selectedFilter.value]['label'] as String, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: Center(
                            child: Text(
                              'No weight data available',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(filters.length, (i) {
                            final selected = selectedFilter.value == i;
                            final color = appSettingsController.appSettings.value.primaryColor;
                            return GestureDetector(
                              onTap: () => selectedFilter.value = i,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    filters[i]['label'] as String,
                                    style: TextStyle(
                                      color: selected ? color : const Color(0xFF6B7280),
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 2,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: selected ? color : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Sort by date ascending for chart
              entries = List.from(entries)..sort((a, b) => a.dateTime.compareTo(b.dateTime));

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(filters[selectedFilter.value]['label'] as String, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
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
                              // Target weight dashed line
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
                              // Actual weight line with light area fill
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
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: primary.withOpacity(0.08),
                                ),
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
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(filters.length, (i) {
                          final selected = selectedFilter.value == i;
                          final color = appSettingsController.appSettings.value.primaryColor;
                          return GestureDetector(
                            onTap: () => selectedFilter.value = i,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  filters[i]['label'] as String,
                                  style: TextStyle(
                                    color: selected ? color : const Color(0xFF6B7280),
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 2,
                                  width: 28,
                                  decoration: BoxDecoration(
                                    color: selected ? color : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Lowest recorded mini-card
            Obx(() {
              final lowest = weightController.lowestWeight;
              final unit = userProfileController.userProfile.value.unit == WeightUnit.kg ? "kg" : "lb";
              if (lowest == null) return const SizedBox.shrink();
              return Card(
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    'Lowest Recorded: ${lowest.toStringAsFixed(1)} $unit',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Weight logs list
            Expanded(
              child: Obx(() {
                List<WeightEntry> entries;
                final filter = filters[selectedFilter.value];
                if (filter['days'] != null) {
                  entries = weightController.getEntriesForLastDays(filter['days'] as int);
                } else {
                  entries = weightController.weightEntries;
                }
                entries = List.from(entries)..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                final lowest = weightController.lowestWeight;

                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor),
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    final prev = i < entries.length - 1 ? entries[i + 1] : null;
                    final change = prev != null ? entry.weight - prev.weight : 0.0;
                    final isLowest = lowest != null && entry.weight == lowest;

                    return GestureDetector(
                      onLongPress: () {
                        _showEditDialog(context, entry, weightController, userProfileController);
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: isLowest ? Colors.green.withOpacity(0.12) : const Color(0xFFEFF3F8),
                          child: Icon(
                            isLowest ? Icons.star : Icons.fitness_center,
                            color: isLowest ? Colors.green : Colors.black54,
                          ),
                        ),
                        title: Text(
                          '${entry.weight.toStringAsFixed(1)} ${userProfileController.userProfile.value.unit == WeightUnit.kg ? "kg" : "lb"}',
                          style: TextStyle(
                            fontWeight: isLowest ? FontWeight.w700 : FontWeight.w500,
                            color: isLowest ? Colors.green[800] : null,
                          ),
                        ),
                        subtitle: Text(DateFormat('MMM d, yyyy – h a').format(entry.dateTime)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (prev != null)
                              Icon(
                                change < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                                color: change < 0 ? Colors.green : Colors.red,
                                size: 18,
                              ),
                            if (prev != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Text(
                                  '${change > 0 ? "+" : ""}${change.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: change < 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditDialog(context, entry, weightController, userProfileController);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, entry, weightController);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WeightEntry entry, WeightController weightController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: Text('Are you sure you want to delete the weight entry from ${DateFormat('MMM d, yyyy').format(entry.dateTime)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              weightController.deleteWeightEntry(entry);
              Navigator.of(context).pop();
              Get.snackbar(
                'Deleted',
                'Weight entry has been deleted',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WeightEntry entry, WeightController weightCtrl, UserProfileController userProfileController) {
    final weightController = TextEditingController(text: entry.weight.toStringAsFixed(1));
    DateTime selectedDate = entry.dateTime;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(entry.dateTime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Weight Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (${userProfileController.userProfile.value.unit == WeightUnit.kg ? "kg" : "lb"})',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        child: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                        child: Text(selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newWeight = double.tryParse(weightController.text);
                  if (newWeight != null && newWeight > 0) {
                    final newDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    final newEntry = WeightEntry(
                      dateTime: newDateTime,
                      weight: newWeight,
                    );
                    weightCtrl.updateWeightEntry(entry, newEntry);
                    Navigator.of(context).pop();
                    Get.snackbar(
                      'Updated',
                      'Weight entry has been updated',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter a valid weight',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
