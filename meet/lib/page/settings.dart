import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _CreateState();
}

class _CreateState extends State<Setting> {
  bool _notificationsEnabled = true;
  String _selectedTheme = 'Light';
  bool _locationEnabled = false;
  double _micVolume = 0.5; // Volume level for Mic from 0.0 to 1.0
  double _speakerVolume = 0.5; // Volume level for Speaker from 0.0 to 1.0

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
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: Colors.purple.shade800,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
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
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_selectedTheme),
            leading: const Icon(Icons.color_lens),
            onTap: () {
              _selectTheme(context);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Location'),
            value: _locationEnabled,
            onChanged: (bool value) {
              setState(() {
                _locationEnabled = value;
              });
            },
            secondary: const Icon(Icons.location_on),
          ),
          ListTile(
            title: Row(
              children: const [
                Icon(Icons.volume_up),
                SizedBox(width: 8), // Space between icon and text
                Text('Audio'),
              ],
            ),
            onTap: () {
              // Navigate to Audio settings page
            },
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30.0), // Left padding for "Mic"
                  child: const Text('Mic'),
                ),
                Slider(
                  value: _micVolume,
                  onChanged: (double value) {
                    setState(() {
                      _micVolume = value;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(_micVolume * 100).toInt()}%',
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0), // Left padding for "Speaker"
                  child: const Text('Speaker'),
                ),
                Slider(
                  value: _speakerVolume,
                  onChanged: (double val) {
                    setState(() {
                      _speakerVolume = val;
                    });
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(_speakerVolume * 100).toInt()}%',
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Account'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // Navigate to Account settings page
            },
          ),
          ListTile(
            title: const Text('Privacy'),
            leading: const Icon(Icons.lock),
            onTap: () {
              // Navigate to Privacy settings page
            },
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              // Navigate to About page
            },
          ),
        ],
      ),
    );
  }

  void _selectTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RadioListTile<String>(
                  title: const Text('Light'),
                  value: 'Light',
                  groupValue: _selectedTheme,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Dark'),
                  value: 'Dark',
                  groupValue: _selectedTheme,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
