import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // <--- Import
import '../../Components/common_app_bar.dart';
import '../../Models/course_model.dart';
import '../../services/course_service.dart';

// Change to ConsumerStatefulWidget to handle Razorpay lifecycle
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  late Razorpay _razorpay;
  int? _currentCourseId; // To track which course is being bought

  @override
  void initState() {
    super.initState();
    // 1. Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Important: Clear listeners
    super.dispose();
  }

  // --- Razorpay Handlers ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // 2. Call Backend to Verify & Enroll
      await ref.read(courseServiceProvider).verifyPayment({
        'razorpayOrderId': response.orderId,
        'razorpayPaymentId': response.paymentId,
        'razorpaySignature': response.signature,
        'courseId': _currentCourseId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful! Enrolled."), backgroundColor: Colors.green),
        );
        // Refresh My Courses list
        ref.invalidate(myCoursesProvider);
        Navigator.pop(context);
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

  // --- Main Payment Logic ---
  Future<void> _startPayment(Course course) async {
    try {
      // 1. Get Order ID from Backend
      final data = await ref.read(courseServiceProvider).createPaymentOrder(course.courseId!);

      final String keyId = data['keyId'];
      final Map<String, dynamic> order = data['order'];

      _currentCourseId = course.courseId;

      // 2. Open Razorpay Checkout
      var options = {
        'key': keyId,
        'amount': order['amount'], // Amount in paise
        'name': 'JBH Academy',
        'description': course.title,
        'order_id': order['id'], // Generate Order ID from Backend
        'prefill': {
          'contact': '9876543210', // You can fetch user phone from AuthState if available
          'email': 'student@example.com' // Fetch user email from AuthState
        },
        'theme': {'color': '#FF0000'}
      };

      _razorpay.open(options);

    } catch (e) {
      _showError("Failed to start payment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = ModalRoute.of(context)!.settings.arguments as Course;

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
              color: Colors.grey[300],
              child: course.thumbnailUrl != null
                  ? Image.network(course.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.image))
                  : const Center(child: Icon(Icons.image, size: 50)),
            ),
            const SizedBox(height: 20),

            // Title & Price
            Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              course.price == 0 ? "Free" : "Price: ₹${course.price}",
              style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Description
            const Text("Description:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(course.description ?? "No description available.", style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 40),

            // --- PAY / ENROLL BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (course.price == 0) {
                    // Free Course Flow
                    try {
                      await ref.read(courseServiceProvider).enrollFree(course.courseId!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enrolled Successfully!")));
                        ref.invalidate(myCoursesProvider);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      _showError("Error: $e");
                    }
                  } else {
                    // Paid Course Flow (Razorpay)
                    _startPayment(course);
                  }
                },
                child: Text(course.price == 0 ? "Enroll for Free" : "Pay ₹${course.price} & Enroll"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}