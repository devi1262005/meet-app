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
      Uri.parse('http://10.0.2.2:5001/generate_agenda'), // Replace with your API URL
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextMeetingPage()),
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
        title: Text(
          'Create Meeting',
          style: GoogleFonts.roboto(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.black87),
            onPressed: _navigateToNextPage,
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            SizedBox(height: 40),
            _buildTextField(
              controller: _meetingNameController,
              labelText: 'Meeting Name',
              hintText: 'Enter Meeting Name',
              icon: Icons.text_format,
            ),
            SizedBox(height: 15),
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
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _generateAgenda,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Generate',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildTextField(
              controller: _agendaDetailsController,
              labelText: 'Agenda Details',
              hintText: 'Generated Agenda Details',
              icon: Icons.text_fields,
              maxLines: 5,
              readOnly: true,
            ),
            SizedBox(height: 20),
            _buildEditButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool readOnly = false,
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
      ],
    );
  }

  Widget _buildDropdownField() {
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
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            ),
            items: <String>['Category 1', 'Category 2', 'Category 3']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton.icon(
      onPressed: _editAgenda,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.orange.shade700,
      ),
      icon: Icon(FontAwesomeIcons.penToSquare),
      label: Text(
        'Edit Agenda',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class NextMeetingPage extends StatelessWidget {
  const NextMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Meeting Page'),
      ),
      body: Center(
        child: Text('Next Meeting Page Content'),
      ),
    );
  }
}
