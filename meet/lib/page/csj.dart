import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/create.dart';
import 'package:meet/page/schedule.dart';
import 'package:meet/page/joinmeeting.dart';

class ToCreate extends StatefulWidget {
  const ToCreate({super.key});

  @override
  State<ToCreate> createState() => _ToCreateState();
}

class _ToCreateState extends State<ToCreate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Icon
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0.0, 0.4),
              child: Icon(
                Icons.grid_on,
                size: 150,
                color: Colors.purple.shade100.withOpacity(0.3),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Create()),
                    ); // Action for "Create a Meeting"
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(width: 25),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Schedule()),
                    ); // Action for "Schedule a Meeting"
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.schedule,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(width: 25),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Joinmeet()),
                    ); // Action for "Join a Meeting"
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Icon(Icons.group_add,
                            color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(width: 25),
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
