import 'package:flutter/material.dart';
import 'package:jbh_academy/Components/floating_custom_nav_bar.dart';

import '../../Components/common_app_bar.dart';
import '../../app_routes.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Courses',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          _buildTabBarAndFilter(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Paid Courses Tab Content
                _buildCourseList(context, isPaid: true),
                // Free Courses Tab Content
                _buildCourseList(context, isPaid: false),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for the floating nav bar
        ],
      ),
      // Use index 0 or another appropriate index for this screen
      bottomNavigationBar: FloatingCustomNavBar(currentIndex: 0),
    );
  }

  /// Builds the Tab Bar (Paid/Free Course) and Filter Icon
  Widget _buildTabBarAndFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40, // Height for tab bar
              decoration: BoxDecoration(
                // Background for tabs
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor, // Selected text color
                indicatorWeight: 3.0,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.grey[600], // Unselected text
                tabs: const [
                  Tab(text: "Paid Course"),
                  Tab(text: "Free course"),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).cardColor, // Use card color for filter icon background
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              // Filter icon color
              onPressed: () {
                // Handle filter tap
                print('Filter tapped');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list of course cards
  Widget _buildCourseList(BuildContext context, {required bool isPaid}) {
    // Example data - you would fetch this from an API
    final List<Map<String, dynamic>> courses = isPaid
        ? [
      {
        'title': 'Computer Literacy',
        'price': '3000',
        'hasSyllabus': true,
        'description': null,
      },
      {
        'title': 'Python Django',
        'price': '30000',
        'hasSyllabus': false,
        'description': 'Description:',
      },
      {
        'title': 'Artificial Intelligence',
        'price': '35000',
        'hasSyllabus': false,
        'description': 'Description:',
      },
      // Add more paid courses
    ]
        : [
      {
        'title': 'Introduction to Flutter',
        'price': 'Free',
        'hasSyllabus': true,
        'description': 'Learn basics of Flutter UI.',
      },
      {
        'title': 'Basic English',
        'price': 'Free',
        'hasSyllabus': false,
        'description': 'Improve your English speaking.',
      },
      // Add more free courses
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(
          context,
          title: course['title'],
          price: course['price'],
          hasSyllabus: course['hasSyllabus'],
          description: course['description'],
        );
      },
    );
  }

  /// Builds a single Course Card
  Widget _buildCourseCard(
      BuildContext context, {
        required String title,
        required String price,
        bool hasSyllabus = false,
        String? description,
      }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.courseDetail,
          arguments: {'title': title, 'price': price},
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        color: Theme.of(context).cardColor,
        // White card background
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Course Icon/Image Placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Placeholder background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline, // Question mark icon as in Figma
                  color: Colors.black,
                  size: 30,
                ),
                // If you have an actual image:
                // child: Image.asset('assets/images/course_icon.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              // Course Details (Title, Price/Description, Syllabus)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (price !=
                        'Free') // Display "Price" only for paid courses
                      Text(
                        'Price : $price',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    if (description != null) // Display description if available
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (hasSyllabus)
                      InkWell(
                        onTap: () {
                          print('View Syllabus for $title');
                          // Navigate to syllabus view
                        },
                        child: const Text(
                          'View Syllabus',
                          style: TextStyle(
                            color: Colors.red, // Red as in Figma
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // --- CORRECTED LOGIC HERE ---
              Column(
                children: [
                  // 1. Show '+' icon for FREE courses
                  if (price == 'Free') // Check for uppercase 'Free'
                    IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        print('Add button for $title tapped');
                        // Add to cart/wishlist logic
                      },
                    ),

                  // 2. Show 'Buy Now' button for PAID courses
                  if (price != 'Free') // Any price other than 'Free'
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.paymentOptions);
                        // Buy now logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        // Button background color
                        foregroundColor: Colors.white,
                        // Text color
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              // --- END OF CORRECTION ---
            ],
          ),
        ),
      ),
    );
  }
}