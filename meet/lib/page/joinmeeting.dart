import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:meet/page/waiting.dart';

class Joinmeet extends StatefulWidget {
  const Joinmeet({super.key});

  @override
  State<Joinmeet> createState() => _JoinmeetState();
}

class _JoinmeetState extends State<Joinmeet> {
  String? selectedCategory;
  bool isToggled = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Join Meeting',
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
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            height: 1.0,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Meeting Name',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(1, 1),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Meeting Code',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(1, 1),
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
                      child: Icon(Icons.confirmation_num, color: Colors.grey.shade600),
                    ),
                    hintText: '000 000',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  ),
                  maxLines: 1,
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
              context, MaterialPageRoute(builder: (context) => const Waiting()));
        },
        backgroundColor: Colors.purple.shade800,
        shape: const CircleBorder(),
        child: const FaIcon(
          FontAwesomeIcons.play,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
