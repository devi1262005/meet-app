import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _CreateState();
}

class _CreateState extends State<Settings> {
  bool isToggled = false; // Track the state of the toggle button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // This will add a default shadow to the AppBar
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.purple.shade800,
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 30,
                color: Colors.purple.shade800,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 50),
            Row(
              children: [
                Icon(Icons.video_call),
                SizedBox(width: 10),
                Text(
                  'Video',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.audiotrack),
                SizedBox(width: 10),
                Text(
                  'Audio',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.brightness_4_outlined),
                SizedBox(width: 10),
                Text(
                  'Theme',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Spacer(), // Pushes the toggle button to the far right
                IconButton(
                  onPressed: () {
                    setState(() {
                      isToggled = !isToggled; // Toggle the state
                    });
                  },
                  icon: FaIcon(
                    isToggled ? FontAwesomeIcons.toggleOn : FontAwesomeIcons.toggleOff, // Change icon based on state
                    color: isToggled ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0), // Optionally change color based on state
                  ),
                ),
              ],
            ),
            // Add more content below this line
          ],
        ),
      ),
    );
  }
}
