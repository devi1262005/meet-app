import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet/page/create.dart';
import 'package:meet/page/csj.dart';
import 'package:meet/page/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showParticipantContent = false;
  bool showHostContent = false;
  bool isParticipantSelected = false;
  bool isHostSelected = false;
  List<String> participantPages = ["Participant Page 1", "Participant Page 2", "Participant Page 3"];
  List<String> hostPages = ["Host Page 1", "Host Page 2"];

  void toggleParticipant() {
    setState(() {
      showParticipantContent = !showParticipantContent;
      if (showParticipantContent) {
        showHostContent = false;
        isParticipantSelected = true;
        isHostSelected = false;
      } else {
        isParticipantSelected = false;
      }
    });
  }

  void toggleHost() {
    setState(() {
      showHostContent = !showHostContent;
      if (showHostContent) {
        showParticipantContent = false;
        isHostSelected = true;
        isParticipantSelected = false;
      } else {
        isHostSelected = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // This will add a default shadow to the AppBar
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3), // Custom shadow color
        title: Text(
          'Cozy meet',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.normal,
          ),
        ),
       
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Set the height of the shadow
          child: Container(
            color: Colors.black.withOpacity(0.2), // Color of the shadow
            height: 1.0, // Height of the shadow
          ),
        ),
      ),
      
     
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple.shade800,
              ),
              child: Text(
                'Menu',
                style: GoogleFonts.roboto(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.purple.shade800),
              title: Text('Home', style: GoogleFonts.roboto(color: Colors.purple.shade800)),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Home page
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.purple.shade800),
              title: Text('Settings', style: GoogleFonts.roboto(color: Colors.purple.shade800)),
              onTap: () {
                 Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Settings()),
          ); // Close the drawer
                // Navigate to Settings page
              },
            ),
            // Add more drawer items here
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3), // Changes the position of the shadow
      ),
    ],
  ),
  child: TextField(
    decoration: InputDecoration(
      hintText: 'Search...',
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(Icons.search, color: Colors.purple.shade800),
      border: InputBorder.none, // Removes the border
      contentPadding: EdgeInsets.all(15),
    ),
    style: TextStyle(color: Colors.purple.shade800),
  ),
),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: toggleParticipant,
                    child: Column(
                      children: [
                        Text(
                          'Participant',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        if (isParticipantSelected)
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            height: 5, // Line thickness
                            color: Colors.purple.shade800,
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: toggleHost,
                    child: Column(
                      children: [
                        Text(
                          'Host',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            color: Colors.purple.shade800,
                          ),
                        ),
                        if (isHostSelected)
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            height: 5, // Line thickness
                            color: Colors.purple.shade800,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (showParticipantContent) 
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: participantPages.map((page) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle page click here
                        },
                        child: Text(page, style: GoogleFonts.roboto(color: const Color.fromARGB(255, 0, 0, 0))),
                        style: ElevatedButton.styleFrom(
                          
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (showHostContent) 
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: hostPages.map((page) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle page click here
                        },
                        child: Text(page, style: GoogleFonts.roboto(color: const Color.fromARGB(255, 0, 0, 0))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the video action here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const toCreate()),
          );
        },
        child: FaIcon(FontAwesomeIcons.video, size: 30, color: Colors.white),
        backgroundColor: Colors.purple.shade800,
        shape: CircleBorder(),
      ),
    );
  }
}
