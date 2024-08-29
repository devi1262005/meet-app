import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/create.dart';
import 'package:meet/page/schedule.dart';
import 'package:meet/page/joinmeeting.dart';

class toCreate extends StatefulWidget {
  const toCreate({super.key});

  @override
  State<toCreate> createState() => _toCreateState();
}

class _toCreateState extends State<toCreate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // Adds a default shadow to the AppBar
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3), // Custom shadow color
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(1.0), // Set the height of the shadow
          child: Container(
            color: Colors.black.withOpacity(0.2), // Color of the shadow
            height: 1.0, // Height of the shadow
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Icon
          Positioned.fill(
            child: Align(
              alignment: Alignment(0.0, 0.4), // Move icon down from the center
              child: Icon(
                Icons.grid_on, // Change this to any icon you want
                size: 150, // Adjust the size as needed
                color: Colors.purple.shade100.withOpacity(0.3), // Faded color
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Circle with Username, Email ID, and Manage Account Button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Name', // Replace with actual username
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        Text(
                          'user.email@example.com', // Replace with actual email ID
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // Manage Account Button
                        TextButton.icon(
                          onPressed: () {
                            // Action for "Manage Account"
                          },
                          icon: Icon(
                            Icons.manage_accounts_sharp,
                            size: 18,
                            color: Colors.purple.shade800,
                          ),
                          label: Text(
                            'Manage Account',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Create a Meeting Button
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Create())); // Action for "Create a Meeting"
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(
                            width: 25), // Adjusted space between icon and text
                        Text(
                          'Create a Meeting',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.purple.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Schedule a Meeting Button
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
<<<<<<< HEAD
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Schedule())); // Action for "Schedule a Meeting"
=======
        context, MaterialPageRoute(builder: (context) => Schedule())); // Action for "Schedule a Meeting"
>>>>>>> e06aa4e9f0c28281ebf4ecdcde9a8b12820fbab6
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(
                            width: 25), // Adjusted space between icon and text
                        Text(
                          'Schedule a Meeting',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.purple.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Join a Meeting Button
                InkWell(
                  onTap: () {
                    // Action for "Joining a Meeting"
<<<<<<< HEAD
                    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Joinmeet()));  
=======
                     Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Joinmeet()));
>>>>>>> e06aa4e9f0c28281ebf4ecdcde9a8b12820fbab6
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.group_add,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(
                            width: 25), // Adjusted space between icon and text
                        Text(
                          'Join a Meeting',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.purple.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
