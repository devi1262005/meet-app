import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'videocall.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Joinmeet extends StatefulWidget {
  const Joinmeet({super.key});

  @override
  State<Joinmeet> createState() => _JoinmeetState();
}

class _JoinmeetState extends State<Joinmeet> {
  final TextEditingController _meetingCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isJoining = false;
  bool _obscurePassword = true;

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

  Future<void> _joinMeeting() async {
    if (_meetingCodeController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both meeting code and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      String meetingCode = _meetingCodeController.text.replaceAll(' ', '');
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // Check in savedmeetings collection
      QuerySnapshot savedMeetingsSnapshot = await FirebaseFirestore.instance
          .collection('savedmeetings')
          .where('meeting_code', isEqualTo: meetingCode)
          .get();

      if (savedMeetingsSnapshot.docs.isNotEmpty) {
        final meetingData = savedMeetingsSnapshot.docs.first.data() as Map<String, dynamic>;
        
        // Verify password
        if (meetingData['password'] != _passwordController.text) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect password'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isJoining = false;
          });
          return;
        }

        // Store the joined meeting in Firestore
        await FirebaseFirestore.instance
            .collection('joinmeet')
            .doc(currentUser?.uid)
            .collection('joined_meetings')
            .doc(meetingCode)
            .set({
          'meeting_code': meetingCode,
          'meeting_name': meetingData['meeting_name'],
          'agenda_details': meetingData['agenda_details'],
          'host_id': meetingData['host_id'],
          'host_email': meetingData['host_email'],
          'category': meetingData['category'],
          'joined_at': FieldValue.serverTimestamp(),
          'password': _passwordController.text,
        });

        // Update participants list if not already included
        if (currentUser != null && !meetingData['participants'].contains(currentUser.email)) {
          await FirebaseFirestore.instance
              .collection('savedmeetings')
              .doc(savedMeetingsSnapshot.docs.first.id)
              .update({
            'participants': FieldValue.arrayUnion([currentUser.email])
          });
        }

        // Navigate to video call with all meeting details
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallPage(
                meeting: {
                  'meeting_name': meetingData['meeting_name'],
                  'agenda_details': meetingData['agenda_details'],
                  'meeting_code': meetingCode,
                  'is_host': false,
                  'host_id': meetingData['host_id'],
                  'host_email': meetingData['host_email'],
                  'category': meetingData['category'],
                  'participants': meetingData['participants'],
                },
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Meeting not found. Please check the code and try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error joining meeting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining meeting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Join Meeting',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple.shade800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meeting Code',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _meetingCodeController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.purple.shade800,
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit code',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.purple.shade800),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Meeting Password',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.purple.shade800,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.purple.shade800),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isJoining ? null : _joinMeeting,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isJoining
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Join Meeting',
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
    );
  }
}
