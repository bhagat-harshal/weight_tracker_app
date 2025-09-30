import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_profile.dart';

class UserProfileController extends GetxController {
  var userProfile = UserProfile(
    name: '',
    height: 170.0,
    targetWeight: 70.0,
    unit: WeightUnit.kg,
  ).obs;
  final _storage = GetStorage();
  final _storageKey = 'user_profile';

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final stored = _storage.read<Map<String, dynamic>>(_storageKey);
    if (stored != null) {
      userProfile.value = UserProfile.fromMap(stored);
    }
  }

  void _saveUserProfile() {
    _storage.write(_storageKey, userProfile.value.toMap());
  }

  void updateName(String name) {
    userProfile.update((val) {
      if (val != null) val.name = name;
    });
    _saveUserProfile();
  }

  void updateHeight(double height) {
    userProfile.update((val) {
      if (val != null) val.height = height;
    });
    _saveUserProfile();
  }

  void updateTargetWeight(double targetWeight) {
    userProfile.update((val) {
      if (val != null) val.targetWeight = targetWeight;
    });
    _saveUserProfile();
  }

  void updateUnit(WeightUnit unit) {
    userProfile.update((val) {
      if (val != null) val.unit = unit;
    });
    _saveUserProfile();
  }

  void reset() {
    userProfile.value = UserProfile(
      name: '',
      height: 170.0,
      targetWeight: 70.0,
      unit: WeightUnit.kg,
    );
    _saveUserProfile();
  }
}
