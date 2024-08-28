import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Map<String, dynamic>? _jsonResponse;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  Future<void> _generateAgenda() async {
    String agendaDetails = _agendaGeneratorController.text;

    // Create the request body with the specified format
    Map<String, dynamic> requestBody = {
      "agenda": "generate agenda for $agendaDetails",
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5001/generate_agenda'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Extract the agenda text
        String agendaText = jsonResponse['agenda'] ?? '';

        // Clean up the agenda text and format for display
        List<String> agendaPoints = agendaText.split('\n').where((line) => line.isNotEmpty).toList();
        _agendaDetailsController.text = agendaPoints.join('\n• ');
      });
    } else {
      print('Failed to generate agenda. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _editAgenda() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Agenda'),
          content: TextField(
            controller: _agendaDetailsController,
            decoration: InputDecoration(
              hintText: 'Edit agenda details',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _jsonResponse = jsonDecode(_agendaDetailsController.text);
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _meetingNameController.dispose();
    _participantCountController.dispose();
    _agendaGeneratorController.dispose();
    _agendaDetailsController.dispose();
    super.dispose();
  }

  void _navigateToNextPage() {
    // Navigate to the next meeting page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextMeetingPage()), // Replace with your next page
    );
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
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.play, color: Colors.blue),
          onPressed: _navigateToNextPage,
        ),
        title: Text(
          'Create Meeting',
          style: GoogleFonts.roboto(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            SizedBox(height: 40),
            Text(
              'Meeting Name',
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
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
              child: TextField(
                controller: _meetingNameController,
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.text_format, color: Colors.grey.shade600),
                  ),
                  hintText: 'Enter Meeting Name',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Participant Count',
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _participantCountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.people, color: Colors.grey.shade600),
                  ),
                  hintText: 'Participant Count',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Category',
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select Category',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                items: <String>[
                  'Category 1',
                  'Category 2',
                  'Category 3',
                  'Category 4'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Agenda Generator',
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _agendaGeneratorController,
                decoration: InputDecoration(
                  hintText: 'Type agenda details',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                maxLines: 2,
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _generateAgenda,
              child: Text('Generate Agenda'),
            ),
            SizedBox(height: 15),
            Text(
              'Agenda Details',
              style: GoogleFonts.roboto(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _agendaDetailsController,
                decoration: InputDecoration(
                  hintText: 'Generated agenda will appear here',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                maxLines: 5,
                readOnly: true,
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _editAgenda,
              child: Text('Edit Agenda'),
            ),
            SizedBox(height: 15),
            CheckboxListTile(
              title: Text('Hide Agenda In Meeting'),
              value: false, // Replace with your variable
              onChanged: (bool? value) {
                setState(() {
                  // Update the variable here
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNextPage,
        child: Icon(FontAwesomeIcons.arrowRight),
      ),
    );
  }
}

// Placeholder for the next meeting page
class NextMeetingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Meeting Page'),
      ),
      body: Center(
        child: Text('This is the next meeting page.'),
      ),
    );
  }
}
