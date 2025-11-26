import 'package:flutter/material.dart';
import 'package:jbh_academy/Pages/Authentication/forgot_screen_page.dart';
import 'package:jbh_academy/Pages/Authentication/login_page.dart';
import 'package:jbh_academy/Pages/Authentication/register_page.dart';
import 'package:jbh_academy/Pages/Authentication/verification%20Page.dart';
// Import all your screen files
// Note: I am guessing the class names from your file names.
// You MUST update these if your class names are different!
import 'package:jbh_academy/Pages/apprenticeship/apply_apprenticeship_screen.dart';
import 'package:jbh_academy/Pages/apprenticeship/apprenticeship_detail_screen.dart';
import 'package:jbh_academy/Pages/apprenticeship/apprenticeships_screen.dart';
// Typo 'deatila' is from your image
import 'package:jbh_academy/Pages/course/course_selection_screen.dart';
import 'package:jbh_academy/Pages/demo_class_screen.dart';
import 'package:jbh_academy/Pages/home_page.dart';
import 'package:jbh_academy/Pages/live_lecture_screen.dart';
import 'package:jbh_academy/Pages/notes_screen.dart';
import 'package:jbh_academy/Pages/payment_option_screen.dart';
import 'package:jbh_academy/Pages/placeholderscreen.dart'; // I see this, good for placeholders
import 'package:jbh_academy/Pages/quizzes_result_screen.dart';
import 'package:jbh_academy/Pages/quizzes_screen.dart';
import 'package:jbh_academy/Pages/recorded_lecture_screen.dart';
import 'package:jbh_academy/Pages/scholarship/scholarship_result_screen.dart'; // This is the "Results!" screen
import 'package:jbh_academy/Pages/scholarship/scholarship_screen.dart';
import 'package:jbh_academy/Pages/score_&_result_screen.dart'; // Scholarship results
import 'package:jbh_academy/Pages/syllabus_and_module.dart';
import 'package:jbh_academy/Pages/time_table_screen.dart';

import 'Pages/assignment_screen.dart';
import 'Pages/attendance_screen.dart';
import 'Pages/course/course_detail_screen.dart';
import 'Pages/my_courses.dart';
import 'Pages/scholarship/scholarship_apply.dart';
import 'Pages/weekly_test/weekly_test_result_screen.dart';
import 'Pages/weekly_test/weekly_test_screeen.dart'; // Spacing is from your image

/// This class holds all the route names for your app.
/// Using static consts prevents typos when referring to routes.
class AppRoutes {
  static const String login = '/'; // '/' is the default "home" route
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String home = '/home';
  static const String courseSelection = '/course-selection';
  static const String courseDetail = '/course-detail';
  static const String liveLectures = '/live-lectures';
  static const String timeTable = '/time-table';
  static const String recordedLectures = '/recorded-lectures';
  static const String pdfNotes = '/pdf-notes';
  static const String demoClass = '/demo-class';
  static const String weeklyTest =
      '/weekly-test'; // This is in the 'weekly_test' folder
  static const String assignments = '/assignments';
  static const String quizzes = '/quizzes';
  static const String scoreResults = '/results'; // The "Results!" screen
  static const String scholarshipResult =
      '/scholarship-result'; // The list screen
  static const String quizzesResult = '/quizzes-result'; // The list screen
  static const String paymentOptions = '/payment-options';
  static const String apprenticeships = '/apprenticeships';
  static const String apprenticeshipDetail = '/apprenticeship-detail';
  static const String applyApprenticeship = '/apply-apprenticeship';
  static const String placeholder = '/placeholder'; // Good for new items
  static const String weeklyTestResult = '/weekly-test-result';
  static const String myCourses = "/my-courses";
  static const String scholarship = "/scholarship";
  static const String applyScholarship = "/apply-scholarship";
  static const String syllabusModule = "/syllabus-module";
  static const String attendance = "/attendance";
}

/// This map links a route name (from AppRoutes) to a screen (Widget).
/// This is the magic that makes named routes work.
Map<String, WidgetBuilder> appRoutes = {
  // --- A_ Imports ---
  AppRoutes.applyApprenticeship: (context) => const ApplyApprenticeshipScreen(),
  AppRoutes.apprenticeshipDetail: (context) =>
      const ApprenticeshipDetailScreen(),
  AppRoutes.apprenticeships: (context) => const ApprenticeshipsScreen(),
  AppRoutes.assignments: (context) => const AssignmentScreen(),
  // --- C_ Imports ---
  AppRoutes.courseDetail: (context) => const CourseDetailScreen(),
  AppRoutes.courseSelection: (context) => const CourseSelectionScreen(),
  // --- D_ Imports ---
  AppRoutes.demoClass: (context) => const DemoClassScreen(),
  // --- F_ Imports ---
  AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
  // --- H_ Imports ---
  AppRoutes.home: (context) => const HomeScreen(),
  // --- L_ Imports ---
  AppRoutes.liveLectures: (context) => const LecturesScreen(),
  AppRoutes.login: (context) => const LoginPage(),
  // --- N_ Imports ---
  AppRoutes.pdfNotes: (context) => const NotesScreen(),
  // --- P_ Imports ---
  AppRoutes.paymentOptions: (context) => const PaymentOptionScreen(),
  AppRoutes.placeholder: (context) => const PlaceholderScreen(),
  // --- Q_ Imports ---
  AppRoutes.quizzes: (context) => const QuizzesScreen(),
  AppRoutes.quizzesResult: (context) => const QuizzesResultScreen(),
  // --- R_ Imports ---
  AppRoutes.recordedLectures: (context) => const RecordedLecturesScreen(),
  AppRoutes.register: (context) => const RegisterPage(),
  AppRoutes.scoreResults: (context) => const ScoreResultsScreen(),
  // 'scholarship_screen.dart'
  // --- S_ Imports ---
  AppRoutes.scholarshipResult: (context) =>
      const ScholarshipResultsScreen(), // 'score_&_result_screen.dart'
  // --- T_ Imports ---
  AppRoutes.timeTable: (context) => const TimeTableScreen(),
  // --- V_ Imports ---
  AppRoutes.verification: (context) => const VerificationPage(),
  // --- W_ Imports ---
  AppRoutes.weeklyTest: (context) => const WeeklyTestScreen(),

  AppRoutes.weeklyTestResult: (context) => const WeeklyTestResultScreen(),

  AppRoutes.myCourses: (context) => const MyCoursesScreen(),

  AppRoutes.scholarship: (context) => const UpcomingScholarshipScreen(),

  AppRoutes.applyScholarship: (context) => const ApplyScholarshipScreen(),
  AppRoutes.syllabusModule: (context) => const SyllabusModulesScreen(),
  AppRoutes.attendance: (context) => const AttendanceScreen(),
};
