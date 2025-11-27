import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/Models/apprenticeship_model.dart';
import 'package:jbh_academy/services/apprenticeship_service.dart';
import 'package:jbh_academy/services/resume_service.dart';

import '../Models/resume_model.dart';

// --- DATA PROVIDERS (Auto-Fetch) ---

final apprenticeshipListProvider = FutureProvider.autoDispose<List<Apprenticeship>>((ref) async {
  final service = ref.watch(apprenticeshipServiceProvider);
  return service.getAllApprenticeships();
});

final resumeListProvider = FutureProvider.autoDispose<List<Resume>>((ref) async {
  final service = ref.watch(resumeServiceProvider);
  return service.getMyResumes();
});

// --- CONTROLLER FOR APPLY SCREEN ---

class ApplicationState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  ApplicationState({this.isLoading = false, this.error, this.isSuccess = false});
}

class ApplicationController extends StateNotifier<ApplicationState> {
  final ApprenticeshipService _appService;
  final ResumeService _resumeService;
  final Ref _ref;

  ApplicationController(this._appService, this._resumeService, this._ref) : super(ApplicationState());

  Future<int?> uploadAndSelectResume(String path, String name) async {
    state = ApplicationState(isLoading: true);
    try {
      final newResume = await _resumeService.uploadResume(path, name);
      // Refresh the list so the dropdown updates immediately
      _ref.invalidate(resumeListProvider);
      state = ApplicationState(isLoading: false);
      return newResume.id;
    } catch (e) {
      state = ApplicationState(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> submitApplication(int appId, int resumeId, String message) async {
    state = ApplicationState(isLoading: true);
    try {
      await _appService.apply(appId, resumeId, message);
      // Refresh the apprenticeship list to show "Applied" status
      _ref.invalidate(apprenticeshipListProvider);
      state = ApplicationState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = ApplicationState(isLoading: false, error: e.toString());
    }
  }
}

final applicationControllerProvider = StateNotifierProvider.autoDispose<ApplicationController, ApplicationState>((ref) {
  return ApplicationController(
    ref.watch(apprenticeshipServiceProvider),
    ref.watch(resumeServiceProvider),
    ref,
  );
});