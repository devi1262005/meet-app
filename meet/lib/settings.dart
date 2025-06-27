import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _notificationsEnabled = true;
  String _selectedTheme = 'Light';
  bool _autoJoinAudio = true;
  bool _muteOnEntry = true;
  bool _showSubtitles = true;
  bool _autoRecordMeeting = false;
  String _selectedVideoQuality = 'Auto';
  double _micVolume = 0.5;
  double _speakerVolume = 0.5;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications') ?? true;
        _selectedTheme = prefs.getString('theme') ?? 'Light';
        _autoJoinAudio = prefs.getBool('autoJoinAudio') ?? true;
        _muteOnEntry = prefs.getBool('muteOnEntry') ?? true;
        _showSubtitles = prefs.getBool('showSubtitles') ?? true;
        _autoRecordMeeting = prefs.getBool('autoRecordMeeting') ?? false;
        _selectedVideoQuality = prefs.getString('videoQuality') ?? 'Auto';
        _micVolume = prefs.getDouble('micVolume') ?? 0.5;
        _speakerVolume = prefs.getDouble('speakerVolume') ?? 0.5;
        _selectedLanguage = prefs.getString('language') ?? 'English';
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', _notificationsEnabled);
      await prefs.setString('theme', _selectedTheme);
      await prefs.setBool('autoJoinAudio', _autoJoinAudio);
      await prefs.setBool('muteOnEntry', _muteOnEntry);
      await prefs.setBool('showSubtitles', _showSubtitles);
      await prefs.setBool('autoRecordMeeting', _autoRecordMeeting);
      await prefs.setString('videoQuality', _selectedVideoQuality);
      await prefs.setDouble('micVolume', _micVolume);
      await prefs.setDouble('speakerVolume', _speakerVolume);
      await prefs.setString('language', _selectedLanguage);
    } catch (e) {
      print('Error saving settings: $e');
    }
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
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.purple.shade800,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Meeting Preferences'),
          SwitchListTile(
            title: const Text('Auto-join Audio'),
            subtitle: const Text('Automatically join audio when entering meetings'),
            value: _autoJoinAudio,
            onChanged: (bool value) {
              setState(() {
                _autoJoinAudio = value;
                _saveSettings();
              });
            },
            secondary: const Icon(Icons.headset),
          ),
          SwitchListTile(
            title: const Text('Mute on Entry'),
            subtitle: const Text('Automatically mute microphone when joining'),
            value: _muteOnEntry,
            onChanged: (bool value) {
              setState(() {
                _muteOnEntry = value;
                _saveSettings();
              });
            },
            secondary: const Icon(Icons.mic_off),
          ),
          SwitchListTile(
            title: const Text('Show Subtitles'),
            subtitle: const Text('Enable live captions during meetings'),
            value: _showSubtitles,
            onChanged: (bool value) {
              setState(() {
                _showSubtitles = value;
                _saveSettings();
              });
            },
            secondary: const Icon(Icons.closed_caption),
          ),
          SwitchListTile(
            title: const Text('Auto-record Meeting'),
            subtitle: const Text('Automatically start recording when hosting'),
            value: _autoRecordMeeting,
            onChanged: (bool value) {
              setState(() {
                _autoRecordMeeting = value;
                _saveSettings();
              });
            },
            secondary: const Icon(Icons.fiber_manual_record),
          ),
          _buildSectionHeader('Audio & Video'),
          ListTile(
            title: const Text('Video Quality'),
            subtitle: Text(_selectedVideoQuality),
            leading: const Icon(Icons.high_quality),
            onTap: () => _selectVideoQuality(context),
          ),
          ListTile(
            title: const Text('Audio Settings'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Microphone'),
                Slider(
                  value: _micVolume,
                  onChanged: (value) {
                    setState(() {
                      _micVolume = value;
                      _saveSettings();
                    });
                  },
                ),
                const Text('Speaker'),
                Slider(
                  value: _speakerVolume,
                  onChanged: (value) {
                    setState(() {
                      _speakerVolume = value;
                      _saveSettings();
                    });
                  },
                ),
              ],
            ),
            leading: const Icon(Icons.volume_up),
          ),
          _buildSectionHeader('General Settings'),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Enable meeting reminders and updates'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
                _saveSettings();
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            leading: const Icon(Icons.language),
            onTap: () => _selectLanguage(context),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_selectedTheme),
            leading: const Icon(Icons.color_lens),
            onTap: () => _selectTheme(context),
          ),
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description),
            onTap: () {
              // Navigate to Terms of Service
            },
          ),
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.purple.shade800,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _selectVideoQuality(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Video Quality'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Auto'),
                value: 'Auto',
                groupValue: _selectedVideoQuality,
                onChanged: (String? value) {
                  setState(() {
                    _selectedVideoQuality = value!;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('High Definition'),
                value: 'HD',
                groupValue: _selectedVideoQuality,
                onChanged: (String? value) {
                  setState(() {
                    _selectedVideoQuality = value!;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Standard Definition'),
                value: 'SD',
                groupValue: _selectedVideoQuality,
                onChanged: (String? value) {
                  setState(() {
                    _selectedVideoQuality = value!;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'English',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Spanish'),
                value: 'Spanish',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('French'),
                value: 'French',
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  setState(() {
                    _selectedLanguage = value!;
                    _saveSettings();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                RadioListTile<String>(
                  title: const Text('Light'),
                  value: 'Light',
                  groupValue: _selectedTheme,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTheme = value!;
                    _saveSettings();
                    });
                  Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Dark'),
                  value: 'Dark',
                  groupValue: _selectedTheme,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTheme = value!;
                    _saveSettings();
                    });
                  Navigator.pop(context);
                  },
                ),
              ],
          ),
        );
      },
    );
  }
}
