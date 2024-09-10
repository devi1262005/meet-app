import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/videocall.dart';

class   Waiting extends StatefulWidget {
  const Waiting({super.key});

  @override
  State<Waiting> createState() => _CreateState();
}

class _CreateState extends State<Waiting> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Waiting Room',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            color: Colors.purple.shade800,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            height: 2.0,
          ),
        ),
      ),
     body:Container(
       // Light purple background color
      child:  Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0), // Adjusts top padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome!\nReady to join',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
             
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.purple.shade800,
                child: FaIcon(
                  FontAwesomeIcons.user,
                  color: Colors.white,
                  size: 50, // Adjust the size of the icon
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Host is in the call',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
              ),
              
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  // Add your onPressed functionality here
                   Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => VideoCallPage()));
                },
                child: Text(
                  'Join meeting',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.purple.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Join and Use phone for audio!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      )
      
    );
  }
}
