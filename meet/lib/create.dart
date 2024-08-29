import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For encoding the JSON request body

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  String? selectedCategory;
  final TextEditingController _meetingNameController = TextEditingController();
<<<<<<< HEAD
  final TextEditingController _participantCountController =
      TextEditingController();
  final TextEditingController _agendaGeneratorController =
      TextEditingController();
  final TextEditingController _agendaDetailsController =
      TextEditingController();
=======
  final TextEditingController _participantCountController = TextEditingController();
  final TextEditingController _agendaGeneratorController = TextEditingController();
  final TextEditingController _agendaDetailsController = TextEditingController();
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
  Map<String, dynamic>? _jsonResponse; // To store the parsed JSON response

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
    String meetingName = _meetingNameController.text;
    String participantCount = _participantCountController.text;
    String agendaDetails = _agendaGeneratorController.text;
    String selectedCat = selectedCategory ?? '';

    Map<String, dynamic> requestBody = {
      "meeting_name": meetingName,
      "participant_count": participantCount,
      "agenda": "Generate agenda for $agendaDetails",
      "agenda_details": agendaDetails,
      "category": selectedCat,
    };

    final response = await http.post(
<<<<<<< HEAD
      Uri.parse(
          'http://10.0.2.2:5001/generate_agenda'), // Replace with your API URL
=======
      Uri.parse('http://10.0.2.2:5001/generate_agenda'), // Replace with your API URL
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
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

        // Clean up the agenda text
<<<<<<< HEAD
        List<String> agendaPoints =
            agendaText.split('\n').where((line) => line.isNotEmpty).toList();

        // Format the points for display
        _agendaDetailsController.text =
            agendaPoints.join('\n• '); // Add a bullet point before each line
=======
        List<String> agendaPoints = agendaText.split('\n').where((line) => line.isNotEmpty).toList();

        // Format the points for display
        _agendaDetailsController.text = agendaPoints.join('\n• '); // Add a bullet point before each line
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
      });
    } else {
      print('Failed to generate agenda. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }


  void _editAgenda() {
    // Handle the editing functionality here
    // For example, show a dialog with a TextField to update the agenda
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
      MaterialPageRoute(
          builder: (context) =>
              NextMeetingPage()), // Replace with your next page
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
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            SizedBox(height: 40),
            Text(
              'Meeting Name',
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
              child: TextField(
                controller: _meetingNameController,
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.text_format, color: Colors.grey.shade600),
                  ),
                  hintText: 'Enter Meeting Name',
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
                maxLines: 1,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Participant Count',
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
                maxLines: 1,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Category',
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
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
              'The meeting is about?',
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
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _agendaGeneratorController,
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.note_add, color: Colors.grey.shade600),
                  ),
                  hintText: 'Enter Agenda Details',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
<<<<<<< HEAD
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
=======
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
                ),
                maxLines: 3,
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 5), // Space between the TextField and the button
=======
            SizedBox(height: 5),  // Space between the TextField and the button
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _generateAgenda,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  backgroundColor: Colors.blue, // Adjust button color as needed
                ),
                child: Text(
                  'Generate',
                  style: TextStyle(fontSize: 14), // Adjust text size as needed
                ),
              ),
            ),

            SizedBox(height: 2),
            Text(
              'Agenda Details',
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
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _agendaDetailsController,
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.text_fields, color: Colors.grey.shade600),
                  ),
                  hintText: 'Generated Agenda Details',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
<<<<<<< HEAD
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
=======
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
                ),
                maxLines: 5,
                readOnly: true, // Make this field read-only
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
<<<<<<< HEAD
              children: [],
=======
              children: [

              ],
>>>>>>> 87d6d667abd9c0d97bd9813d7cd7bfc56a7ad382
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNextPage,
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

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
