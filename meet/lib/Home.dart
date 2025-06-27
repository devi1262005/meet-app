import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meet/page/csj.dart';
import 'package:meet/page/login.dart';
import 'package:meet/page/profile.dart';
import 'package:meet/page/savedagenda.dart';
import 'package:meet/page/settings.dart';
import 'package:meet/page/videocall.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet/page/joinmeeting.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


final GoogleSignIn _googleSignIn = GoogleSignIn();

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
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  String _userPhotoUrl = '';

  List<Map<String, dynamic>> meetings = [];
  List<Map<String, dynamic>> joinedMeetings = [];
  List<Map<String, dynamic>> filteredMeetings = [];
  List<Map<String, dynamic>> filteredJoinedMeetings = [];

  GoogleSignInAccount? _currentUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });

    _googleSignIn.signInSilently();
    fetchMeetings();
    fetchJoinedMeetings();

    _searchController.addListener(() {
      filterMeetings();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          _userName = user.displayName ?? userDoc.data()?['username'] ?? 'Guest';
          _userEmail = user.email ?? 'No Email';
          _userPhotoUrl = user.photoURL ?? userDoc.data()?['profilePicUrl'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchMeetings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final meetingCollection = FirebaseFirestore.instance.collection('savedmeetings');
        final meetingSnapshot = await meetingCollection
            .where('host_id', isEqualTo: currentUser.uid)
            .get();
        
        final meetingDocs = meetingSnapshot.docs;
        setState(() {
          meetings = meetingDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          filteredMeetings = meetings;
        });
      }
    } catch (e) {
      print('Error fetching meetings: $e');
    }
  }

  Future<void> fetchJoinedMeetings() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final meetingCollection = FirebaseFirestore.instance.collection('savedmeetings');
        final meetingSnapshot = await meetingCollection
            .where('participants', arrayContains: currentUser.email)
            .where('host_id', isNotEqualTo: currentUser.uid)
            .get();
        
        final meetingDocs = meetingSnapshot.docs;
        setState(() {
          joinedMeetings = meetingDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          filteredJoinedMeetings = joinedMeetings;
        });
      }
    } catch (e) {
      print('Error fetching joined meetings: $e');
    }
  }

  void filterMeetings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMeetings = meetings.where((meeting) {
        final meetingName = meeting['meeting_name']?.toLowerCase() ?? '';
        return meetingName.contains(query);
      }).toList();

      filteredJoinedMeetings = joinedMeetings.where((meeting) {
        final meetingName = meeting['meeting_name']?.toLowerCase() ?? '';
        return meetingName.contains(query);
      }).toList();
    });
  }

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

  Future<void> _logout() async {
    await _googleSignIn.signOut();
    // Delay navigation to give time for logout
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Ensure LoginPage import
    );
  }

  Future<void> _deleteMeeting(String meetingId) async {
    try {
      await FirebaseFirestore.instance.collection('meetings').doc(meetingId).delete();
      setState(() {
        meetings.removeWhere((meeting) => meeting['meeting_id'] == meetingId);
        filteredMeetings.removeWhere((meeting) => meeting['meeting_id'] == meetingId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meeting deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete meeting: $error')),
      );
    }
  }

  void _showMeetingDetailsDialog(BuildContext context, Map<String, dynamic> meeting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(meeting['meeting_name'] ?? 'Meeting Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Participant Count: ${meeting['participant_count'] ?? 'N/A'}'),
                Text('Category: ${meeting['category'] ?? 'N/A'}'),
                Text('Agenda Details: ${meeting['agenda_details'] ?? 'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateMeetingPDF(Map<String, dynamic> meeting) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Fetch AI suggestions
      final suggestionsResponse = await http.post(
        Uri.parse('https://server4-vg91.onrender.com/generate_comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'agenda': meeting['agenda_details']}),
      );

      List<String> suggestions = [];
      if (suggestionsResponse.statusCode == 200) {
        final data = json.decode(suggestionsResponse.body);
        final comments = data['comments'] as String;
        suggestions = comments
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .toList();
      }

      // Fetch participants
      final participantsSnapshot = await FirebaseFirestore.instance
          .collection('meetings')
          .where('meeting_code', isEqualTo: meeting['meeting_code'])
          .get();

      List<String> participants = [];
      if (participantsSnapshot.docs.isNotEmpty) {
        participants = List<String>.from(participantsSnapshot.docs.first.data()['participants'] ?? []);
      }

      // Build PDF content
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                meeting['meeting_name'] ?? 'Meeting Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Meeting Details'),
            ),
            pw.Text('Meeting Code: ${meeting['meeting_code']}'),
            pw.Text('Category: ${meeting['category'] ?? 'N/A'}'),
            if (meeting['date'] != null && meeting['time'] != null)
              pw.Text('Scheduled: ${meeting['date']} at ${meeting['time']}'),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Agenda'),
            ),
            pw.Text(meeting['agenda_details'] ?? 'No agenda available'),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('AI Suggestions'),
            ),
            ...suggestions.map((suggestion) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 8),
              child: pw.Text('• $suggestion'),
            )),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text('Participants'),
            ),
            ...participants.map((participant) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('• $participant'),
            )),
          ],
        ),
      );

      // Save PDF to temporary file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/meeting_${meeting['meeting_code']}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('meeting_reports')
          .child('${meeting['meeting_code']}.pdf');
      
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Update meeting document with PDF URL
      await FirebaseFirestore.instance
          .collection('savedmeetings')
          .doc(meeting['meeting_id'])
          .update({
        'report_url': downloadUrl,
        'report_generated_at': FieldValue.serverTimestamp(),
      });

      // Clean up temporary file
      await file.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meeting report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating meeting report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text(
          'Cozy Meet',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.normal,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
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
                  _userName,
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
                accountEmail: Text(
                  _userEmail,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: _userPhotoUrl.isNotEmpty
                      ? NetworkImage(_userPhotoUrl)
                      : null,
                  child: _userPhotoUrl.isEmpty
                      ? FaIcon(
                          FontAwesomeIcons.user,
                          color: Colors.purple.shade800,
                          size: 40,
                        )
                      : null,
                ),
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.gear, color: Colors.purple.shade800, size: 20),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Setting()),
                  );
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.user, color: Colors.purple.shade800),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(), // Navigating to ProfilePage
                    ),
                  );
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.floppyDisk, color: Colors.purple.shade800, size: 20),
                title: const Text('Saved Agenda'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SavedAgenda()),
                  );
                },
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.chartLine, size: 20, color: Colors.purple.shade800),
                title: const Text('Statistics'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.circleExclamation, size: 20, color: Colors.purple.shade800),
                title: const Text('About'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.circleQuestion, size: 20, color: Colors.purple.shade800),
                title: const Text('Help'),
                onTap: () {},
              ),
              ListTile(
                leading: FaIcon(FontAwesomeIcons.rightFromBracket, size: 20, color: Colors.purple.shade800),
                title: const Text('Logout'),
                onTap: _logout,
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
            const SizedBox(height: 10),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meetings...',
                prefixIcon: Icon(Icons.search, color: Colors.purple.shade800),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.purple.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.purple.shade800),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.purple.shade800),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Horizontal Row for Participant and Host
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: toggleParticipant,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isParticipantSelected ? Colors.purple.shade200 : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          if (isParticipantSelected)
                            BoxShadow(
                              color: Colors.purple.shade500.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.user, size: 20, color: Colors.purple.shade800),
                          const SizedBox(width: 10),
                          Text(
                            'Participant',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: toggleHost,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isHostSelected ? Colors.purple.shade200 : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          if (isHostSelected)
                            BoxShadow(
                              color: Colors.purple.shade500.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.userTie, size: 20, color: Colors.purple.shade800),
                          const SizedBox(width: 10),
                          Text(
                            'Host',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (showParticipantContent) ...[
              Expanded(
                child: Column(
                  children: [
                    if (joinedMeetings.isEmpty) ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.meeting_room,
                                size: 64,
                                color: Colors.purple.shade200,
                              ),
                              SizedBox(height: 24),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Joinmeet(),
                                      ),
                                    ).then((_) {
                                      // Refresh joined meetings when returning from join meeting page
                                      fetchJoinedMeetings();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade800,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Join New Meeting',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredJoinedMeetings.length,
                          itemBuilder: (context, index) {
                            final meeting = filteredJoinedMeetings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 3,
                              child: ListTile(
                                title: Text(meeting['meeting_name'] ?? 'Unnamed Meeting'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category: ${meeting['category'] ?? 'N/A'}'),
                                    if (meeting['date'] != null && meeting['time'] != null)
                                      Text('Scheduled: ${meeting['date']} at ${meeting['time']}'),
                                    Text('Host: ${meeting['host_email'] ?? 'Unknown'}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.video_call, color: Colors.purple),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoCallPage(
                                              meeting: {
                                                'meeting_name': meeting['meeting_name'],
                                                'agenda_details': meeting['agenda_details'],
                                                'meeting_code': meeting['meeting_code'],
                                                'is_host': false,
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteMeeting(meeting['meeting_id']),
                                    ),
                                  ],
                                ),
                                onTap: () => _showMeetingDetailsDialog(context, meeting),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (showHostContent) ...[
              Expanded(
                child: Column(
                  children: [
                    if (meetings.isEmpty) ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_camera_front,
                                size: 64,
                                color: Colors.purple.shade200,
                              ),

                              SizedBox(height: 24),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ToCreate(),
                                      ),
                                    ).then((_) {
                                      // Refresh hosted meetings when returning from create page
                                      fetchMeetings();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade800,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    'Create New Meeting',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredMeetings.length,
                          itemBuilder: (context, index) {
                            final meeting = filteredMeetings[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 3,
                              child: ListTile(
                                title: Text(meeting['meeting_name'] ?? 'Unnamed Meeting'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Category: ${meeting['category'] ?? 'N/A'}'),
                                    if (meeting['date'] != null && meeting['time'] != null)
                                      Text('Scheduled: ${meeting['date']} at ${meeting['time']}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.video_call, color: Colors.purple),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoCallPage(
                                              meeting: {
                                                'meeting_name': meeting['meeting_name'],
                                                'agenda_details': meeting['agenda_details'],
                                                'meeting_code': meeting['meeting_code'],
                                                'is_host': true,
                                                'host_id': FirebaseAuth.instance.currentUser?.uid,
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                                      onPressed: () => _generateMeetingPDF(meeting),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteMeeting(meeting['meeting_id']),
                                    ),
                                  ],
                                ),
                                onTap: () => _showMeetingDetailsDialog(context, meeting),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
