// ... imports ...
import 'package:flutter/material.dart';
// ... other imports ...
import 'package:jbh_academy/Pages/Authentication/login_page.dart';
import 'package:jbh_academy/Pages/admin/manage_syllabus_screen.dart';

import 'Models/lesson_model.dart';
import 'Pages/Authentication/auth_guard_screen.dart';
import 'Pages/Authentication/forgot_screen_page.dart';
import 'Pages/Authentication/register_page.dart';
import 'Pages/Authentication/reset_password_screen.dart';
import 'Pages/Authentication/verification Page.dart';
import 'Pages/admin/add_edit_course_screen.dart';
import 'Pages/admin/admin_apprenticeship_list.dart';
import 'Pages/admin/admin_dashboard.dart';
import 'Pages/admin/apprenticeship_applicants_screen.dart';
import 'Pages/admin/assign_schedule_screen.dart';
import 'Pages/admin/create_apprenticeship_screen.dart';
import 'Pages/admin/create_user_screen.dart';
import 'Pages/admin/manage_courses_screen.dart';
import 'Pages/admin/manage_users_screen.dart';
import 'Pages/apprenticeship/apply_apprenticeship_screen.dart';
import 'Pages/apprenticeship/apprenticeship_detail_screen.dart';
import 'Pages/apprenticeship/apprenticeships_screen.dart';
import 'Pages/assignment_screen.dart';
import 'Pages/attendance_screen.dart';
import 'Pages/course/course_detail_screen.dart';
import 'Pages/course/course_selection_screen.dart';
import 'Pages/course/lesson_viewer_screen.dart';
import 'Pages/demo_class_screen.dart';
import 'Pages/home_page.dart';
import 'Pages/live_class/live_class_screen.dart';
import 'Pages/live_lecture_screen.dart';
import 'Pages/resume/manage_resumes_screen.dart';
import 'Pages/my_courses.dart';
import 'Pages/notes_screen.dart';
import 'Pages/payment_option_screen.dart';
import 'Pages/placeholderscreen.dart';
import 'Pages/quizzes_result_screen.dart';
import 'Pages/quizzes_screen.dart';
import 'Pages/scholarship/scholarship_apply.dart';
import 'Pages/scholarship/scholarship_result_screen.dart';
import 'Pages/scholarship/scholarship_screen.dart';
import 'Pages/score_&_result_screen.dart';
import 'Pages/syllabus_and_module.dart';
import 'Pages/time_table_screen.dart';
import 'Pages/weekly_test/weekly_test_result_screen.dart';
import 'Pages/weekly_test/weekly_test_screeen.dart';



class AppRoutes {
  static const String splash = "/";
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String home = '/home';
  static const String courseSelection = '/course-selection';
  static const String courseDetail = '/course-detail';
  static const String liveLectures = '/live-lectures';
  static const String timeTable = '/time-table';
  static const String pdfNotes = '/pdf-notes';
  static const String demoClass = '/demo-class';
  static const String weeklyTest = '/weekly-test';
  static const String assignments = '/assignments';
  static const String quizzes = '/quizzes';
  static const String scoreResults = '/results';
  static const String scholarshipResult = '/scholarship-result';
  static const String quizzesResult = '/quizzes-result';
  static const String paymentOptions = '/payment-options';
  static const String apprenticeships = '/apprenticeships';
  static const String apprenticeshipDetail = '/apprenticeship-detail';
  static const String applyApprenticeship = '/apply-apprenticeship';
  static const String placeholder = '/placeholder';
  static const String weeklyTestResult = '/weekly-test-result';
  static const String myCourses = "/my-courses";
  static const String scholarship = "/scholarship";
  static const String applyScholarship = "/apply-scholarship";
  static const String syllabusModule = "/syllabus-module";
  static const String attendance = "/attendance";
  static const String resetPassword = "/reset-password";
  static const String manageResumes = '/manage-resumes';
  static const String adminDashboard = '/admin/dashboard';
  static const String createJob = '/admin/create-job';
  static const String manageUsers = '/admin/manage-users';
  static const String createUser = '/admin/create-user';
  static const String manageCourses = '/admin/manage-courses';
  static const String addEditCourse = '/admin/add-edit-course';
  static const String manageSyllabus = '/admin/manage-syllabus';
  static const String liveClass = '/live-class';
  static const String lessonViewer = '/lesson-viewer';
  static const String assignSchedule = "/admin/assign-schedule";

  static const String adminApprenticeshipList = '/admin/apprenticeships-list';
  static const String adminApprenticeshipApplicants = '/admin/apprenticeship-applicants';

}

Map<String, WidgetBuilder> appRoutes = {
  // ... keep existing map entries ...
  // Ensure login page is mapped to the new route string

  AppRoutes.splash: (context) => const AuthGuardScreen(),
  AppRoutes.login: (context) => const LoginPage(),
  // ... other routes ...
  AppRoutes.register: (context) => const RegisterPage(),
  AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
  AppRoutes.home: (context) => const HomeScreen(),
  AppRoutes.courseSelection: (context) => const CourseSelectionScreen(),
  AppRoutes.courseDetail: (context) => const CourseDetailScreen(),
  AppRoutes.liveLectures: (context) => const LecturesScreen(),
  AppRoutes.timeTable: (context) => const TimeTableScreen(),
  AppRoutes.pdfNotes: (context) => const NotesScreen(),
  AppRoutes.demoClass: (context) => const DemoClassScreen(),
  AppRoutes.weeklyTest: (context) => const WeeklyTestScreen(),
  AppRoutes.assignments: (context) => const AssignmentScreen(),
  AppRoutes.quizzes: (context) => const QuizzesScreen(),
  AppRoutes.scoreResults: (context) => const ScoreResultsScreen(),
  AppRoutes.scholarshipResult: (context) => const ScholarshipResultsScreen(),
  AppRoutes.quizzesResult: (context) => const QuizzesResultScreen(),
  AppRoutes.paymentOptions: (context) => const PaymentOptionScreen(),
  AppRoutes.apprenticeships: (context) => const ApprenticeshipsScreen(),
  AppRoutes.apprenticeshipDetail: (context) => const ApprenticeshipDetailScreen(),
  AppRoutes.applyApprenticeship: (context) => const ApplyApprenticeshipScreen(),
  AppRoutes.placeholder: (context) => const PlaceholderScreen(),
  AppRoutes.weeklyTestResult: (context) => const WeeklyTestResultScreen(),
  AppRoutes.myCourses: (context) => const MyCoursesScreen(),
  AppRoutes.scholarship: (context) => const UpcomingScholarshipScreen(),
  AppRoutes.applyScholarship: (context) => const ApplyScholarshipScreen(),
  AppRoutes.syllabusModule: (context) => const SyllabusModulesScreen(),
  AppRoutes.attendance: (context) => const AttendanceScreen(),
  AppRoutes.verification: (context) => const VerificationPage(),
  AppRoutes.resetPassword: (context) => const ResetPasswordScreen(),
  AppRoutes.manageResumes: (context) => const ManageResumesScreen(),
  AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
  AppRoutes.createJob: (context) => const CreateApprenticeshipScreen(),
  AppRoutes.manageUsers: (context) => const ManageUsersScreen(),
  AppRoutes.createUser: (context) => const CreateUserScreen(),
  AppRoutes.manageCourses: (context) => const ManageCoursesScreen(),
  AppRoutes.addEditCourse: (context) => const AddEditCourseScreen(),
  AppRoutes.manageSyllabus: (context)=> const ManageSyllabusScreen(),
  AppRoutes.liveClass: (context) => const _LiveClassWrapper(), // Wrapper to handle arguments
  AppRoutes.lessonViewer: (context) {
    final lesson = ModalRoute.of(context)!.settings.arguments as Lesson;
    return LessonViewerScreen(lesson: lesson);
  },
  AppRoutes.assignSchedule: (context) => const AssignScheduleScreen(),

  // 1. Admin Job List
  AppRoutes.adminApprenticeshipList: (context) => const AdminApprenticeshipListScreen(),

  // 2. Admin Applicants (Uses Wrapper)
  AppRoutes.adminApprenticeshipApplicants: (context) => const _ApprenticeshipApplicantsWrapper(),
};


// ==========================================================
//                 HELPER CLASSES & WIDGETS
//           (Place these at the bottom of the file)
// ==========================================================

// 1. Argument Class (Defines what data must be passed)
class LiveClassArgs {
  final String roomId;
  final String token;
  final String displayName;

  LiveClassArgs({
    required this.roomId,
    required this.token,
    required this.displayName,
  });
}

// 2. Wrapper Widget (Extracts arguments and builds the screen)
// The underscore (_) makes it private, so only this file can see it.
class _LiveClassWrapper extends StatelessWidget {
  const _LiveClassWrapper();

  @override
  Widget build(BuildContext context) {
    // Extract arguments safely
    final args = ModalRoute.of(context)!.settings.arguments as LiveClassArgs;

    return LiveClassScreen(
      roomId: args.roomId,
      token: args.token,
      displayName: args.displayName,
    );
  }
}

// 1. Arguments Class for Applicants Screen
class ApprenticeshipApplicantsArgs {
  final int apprenticeshipId;
  final String jobTitle;

  ApprenticeshipApplicantsArgs({
    required this.apprenticeshipId,
    required this.jobTitle
  });
}

// 2. Wrapper Widget to extract arguments
class _ApprenticeshipApplicantsWrapper extends StatelessWidget {
  const _ApprenticeshipApplicantsWrapper();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ApprenticeshipApplicantsArgs;

    return ApprenticeshipApplicantsScreen(
      apprenticeshipId: args.apprenticeshipId,
      jobTitle: args.jobTitle,
    );
  }
}