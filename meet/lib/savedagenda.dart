import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'videocall.dart';

class SavedAgenda extends StatefulWidget {
  const SavedAgenda({super.key});

  @override
  State<SavedAgenda> createState() => _SavedAgendaState();
}

class _SavedAgendaState extends State<SavedAgenda> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text(
          'Saved Meetings',
          style: GoogleFonts.roboto(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('savedmeetings')
            .where('host_id', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(
              child: Text(
                'No meetings scheduled yet',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              var meeting = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              meeting['meeting_name'] ?? 'No Name',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.purple[800]),
                            onPressed: () {
                              final meetingCode = meeting['meeting_code'];
                              if (meetingCode != null) {
                                Share.share(
                                  'Join my meeting with code: $meetingCode\n\nMeeting Name: ${meeting['meeting_name']}\nDate: ${meeting['date']}\nTime: ${meeting['time']}'
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildInfoRow(Icons.calendar_today, 'Date', meeting['date'] ?? 'Not set'),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.access_time, 'Time', meeting['time'] ?? 'Not set'),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.category, 'Category', meeting['category'] ?? 'Not set'),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.people, 'Participant Count', meeting['participant_count'] ?? 'Not set'),
                      SizedBox(height: 16),
                      Text(
                        'Agenda Details',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        meeting['agenda_details'] ?? 'No agenda details',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Code: ',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    meeting['meeting_code'] ?? 'Not set',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.purple[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallPage(
                          meeting: {
                            'meeting_name': meeting['meeting_name'],
                            'agenda_details': meeting['agenda_details'],
                            'meeting_code': meeting['meeting_code'],
                                      'is_host': meeting['host_id'] == FirebaseAuth.instance.currentUser?.uid,
                                      'host_id': meeting['host_id'] ?? '',
                          },
                        ),
                      ),
                    );
                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[800],
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                              minimumSize: Size(0, 0),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
