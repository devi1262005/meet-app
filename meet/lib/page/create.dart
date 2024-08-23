import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/call.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  String? selectedCategory;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Create Meeting',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.angleLeft,
            color: Colors.purple.shade800,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            height: 1.0,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Adjust padding
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Adjust padding
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
                  decoration: InputDecoration(
                    hintText: 'Enter meeting name',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0), // Adjust padding
                  ),
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your onPressed functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 224, 216, 216),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  ),
                  child: Text(
                    'Generate',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed functionality here
            Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => create()));
        },
        backgroundColor: Colors.purple.shade800,
        child: FaIcon(
          FontAwesomeIcons.play,
          color: Colors.white,
        ),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
