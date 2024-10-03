import 'package:flutter/material.dart';
import 'package:flutter_app/pages/dashboard/notes/eng/Bca.dart'; // Import the BCA Notes page

class EngineeringPage extends StatelessWidget {
  const EngineeringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Engineering Faculty"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                "Engineering Courses",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Card for BCA, with navigation to BCA Notes page
              GestureDetector(
                onTap: () {
                  // Navigate to BcaNotesPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BcaNotesPage(),
                    ),
                  );
                },
                child: buildCourseCard("BCA", Icons.computer, Colors.green),
              ),
              const SizedBox(height: 20),
              // Card for B-Tech
              buildCourseCard("B-Tech", Icons.build, Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build course cards
  Widget buildCourseCard(String course, IconData icon, Color iconColor) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              course,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              icon,
              size: 50,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
