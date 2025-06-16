import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/create.dart';
import 'package:meet/page/schedule.dart';
import 'package:meet/page/joinmeeting.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ToCreate extends StatefulWidget {
  const ToCreate({super.key});

  @override
  State<ToCreate> createState() => _ToCreateState();
}

class _ToCreateState extends State<ToCreate> {
  User? user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }


  void _getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

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

                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User Name',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        Text(
                          user?.email ?? 'user.email@example.com',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        TextButton.icon(
                          onPressed: () {

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
                      MaterialPageRoute(builder: (context) => Create()),
                    );
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
                    );
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

                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Joinmeet()),
                    );
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
