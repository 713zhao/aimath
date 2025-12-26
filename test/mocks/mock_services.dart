import 'package:mockito/annotations.dart';
import 'package:aimath/services/storage_service.dart';
import 'package:aimath/services/audio_service.dart';
import 'package:aimath/controllers/game_controller.dart';
import 'package:aimath/controllers/problem_generator.dart';
import 'package:aimath/controllers/progress_tracker.dart';

@GenerateMocks([
  StorageService,
  AudioService,
  GameController,
  ProblemGenerator,
  ProgressTracker,
])
void main() {}
