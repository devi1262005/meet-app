import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'videocall.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  String? selectedCategory;
  final TextEditingController _meetingNameController = TextEditingController();
  final TextEditingController _participantCountController = TextEditingController();
  final TextEditingController _agendaGeneratorController = TextEditingController();
  final TextEditingController _agendaDetailsController = TextEditingController();
  final TextEditingController _meetingCodeController = TextEditingController();
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _generateMeetingCode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  void _generateMeetingCode() {
    final random = Random();
    final code = List.generate(6, (_) => random.nextInt(10)).join();
    _meetingCodeController.text = '${code.substring(0, 3)} ${code.substring(3)}';
  }

  Future<void> _generateAgenda() async {
    String meetingName = _meetingNameController.text;
    String participantCount = _participantCountController.text;
    String agendaDetails = _agendaGeneratorController.text;
    String selectedCat = selectedCategory ?? '';

    Map<String, dynamic> requestBody = {
      "meeting_name": meetingName,
      "participant_count": participantCount,
      "agenda": "Generate agenda for $agendaDetails and $meetingName",
      "agenda_details": agendaDetails,
      "category": selectedCat,
    };

    final response = await http.post(
      Uri.parse('https://server4-vg91.onrender.com/generate_agenda'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String agendaText = jsonResponse['agenda'] ?? '';
        List<String> agendaPoints = agendaText.split('\n').where((line) => line.isNotEmpty).toList();
        _agendaDetailsController.text = agendaPoints.join('\n• ');
      });
    } else {
      print('Failed to generate agenda. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  void dispose() {
    _meetingNameController.dispose();
    _participantCountController.dispose();
    _agendaGeneratorController.dispose();
    _agendaDetailsController.dispose();
    _meetingCodeController.dispose();
    super.dispose();
  }

  void _toggleEditable() {
    setState(() {
      _isEditable = !_isEditable;
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
        title: Text(
          'Create Meeting',
          style: GoogleFonts.roboto(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              _buildTextField(
                controller: _meetingNameController,
                labelText: 'Meeting Name',
                hintText: 'Enter Meeting Name',
                icon: Icons.text_format,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _meetingCodeController,
                labelText: 'Meeting Code',
                hintText: 'Meeting Code',
                icon: Icons.confirmation_num,
                readOnly: true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _participantCountController,
                labelText: 'Participant Count',
                hintText: 'Participant Count',
                icon: Icons.people,
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 15),
              _buildDropdownField(),
              SizedBox(height: 15),
              _buildTextField(
                controller: _agendaGeneratorController,
                labelText: 'The meeting is about?',
                hintText: 'Enter Agenda Details',
                icon: Icons.note_add,
                maxLines: 3,
              ),
              SizedBox(height: 1),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _generateAgenda,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    backgroundColor: Colors.purple[800],
                  ),
                  child: Text(
                    'Generate',
                    style: TextStyle(fontSize: 14,color:Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(
                controller: _agendaDetailsController,
                labelText: 'Agenda Details',
                hintText: 'Generated Agenda Details',
                icon: Icons.text_fields,
                maxLines: null,
                readOnly: !_isEditable,
                hasEditIcon: true,
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please sign in to create a meeting')),
            );
            return;
          }

          String meetingName = _meetingNameController.text;
          String participantCount = _participantCountController.text;
          String agendaDetails = _agendaDetailsController.text;
          String meetingCode = _meetingCodeController.text.replaceAll(' ', '');
          String selectedCat = selectedCategory ?? '';

          try {
            // Create the meeting document with host information
            final meetingRef = await FirebaseFirestore.instance.collection('meetings').add({
              'meeting_name': meetingName,
              'participant_count': participantCount,
              'agenda_details': agendaDetails,
              'category': selectedCat,
              'meeting_code': meetingCode,
              'created_at': FieldValue.serverTimestamp(),
              'host_id': currentUser.uid,
              'host_email': currentUser.email,
              'is_host': true,
              'participants': [currentUser.uid], // Initialize with host as first participant
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoCallPage(
                  meeting: {
                    'meeting_name': meetingName,
                    'agenda_details': agendaDetails,
                    'meeting_code': meetingCode,
                    'is_host': true,
                    'host_id': currentUser.uid,
                    'host_email': currentUser.email,
                    'meeting_id': meetingRef.id,
                  },
                ),
              ),
            );
          } catch (e) {
            print('Error storing meeting details: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create meeting: ${e.toString()}')),
            );
          }
        },
        backgroundColor: Colors.purple[800],
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    bool readOnly = false,
    bool hasEditIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.roboto(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: inputType,
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(icon, color: Colors.grey.shade600),
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  ),
                  maxLines: maxLines,
                  readOnly: readOnly,
                ),
              ),
              if (hasEditIcon)
                GestureDetector(
                  onTap: _toggleEditable,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      _isEditable ? Icons.edit_off : Icons.edit,
                      color: _isEditable ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    List<String> categories = ['Business', 'Tech', 'Design', 'Education'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.roboto(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedCategory,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
            hint: Text('Choose a Category'),
          ),
        ),
      ],
    );
  }
}
