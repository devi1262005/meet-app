import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class SavedAgenda extends StatefulWidget {
  const SavedAgenda({super.key});

  @override
  State<SavedAgenda> createState() => _SavedAgendaState();
}

class _SavedAgendaState extends State<SavedAgenda> {
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
          'Saved Agenda',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: List.generate(6, (index) {
            return GestureDetector(
              onTap: () {
                // Navigate to the Detail Page when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(itemIndex: index + 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Item ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// A simple detail page that shows the clicked item
class DetailPage extends StatelessWidget {
  final int itemIndex;

  const DetailPage({super.key, required this.itemIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Item $itemIndex Details',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
          ),
        ),
        
      ),
      body: Center(
        child: Text(
          'Details of Item $itemIndex',
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.purple.shade800,
          ),
        ),
      ),
    );
  }
}
