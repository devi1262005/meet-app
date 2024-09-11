import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/Home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _Splash();
}

class _Splash extends State<Splash> {
  @override
  void initState() {
    super.initState();
    navigatetohome();
  }

  navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 10500), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade800, // Set the background color to purple shade800
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cozy Meet',
              style: GoogleFonts.museoModerno( // Example font style, you can change it
                fontSize: 40,
                color: Colors.white, // Text color white for better contrast
              ),
            ),
          ],
        ),
      ),
    );
  }
}
