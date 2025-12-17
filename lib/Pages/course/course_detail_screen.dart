import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../app_routes.dart'; // Ensure AppRoutes is imported
import '../../services/course_service.dart';
import '../../state/auth_notifier.dart';
import '../syllabus_and_module.dart'; // Import this to use SyllabusScreenArgs

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  late Razorpay _razorpay;
  int? _currentCourseId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // --- Razorpay Handlers ---
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await ref.read(courseServiceProvider).verifyPayment({
        'razorpayOrderId': response.orderId,
        'razorpayPaymentId': response.paymentId,
        'razorpaySignature': response.signature,
        'courseId': _currentCourseId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful! Enrolled."),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(myCoursesProvider); // Refresh the list of owned courses
        // Optional: Don't pop, just rebuild to show "Start Learning"
        setState(() {});
      }
    } catch (e) {
      _showError("Verification failed: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showError("Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showError("External Wallet Selected: ${response.walletName}");
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _startPayment(Course course) async {
    try {
      final user = ref.read(authNotifierProvider).user;
      final userEmail = user?.email ?? '';
      final userPhone = user?.phone ?? '';

      final data = await ref.read(courseServiceProvider).createPaymentOrder(course.courseId!);
      final String keyId = data['keyId'];
      final Map<String, dynamic> order = data['order'];

      _currentCourseId = course.courseId;

      var options = {
        'key': keyId,
        'amount': order['amount'],
        'name': 'JBH Academy',
        'description': course.title,
        'order_id': order['id'],
        'prefill': {
          'contact':userPhone , // TODO: Fetch real user phone
          'email': userEmail, // TODO: Fetch real user email
        },
        'theme': {'color': '#FF0000'},
      };

      _razorpay.open(options);
    } catch (e) {
      _showError("Failed to start payment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = ModalRoute.of(context)!.settings.arguments as Course;

    // 1. Check Enrollment Status
    final myCoursesAsync = ref.watch(myCoursesProvider);
    bool isEnrolled = false;

    myCoursesAsync.whenData((enrolledCourses) {
      if (enrolledCourses.any((c) => c.courseId == course.courseId)) {
        isEnrolled = true;
      }
    });

    return Scaffold(
      appBar: buildAppBar(context, title: "Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                image: course.thumbnailUrl != null
                    ? DecorationImage(
                  image: NetworkImage(course.thumbnailUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: course.thumbnailUrl == null
                  ? const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))
                  : null,
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              course.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Price Tag (Hide if enrolled)
            if (!isEnrolled)
              Text(
                course.price == 0 ? "Free" : "Price: ₹${course.price}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            // Description
            const Text(
              "Description:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              course.description ?? "No description available.",
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 40),

            // --- 2. PREVIEW SYLLABUS BUTTON (Only if NOT enrolled) ---
            if (!isEnrolled)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text("View Syllabus & Demo Lessons"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.syllabusModule,
                      arguments: SyllabusScreenArgs(
                        courseId: course.courseId!,
                        title: course.title,
                        isEnrolled: false, // <--- Locks content
                      ),
                    );
                  },
                ),
              ),

            // --- 3. MAIN ACTION BUTTON (Start Learning or Pay) ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Turn GREEN if enrolled, else Primary Color
                  backgroundColor: isEnrolled ? Colors.green : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                onPressed: () async {
                  if (isEnrolled) {
                    // FLOW A: Already Enrolled -> Go to Content
                    Navigator.pushNamed(
                      context,
                      AppRoutes.syllabusModule,
                      arguments: SyllabusScreenArgs(
                        courseId: course.courseId!,
                        title: course.title,
                        isEnrolled: true, // <--- Unlocks content
                      ),
                    );
                  } else {
                    // FLOW B: Not Enrolled -> Buy or Free Enroll
                    if (course.price == 0) {
                      try {
                        await ref.read(courseServiceProvider).enrollFree(course.courseId!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enrolled Successfully!")),
                          );
                          ref.invalidate(myCoursesProvider);
                          // Refresh UI to show "Start Learning"
                          setState(() {});
                        }
                      } catch (e) {
                        _showError("Error: $e");
                      }
                    } else {
                      _startPayment(course);
                    }
                  }
                },
                child: Text(
                  isEnrolled
                      ? "Start Learning"
                      : (course.price == 0 ? "Enroll for Free" : "Pay ₹${course.price} & Enroll"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}