import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'videocall.dart'; // Import your VideoCallPage

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _CreateState();
}

class _CreateState extends State<Schedule> {
  String? selectedCategory;
  final TextEditingController _meetingNameController = TextEditingController();
  final TextEditingController _participantCountController = TextEditingController();
  final TextEditingController _agendaGeneratorController = TextEditingController();
  final TextEditingController _agendaDetailsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isEditable = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));

    // Set initial values for date and time controllers
    _dateController.text = '${_selectedDate.toLocal()}'.split(' ')[0];
    _timeController.text = _selectedTime.format(context);
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = '${_selectedDate.toLocal()}'.split(' ')[0]; // Update the text field
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = _selectedTime.format(context); // Update the text field
      });
    }
  }

  Future<void> _generateAgenda() async {
    String meetingName = _meetingNameController.text;
    String participantCount = _participantCountController.text;
    String agendaDetails = _agendaGeneratorController.text;
    String selectedCat = selectedCategory ?? '';

    // Format date and time
    String formattedDate = _dateController.text;
    String formattedTime = _timeController.text;

    Map<String, dynamic> requestBody = {
      "meeting_name": meetingName,
      "participant_count": participantCount,
      "agenda": "Generate agenda for $agendaDetails",
      "agenda_details": agendaDetails,
      "category": selectedCat,
      "date": formattedDate,
      "time": formattedTime,
    };

    final response = await http.post(
      Uri.parse('http://192.168.53.46:5001/generate_agenda'), // Replace with your API URL
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
    _dateController.dispose();
    _timeController.dispose();
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
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Schedule Meeting',
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
                controller: _participantCountController,
                labelText: 'Participant Count',
                hintText: 'Participant Count',
                icon: Icons.people,
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),

              // Date picker text field with icon
              _buildTextField(
                controller: _dateController,
                labelText: 'Date',
                hintText: 'Pick Date',
                icon: Icons.calendar_today,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 10),

              // Time picker text field with icon
              _buildTextField(
                controller: _timeController,
                labelText: 'Time',
                hintText: 'Pick Time',
                icon: Icons.access_time,
                readOnly: true,
                onTap: _pickTime,
              ),
              const SizedBox(height: 15),

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
                    backgroundColor: Colors.purple.shade800,
                  ),
                  child: Text(
                    'Generate',
                    style: TextStyle(fontSize: 14, color: Colors.white),
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
              SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: false, // Add your logic here
                    onChanged: (value) {
                      // Add your logic here
                    },
                  ),
                  Text('Save Agenda'),
                ],
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VideoCallPage()),
          );
        },
        backgroundColor: Colors.purple.shade800,
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
    VoidCallback? onTap,
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  maxLines: maxLines,
                  readOnly: readOnly,
                  onTap: onTap,
                ),
              ),
              if (hasEditIcon)
                GestureDetector(
                  onTap: _toggleEditable,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.edit, color: Colors.grey.shade600),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
