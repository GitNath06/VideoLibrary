import 'package:get_storage/get_storage.dart';

class ProgressService {
  final _storage = GetStorage();
  final String _keyPrefix = "video_progress_";

  // Save progress (0.0 to 1.0)
  Future<void> saveProgress(String videoId, double progress) async {
    await _storage.write("$_keyPrefix$videoId", progress);
  }

  // Get progress (returns 0.0 if nothing saved yet)
  double getProgress(String videoId) {
    return _storage.read("$_keyPrefix$videoId") ?? 0.0;
  }

  // Clear all progress (optional)
  Future<void> clearAllProgress() async {
    await _storage.erase();
  }
}
