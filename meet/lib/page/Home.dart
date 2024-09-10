import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet/page/create.dart';
import 'package:meet/page/csj.dart';
import 'package:meet/page/settings.dart';
import 'package:meet/page/signin.dart';

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
  bool showMeetingDetails = false;

  List<String> participantPages = ["Meeting Attend"];
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

  void toggleMeetingDetails() {
    setState(() {
      showMeetingDetails = !showMeetingDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text(
          'Cozy meet',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.normal,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            height: 1.0,
          ),
        ),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.65,
        child: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.purple.shade800,
                ),
                accountName: Text(
                  "John Doe",
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
                accountEmail: Text(
                  "johndoe@example.com",
                  style:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    color: Colors.purple.shade800,
                    size: 40,
                  ),
                ),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.gear, color: Colors.purple.shade800, size: 20),
                title: Text('Settings'),
                onTap: () {
                    
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.user, color: Colors.purple.shade800),
                title: Text('Profile'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.purple.shade800, size: 20),
                title: Text('Saved Agenda'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.chartLine, size: 20, color: Colors.purple.shade800),
                title: Text('Statistics'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.circleExclamation, size: 20, color: Colors.purple.shade800),
                title: Text('About'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.circleQuestion, size: 20, color: Colors.purple.shade800),
                title: Text('Help'),
                onTap: () {},
              ),
               ListTile(
                leading: FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.purple.shade800, size: 20),
                title: Text('Sign Up'),
                onTap: () {
                  Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Signup()));
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.rightFromBracket, size: 20, color: Colors.purple.shade800),
                title: Text('Logout'),
                onTap: () {},
              ),
            ],
          ),
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
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.purple.shade800),
                  border: InputBorder.none,
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
                            height: 5,
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
                            height: 5,
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
                        onPressed: toggleMeetingDetails,
                        child: Text(page, style: GoogleFonts.roboto(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (showMeetingDetails)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meeting Details',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Date: 24th Aug 2024',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Time: 10:00 AM - 11:00 AM',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Location: Virtual Meeting Room',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
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
                        child: Text(page, style: GoogleFonts.roboto(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ToCreate()),
          );
        },
        child: FaIcon(FontAwesomeIcons.video, size: 30, color: Colors.white),
        backgroundColor: Colors.purple.shade800,
        shape: CircleBorder(),
      ),
    );
  }
}
