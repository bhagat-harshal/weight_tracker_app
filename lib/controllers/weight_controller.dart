import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/weight_entry.dart';

class WeightController extends GetxController {
  var weightEntries = <WeightEntry>[].obs;
  final _storage = GetStorage();
  final _storageKey = 'weight_entries';

  @override
  void onInit() {
    super.onInit();
    _loadWeightEntries();
  }

  void _loadWeightEntries() {
    final stored = _storage.read<List>(_storageKey);
    if (stored != null) {
      weightEntries.value = stored.map((item) => WeightEntry.fromMap(item)).toList();
      weightEntries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }
  }

  void _saveWeightEntries() {
    final entriesMap = weightEntries.map((entry) => entry.toMap()).toList();
    _storage.write(_storageKey, entriesMap);
  }

  // Add a new weight entry
  void addWeightEntry(WeightEntry entry) {
    weightEntries.add(entry);
    weightEntries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _saveWeightEntries();
    update();
  }

  // Get the latest weight entry
  WeightEntry? get latestEntry =>
      weightEntries.isNotEmpty ? weightEntries.last : null;

  // Get the previous weight entry (before the latest)
  WeightEntry? get previousEntry =>
      weightEntries.length > 1 ? weightEntries[weightEntries.length - 2] : null;

  // Get weight change since last entry
  double? get weightChange {
    if (latestEntry != null && previousEntry != null) {
      return latestEntry!.weight - previousEntry!.weight;
    }
    return null;
  }

  // Get weight entries for the last N days
  List<WeightEntry> getEntriesForLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return weightEntries.where((e) => e.dateTime.isAfter(cutoff)).toList();
  }

  // Get lowest recorded weight
  double? get lowestWeight =>
      weightEntries.isNotEmpty
          ? weightEntries.map((e) => e.weight).reduce((a, b) => a < b ? a : b)
          : null;

  // Delete a weight entry
  void deleteWeightEntry(WeightEntry entry) {
    weightEntries.remove(entry);
    _saveWeightEntries();
    update();
  }

  // Update a weight entry
  void updateWeightEntry(WeightEntry oldEntry, WeightEntry newEntry) {
    final index = weightEntries.indexOf(oldEntry);
    if (index != -1) {
      weightEntries[index] = newEntry;
      weightEntries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _saveWeightEntries();
      update();
    }
  }

  // Reset all weight data
  void reset() {
    weightEntries.clear();
    _saveWeightEntries();
    update();
  }
}
