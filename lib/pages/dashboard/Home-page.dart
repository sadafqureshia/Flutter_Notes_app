import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/drawer.dart';
import 'package:flutter_app/pages/dashboard/page/Eng.dart'; // Import the new Engineering page

class Homepage extends StatelessWidget {
  final String greeting = "Faculty";

  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App"),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // Card for Engineering Faculty with navigation
                buildFacultyCardWithNavigation(
                  context,
                  title: "Engineering",
                  courses: ["BCA", "B-Tech", "M-Tech"],
                  icon: Icons.engineering,
                  iconColor: Colors.green,
                  navigateTo: const EngineeringPage(),
                ),
                const SizedBox(height: 20),
                // Card for Management Faculty
                buildFacultyCard(
                  title: "Management",
                  courses: ["BBA", "B.Com", "MBA"],
                  icon: Icons.business_center,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 20),
                // Add more faculty cards here
                buildFacultyCard(
                  title: "Arts & Humanities",
                  courses: ["BA", "MA", "PhD"],
                  icon: Icons.menu_book,
                  iconColor: Colors.purple,
                ),
                const SizedBox(height: 20),
                buildFacultyCard(
                  title: "Sciences",
                  courses: ["BSc", "MSc", "PhD"],
                  icon: Icons.science,
                  iconColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const MyDrawer(),
    );
  }

  // Helper method to build a faculty card with navigation
  Widget buildFacultyCardWithNavigation(BuildContext context, {
    required String title,
    required List<String> courses,
    required IconData icon,
    required Color iconColor,
    required Widget navigateTo,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigateTo),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (String course in courses)
                    Text(
                      course,
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a basic faculty card
  Widget buildFacultyCard({
    required String title,
    required List<String> courses,
    required IconData icon,
    required Color iconColor,
  }) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                for (String course in courses)
                  Text(
                    course,
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
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
