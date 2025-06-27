import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'endofmeet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

class VideoCallPage extends StatefulWidget {
  final Map<String, dynamic> meeting;

  const VideoCallPage({super.key, required this.meeting});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isCameraSwitched = false;
  String _selectedTab = 'participants';
  List<String> _participants = [];
  List<String> _coHosts = [];
  List<String> _aiSuggestions = [];
  List<String> _meetingSubtitles = [];
  late RTCPeerConnection _peerConnection;
  MediaStream? _localStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late FlutterSoundRecorder _recorder;
  String? _recordedFilePath;
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _currentSubtitle = '';
  bool _isListening = false;
  bool _isAgendaVisible = false;
  final ScrollController _agendaScrollController = ScrollController();
  bool _isDisposed = false;
  bool _isInternetSlow = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _subtitleTimer;
  bool _isSubtitleProcessing = false;
  String _currentUserId = '';
  String _hostId = '';
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String _recordingStatus = '';
  Duration _meetingDuration = Duration.zero;
  Timer? _meetingTimer;
  String _userName = '';
  String _userInitial = '';

  // Add new variables for WebRTC
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, MediaStream> _remoteStreams = {};
  bool _isConnectionEstablished = false;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final Map<String, RTCDataChannel> _dataChannels = {};
  final List<Map<String, dynamic>> _sharedFiles = [];
  bool _isFileSending = false;
  Map<String, dynamic> _fileChunks = {};

  // Add these variables at the top of the class
  List<String> _agendaItems = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userName = user?.displayName ?? 'User';
    _userInitial = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';
    _currentUserId = user?.uid ?? '';

    // Initialize WebRTC
    if (!kIsWeb) {
    _initializeResources();
    }

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    _loadParticipants();
    _setupWebRTC();
    _startMeetingTimer();
    _initializeSpeech();
    _initializeAgendaItems();
    _fetchAISuggestions();
  }

  void _monitorConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      if (results.isEmpty) {
        setState(() => _isInternetSlow = true);
        return;
      }

      // Check the first connectivity result
      final result = results.first;
      if (result == ConnectivityResult.none) {
        setState(() => _isInternetSlow = true);
      } else {
        // Check internet speed
        try {
          final stopwatch = Stopwatch()..start();
          await InternetAddress.lookup('google.com');
          stopwatch.stop();
          setState(() => _isInternetSlow = stopwatch.elapsedMilliseconds > 500);
        } catch (e) {
          setState(() => _isInternetSlow = true);
        }
      }
    });
  }

  Future<void> _initializeResources() async {
    try {
      print('Initializing resources...');
      await _initializeRenderer();
      print('Renderer initialized');
      await _initializeWebRTC();
      print('WebRTC initialized');
      await _initializeRecorder();
      print('Recorder initialized');
      await _updateMeetingStatus(true);
      print('Meeting status updated');
    } catch (e) {
      print('Error initializing resources: $e');
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing video call: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _initializeRenderer() async {
    try {
    await _localRenderer.initialize();
    } catch (e) {
      print('Error initializing renderer: $e');
      throw e;
    }
  }

  Future<void> _initializeWebRTC() async {
    try {
      // Request permissions first
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();

      bool micGranted = statuses[Permission.microphone]?.isGranted ?? false;
      bool camGranted = statuses[Permission.camera]?.isGranted ?? false;

      if (!micGranted || !camGranted) {
        if (!_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera and microphone permissions are required'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isMuted = !micGranted;
          _isVideoOff = !camGranted;
        });
        return; // Don't proceed if permissions not granted
      }

      // Configure media constraints
      final Map<String, dynamic> mediaConstraints = {
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        }
      };

      try {
        // Get user media
        _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

        if (!_isDisposed && _localStream != null) {
          // Set up local renderer
          await _localRenderer.initialize();
    _localRenderer.srcObject = _localStream;

          // Set up video track
          final videoTracks = _localStream!.getVideoTracks();
          if (videoTracks.isNotEmpty) {
            final videoTrack = videoTracks[0];
            videoTrack.enabled = !_isVideoOff;
          }

          // Set up audio track
          final audioTracks = _localStream!.getAudioTracks();
          if (audioTracks.isNotEmpty) {
            final audioTrack = audioTracks[0];
            audioTrack.enabled = !_isMuted;
          }

          setState(() {
            _isVideoOff = false;
            _isMuted = false;
          });
      }
    } catch (e) {
        print('Error getting user media: $e');
        setState(() {
      _isVideoOff = true;
          _isMuted = true;
        });
        if (!_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to access camera/microphone: $e')),
          );
        }
      }
    } catch (e) {
      print('Error in WebRTC initialization: $e');
      if (!_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing video call: $e')),
        );
      }
    }
  }

  Future<void> _initializeRecorder() async {
    try {
    _recorder = FlutterSoundRecorder();
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(Duration(milliseconds: 10));
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      
      if (available && mounted) {
        setState(() {
          _isListening = true;
        });
        _startListening();
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  void _startListening() {
    if (!_isListening && mounted) {
    _speech.listen(
      onResult: (result) {
          if (mounted) {
          setState(() {
            _currentSubtitle = result.recognizedWords;
              print('Current subtitle: $_currentSubtitle'); // Debug print
              if (result.finalResult) {
                _saveSubtitleToFirestore(result.recognizedWords);
              }
          });
        }
      },
      listenMode: stt.ListenMode.dictation,
        partialResults: true,
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
    setState(() {
        _isListening = false;
    });
    }
  }

  Future<void> _updateMeetingStatus(bool isActive) async {
    if (_isDisposed) return;
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('meetings')
          .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
          .get();

        if (querySnapshot.docs.isNotEmpty && !_isDisposed) {
        final meetingDoc = querySnapshot.docs.first;
        await meetingDoc.reference.update({
            'is_active': isActive,
            'ended_at': isActive ? null : FieldValue.serverTimestamp(),
          });
        }
    } catch (e) {
      print('Error updating meeting status: $e');
    }
  }

  void _toggleMute() async {
    if (_isDisposed || _localStream == null) return;
    
    // Check microphone permission when unmuting
    if (_isMuted) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microphone permission is required'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }
    }
    
    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isNotEmpty) {
    setState(() {
      _isMuted = !_isMuted;
        audioTracks.forEach((track) {
        track.enabled = !_isMuted;
      });
    });
    }
  }

  void _toggleVideo() async {
    if (_isDisposed || _localStream == null) return;
    
    // Check camera permission when turning video on
    if (_isVideoOff) {
      final camStatus = await Permission.camera.request();
      if (!camStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera permission is required'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      }
    }
    
    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
    setState(() {
      _isVideoOff = !_isVideoOff;
        videoTracks.forEach((track) {
        track.enabled = !_isVideoOff;
      });
    });
    }
  }

  void _switchCamera() {
    if (_isDisposed || _localStream == null) return;
    
    setState(() {
      _isCameraSwitched = !_isCameraSwitched;
      _localStream!.getVideoTracks()[0].switchCamera();
    });
  }

  void _toggleAgenda() {
    if (_isDisposed) return;
    
    setState(() {
      _isAgendaVisible = !_isAgendaVisible;
    });
  }

  Future<void> _endCall() async {
    if (_isDisposed) return;
    
    // Show confirmation dialog
    final bool? shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Leave Meeting',
            style: TextStyle(
              color: Colors.purple.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to leave the meeting?',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Leave',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );

    if (shouldLeave != true) return;

    // Start cleanup immediately and navigate
    _cleanupResources();
    
    // Navigate immediately without waiting for cleanup
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Endofmeet()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _cleanupResources() async {
    if (_isDisposed) return;
    
    try {
      // Cancel timers immediately
      _meetingTimer?.cancel();
      _subtitleTimer?.cancel();
      _recordingTimer?.cancel();
      _connectivitySubscription?.cancel();
      
      // Mark as disposed immediately to prevent further updates
      _isDisposed = true;
      
      // Stop media streams immediately
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream = null;
      }
      
      // Run cleanup tasks concurrently
      await Future.wait([
        // Basic cleanup
        _speech.stop(),
        _recorder.closeRecorder(),
        _localRenderer.dispose(),
        _remoteRenderer.dispose(),
        
        // Update meeting status
        FirebaseFirestore.instance
            .collection('meetings')
            .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
            .get()
            .then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            await snapshot.docs.first.reference.update({
              'is_active': false,
              'ended_at': FieldValue.serverTimestamp(),
              if (_meetingSubtitles.isNotEmpty) 'final_subtitles': _meetingSubtitles,
              'meeting_duration': _meetingDuration.inSeconds,
            });
          }
        }).catchError((e) => print('Error updating meeting status: $e')),
      ]);

      // Cleanup WebRTC in background
      Future.microtask(() {
        _remoteRenderers.forEach((_, renderer) => renderer.dispose());
        _peerConnections.forEach((_, pc) {
          pc.close();
          pc.dispose();
        });
      });

    } catch (e) {
      print('Error in cleanup: $e');
    }
  }

  Future<void> _loadParticipants() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('meetings')
          .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final meetingData = querySnapshot.docs.first.data();
        
        // First get the host_id and fetch their email
        final hostId = meetingData['host_id'];
        if (hostId != null) {
          final hostUserDoc = await FirebaseFirestore.instance
              .collection('savedmeetings')
              .doc(hostId)
              .get();

        }

        // Get participants list and ensure current user is included
        List<String> participantIds = List<String>.from(meetingData['participants'] ?? []);
        if (!participantIds.contains(currentUser.email)) {
          participantIds.add(currentUser.email!);
          // Update Firestore with new participant
          await querySnapshot.docs.first.reference.update({
            'participants': participantIds
          });
        }

        // Make sure host's email is in the participants list
        if (_hostId.isNotEmpty && !participantIds.contains(_hostId)) {
          participantIds.add(_hostId);
        }

        final coHosts = List<String>.from(meetingData['co_hosts'] ?? []);
        
        setState(() {
          _participants = participantIds;
          _coHosts = coHosts;
        });
      }
    } catch (e) {
      print('Error loading participants: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading meeting data: $e')),
      );
    }
  }

  Future<void> _loadAiSuggestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('meetings')
          .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final meetingData = snapshot.docs.first.data();
        setState(() {
          _aiSuggestions = List<String>.from(meetingData['ai_suggestions'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading AI suggestions: $e');
    }
  }

  Future<void> _fetchAISuggestions() async {
    if (_isLoadingSuggestions) return;
    
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      // Fetch the current agenda from Firestore
      final meetingDoc = await FirebaseFirestore.instance
          .collection('meetings')
          .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
          .get();

      if (meetingDoc.docs.isEmpty) {
        setState(() {
          _aiSuggestions = ['No meeting data available'];
          _isLoadingSuggestions = false;
        });
        return;
      }

      final meetingData = meetingDoc.docs.first.data();
      final agenda = meetingData['agenda_details'] ?? '';
      
      if (agenda.isEmpty) {
        setState(() {
          _aiSuggestions = ['No agenda available for suggestions'];
          _isLoadingSuggestions = false;
        });
        return;
      }

      print('Fetching suggestions for agenda: $agenda'); // Debug print

      final response = await http.post(
        Uri.parse('https://server4-vg91.onrender.com/generate_comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'agenda': agenda}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final comments = data['comments'] as String;
        
        print('Received comments: $comments'); // Debug print
        
        // Split comments into individual suggestions
        final suggestions = comments
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
            .toList();

        setState(() {
          _aiSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      } else {
        print('API Error: ${response.statusCode} - ${response.body}'); // Debug print
        throw Exception('Failed to fetch suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching AI suggestions: $e');
      setState(() {
        _aiSuggestions = ['Unable to load suggestions at this time'];
        _isLoadingSuggestions = false;
      });
    }
  }

  void _setupParticipantsListener() {
    FirebaseFirestore.instance
        .collection('meetings')
        .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final meetingData = snapshot.docs.first.data();
        
        final participantIds = List<String>.from(meetingData['participants'] ?? []);
        final coHosts = List<String>.from(meetingData['co_hosts'] ?? []);
        
        if (!mounted) return;
        
        setState(() {
          _participants = participantIds;
          _coHosts = coHosts;
        });
      }
    }, onError: (error) {
      print('Error in participants listener: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating participants: $error')),
      );
    });
  }

  Future<void> _setCoHost(String participantId) async {
    if (!widget.meeting['is_host']) {
      print('User is not a host, cannot set co-host');
      return;
    }
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('savedmeetings')
          .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        print('No meeting found with code: ${widget.meeting['meeting_code']}');
        return;
      }
      
      final meetingDoc = querySnapshot.docs.first;
      await meetingDoc.reference.update({
        'co_hosts': FieldValue.arrayUnion([participantId])
      });
      
      setState(() {
        if (!_coHosts.contains(participantId)) {
          _coHosts.add(participantId);
        }
      });
    } catch (e) {
      print('Error setting co-host: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error setting co-host: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startSubtitleGeneration() async {
    _subtitleTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_isSubtitleProcessing || _isDisposed) return;
      
      try {
        setState(() => _isSubtitleProcessing = true);
        
        // Record audio for 5 seconds
        final tempDir = await Directory.systemTemp.createTemp();
        final audioPath = '${tempDir.path}/audio.flac';
        
        await _recorder.startRecorder(
          toFile: audioPath,
          codec: Codec.flac,
        );
        
        await Future.delayed(Duration(seconds: 5));
        await _recorder.stopRecorder();
        
        // Send audio to server
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://server6-59m8.onrender.com/generate_sub'),
        );
        
        try {
          final audioFile = File(audioPath);
          if (await audioFile.exists()) {
        request.files.add(
              await http.MultipartFile.fromPath(
                'audio',
                audioPath,
                contentType: MediaType('audio', 'flac'),
              ),
            );

            final streamedResponse = await request.send();
            final response = await http.Response.fromStream(streamedResponse);
            
            if (response.statusCode == 200) {
              final responseBody = response.body;
              if (responseBody.isEmpty) {
                print('Empty response body received');
                return;
              }

              try {
                final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;
                final subtitleText = jsonResponse['text'] as String?;
                
                if (subtitleText != null && subtitleText.isNotEmpty) {
          setState(() {
                    _currentSubtitle = subtitleText;
                    _meetingSubtitles.add(subtitleText);
                  });

                  // Save subtitles to Firestore
                  try {
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('meetings')
                        .where('meeting_code', isEqualTo: widget.meeting['meeting_code'])
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      final meetingDoc = querySnapshot.docs.first;
                      await meetingDoc.reference.update({
                        'subtitles': FieldValue.arrayUnion([{
                          'text': subtitleText,
                          'timestamp': FieldValue.serverTimestamp(),
                        }]),
                      });
                    }
                  } catch (e) {
                    print('Error saving subtitle to Firestore: $e');
                  }
                } else {
                  print('No valid text in response');
                }
              } catch (e) {
                print('Error parsing response JSON: $e');
                print('Response body: $responseBody');
              }
            } else {
              print('Server returned status code: ${response.statusCode}');
              print('Response body: ${response.body}');
            }
          } else {
            print('Audio file does not exist at path: $audioPath');
          }
        } catch (e) {
          print('Error processing HTTP request: $e');
        }
        
        // Clean up
        try {
        await File(audioPath).delete();
        await tempDir.delete();
        } catch (e) {
          print('Error cleaning up temporary files: $e');
        }
      } catch (e) {
        print('Error generating subtitle: $e');
      } finally {
        setState(() => _isSubtitleProcessing = false);
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final tempDir = await Directory.systemTemp.createTemp();
      _recordedFilePath = '${tempDir.path}/meeting_recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      
      await _recorder.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.aacADTS,
      );
      
      setState(() {
        _isRecording = true;
        _recordingStatus = 'Recording...';
      });
      
      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration += Duration(seconds: 1);
        });
      });
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      _recordingTimer?.cancel();
      
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        if (await file.exists()) {
          final storage = FirebaseStorage.instance;
          final ref = storage.ref().child('meeting_recordings/${widget.meeting['meeting_code']}/${DateTime.now().millisecondsSinceEpoch}.aac');
          await ref.putFile(file);
          await file.delete();
        }
      }
      
      setState(() {
        _isRecording = false;
        _recordingStatus = 'Recording saved';
        _recordingDuration = Duration.zero;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording saved successfully')),
      );
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recording: $e')),
      );
    }
  }

  void _startMeetingTimer() {
    // Cancel existing timer if any
    _meetingTimer?.cancel();
    
    // Reset duration
    setState(() {
      _meetingDuration = Duration.zero;
    });
    
    // Start new timer
    _meetingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isDisposed) {
        setState(() {
          _meetingDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  Future<void> _setupWebRTC() async {
    try {
      // Initialize WebRTC first
      await _initializeWebRTC();

      // Create a document for the current user in the participants collection
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meeting['meeting_code'])
          .collection('participants')
          .doc(_currentUserId)
          .set({
        'email': FirebaseAuth.instance.currentUser?.email,
        'joined_at': FieldValue.serverTimestamp(),
      });

      // Listen for new participants
      FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meeting['meeting_code'])
          .collection('participants')
          .snapshots()
          .listen((snapshot) {
        snapshot.docChanges.forEach((change) async {
          if (change.type == DocumentChangeType.added) {
            final participantId = change.doc.id;
            if (participantId != _currentUserId) {
              await _createPeerConnection(participantId);
            }
          }
        });
      });

      // Listen for WebRTC signaling
      FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meeting['meeting_code'])
          .collection('signaling')
          .snapshots()
          .listen((snapshot) {
        snapshot.docChanges.forEach((change) async {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data() as Map<String, dynamic>;
            final fromUserId = data['from'];
            final toUserId = data['to'];
            
            if (toUserId == _currentUserId) {
              if (data['type'] == 'offer') {
                await _handleOffer(fromUserId, data['sdp']);
              } else if (data['type'] == 'answer') {
                await _handleAnswer(fromUserId, data['sdp']);
              } else if (data['type'] == 'ice-candidate') {
                await _handleIceCandidate(fromUserId, data['candidate']);
              }
            }
          }
        });
      });
    } catch (e) {
      print('Error in setupWebRTC: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting up video call: $e')),
      );
    }
  }

  Future<void> _createPeerConnection(String remoteUserId) async {
    if (_peerConnections.containsKey(remoteUserId)) return;

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
        {
          'urls': 'turn:numb.viagenie.ca',
          'username': 'webrtc@live.com',
          'credential': 'muazkh'
        }
      ]
    };

    try {
      final pc = await createPeerConnection(configuration);
      _peerConnections[remoteUserId] = pc;

      // Setup data channel
      if (_currentUserId.compareTo(remoteUserId) < 0) {
        final dataChannel = await pc.createDataChannel('files', RTCDataChannelInit()
          ..ordered = true
          ..maxRetransmits = 30);
        _setupDataChannel(dataChannel, remoteUserId);
      } else {
        pc.onDataChannel = (channel) {
          _setupDataChannel(channel, remoteUserId);
        };
      }

      // Add local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          pc.addTrack(track, _localStream!);
        });
      }

      // Set up remote renderer
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      _remoteRenderers[remoteUserId] = renderer;

      // Handle ICE candidates
      pc.onIceCandidate = (candidate) async {
        if (candidate != null) {
          await _sendIceCandidate(remoteUserId, candidate);
        }
      };

      // Handle remote stream
      pc.onTrack = (event) {
        if (event.streams.isEmpty) return;
        
        final stream = event.streams[0];
        _remoteStreams[remoteUserId] = stream;
        
        if (_remoteRenderers.containsKey(remoteUserId)) {
          _remoteRenderers[remoteUserId]!.srcObject = stream;
          if (mounted) setState(() {});
        }
      };

      // Create offer if we're the initiator
      if (_currentUserId.compareTo(remoteUserId) < 0) {
        final offer = await pc.createOffer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true
        });
        await pc.setLocalDescription(offer);
        await _sendOffer(remoteUserId, offer);
      }

    } catch (e) {
      print('Error creating peer connection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to peer: $e')),
      );
    }
  }

  Future<void> _sendOffer(String remoteUserId, RTCSessionDescription offer) async {
    await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meeting['meeting_code'])
        .collection('signaling')
        .add({
      'type': 'offer',
      'from': _currentUserId,
      'to': remoteUserId,
      'sdp': offer.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _handleOffer(String fromUserId, Map<String, dynamic> sdp) async {
    final pc = _peerConnections[fromUserId];
    if (pc == null) return;

    await pc.setRemoteDescription(
      RTCSessionDescription(sdp['sdp'], sdp['type']),
    );

    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meeting['meeting_code'])
        .collection('signaling')
        .add({
      'type': 'answer',
      'from': _currentUserId,
      'to': fromUserId,
      'sdp': answer.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _handleAnswer(String fromUserId, Map<String, dynamic> sdp) async {
    final pc = _peerConnections[fromUserId];
    if (pc == null) return;

    await pc.setRemoteDescription(
      RTCSessionDescription(sdp['sdp'], sdp['type']),
    );
  }

  Future<void> _sendIceCandidate(String remoteUserId, RTCIceCandidate candidate) async {
    await FirebaseFirestore.instance
        .collection('meetings')
        .doc(widget.meeting['meeting_code'])
        .collection('signaling')
        .add({
      'type': 'ice-candidate',
      'from': _currentUserId,
      'to': remoteUserId,
      'candidate': candidate.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _handleIceCandidate(String fromUserId, Map<String, dynamic> candidateMap) async {
    final pc = _peerConnections[fromUserId];
    if (pc == null) return;

    await pc.addCandidate(
      RTCIceCandidate(
        candidateMap['candidate'],
        candidateMap['sdpMid'],
        candidateMap['sdpMLineIndex'],
      ),
    );
  }

  Future<void> _shareFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final size = file.size;

        setState(() => _isFileSending = true);

        // Send file metadata to all peers
        for (final entry in _dataChannels.entries) {
          final channel = entry.value;
          final metadata = {
            'type': 'file_metadata',
            'fileName': fileName,
            'size': size,
            'sender': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
          };
          channel.send(RTCDataChannelMessage(json.encode(metadata)));

          // Read and send file in chunks
          if (file.bytes != null) {
            const chunkSize = 16384; // 16KB chunks
            var offset = 0;
            while (offset < file.bytes!.length) {
              final chunk = file.bytes!.sublist(
                offset,
                min(offset + chunkSize, file.bytes!.length),
              );
              final chunkData = {
                'type': 'file_chunk',
                'fileName': fileName,
                'chunk': base64Encode(chunk),
                'offset': offset,
                'final': offset + chunkSize >= file.bytes!.length,
              };
              channel.send(RTCDataChannelMessage(json.encode(chunkData)));
              offset += chunkSize;
              
              // Add a small delay to prevent overwhelming the channel
              await Future.delayed(Duration(milliseconds: 10));
            }
          }
        }

        setState(() {
          _isFileSending = false;
          _sharedFiles.add({
            'fileName': fileName,
            'size': size.toString(),
            'sender': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
            'uploadedAt': DateTime.now().toIso8601String(),
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error sharing file: $e');
      setState(() => _isFileSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setupDataChannel(RTCDataChannel channel, String remoteUserId) {
    _dataChannels[remoteUserId] = channel;

    channel.onMessage = (message) {
      if (message.type == MessageType.text) {
        final data = json.decode(message.text);
        if (data['type'] == 'file_metadata') {
          setState(() {
            _sharedFiles.add({
              'fileName': data['fileName'],
              'size': data['size'],
              'sender': data['sender'],
              'uploadedAt': DateTime.now().toIso8601String(),
              'remoteUserId': remoteUserId,
            });
          });
        } else if (data['type'] == 'file_chunk') {
          _handleFileChunk(data, remoteUserId);
        }
      }
    };
  }

  void _handleFileChunk(Map<String, dynamic> data, String remoteUserId) {
    final fileName = data['fileName'];
    final chunk = base64Decode(data['chunk']);
    final offset = data['offset'];
    final isFinal = data['final'];

    if (!_fileChunks.containsKey(fileName)) {
      _fileChunks[fileName] = {
        'chunks': <int, List<int>>{},
        'size': 0,
      };
    }

    _fileChunks[fileName]['chunks'][offset] = chunk;
    _fileChunks[fileName]['size'] += chunk.length;

    if (isFinal) {
      _assembleAndSaveFile(fileName);
    }
  }

  Future<void> _assembleAndSaveFile(String fileName) async {
    try {
      final fileData = _fileChunks[fileName];
      if (fileData == null) return;

      final chunks = fileData['chunks'] as Map<int, List<int>>;
      final sortedOffsets = chunks.keys.toList()..sort();
      
      final completeData = BytesBuilder();
      for (final offset in sortedOffsets) {
        completeData.add(chunks[offset]!);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(completeData.takeBytes());

      // Clean up chunks
      _fileChunks.remove(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File received: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error assembling file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error receiving file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return Container();
    }

    final meeting = widget.meeting;
    final currentUser = FirebaseAuth.instance.currentUser;
    final userName = currentUser?.displayName ?? 'User';
    final userInitial = userName[0].toUpperCase();

    return WillPopScope(
      onWillPop: () async {
        final bool? shouldLeave = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Leave Meeting',
                style: TextStyle(
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to leave the meeting?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Leave',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            );
          },
        );

        if (shouldLeave == true) {
          await _cleanupResources();
          if (!mounted) return false;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Endofmeet()),
            (Route<dynamic> route) => false,
          );
        }
        return false;
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final bool? shouldLeave = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(
                      'Leave Meeting',
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to leave the meeting?',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          'Leave',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  );
                },
              );

              if (shouldLeave == true) {
                await _cleanupResources();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Endofmeet()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        title: Row(
          children: [
              Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      meeting['meeting_name'] ?? 'Team Meeting',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                    Row(
                      children: [
                Text(
                          '${_meetingDuration.inHours.toString().padLeft(2, '0')}:' +
                          '${(_meetingDuration.inMinutes % 60).toString().padLeft(2, '0')}:' +
                          '${(_meetingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (_isRecording)
                          Text(
                            '${_recordingDuration.inMinutes.toString().padLeft(2, '0')}:' +
                            '${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
              ),
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.fiber_manual_record : Icons.fiber_manual_record_outlined,
                  color: _isRecording ? Colors.red : Colors.white,
                  size: 28.0,
                ),
                onPressed: _toggleRecording,
              ),
          if (_isInternetSlow)
            Padding(
                  padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.wifi_off,
                color: Colors.red,
                size: 24,
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.notes,
              color: Colors.white,
              size: 28.0,
            ),
            onPressed: _toggleAgenda,
          ),
        ],
          ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
          Expanded(
            flex: 4,
              child: _remoteStreams.isEmpty
                ? _buildLocalVideoView()
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _remoteStreams.length == 1 ? 1 : 2,
                    ),
                    itemCount: _remoteStreams.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildLocalVideoView();
                      }
                      final remoteUserId = _remoteStreams.keys.elementAt(index - 1);
                      return _buildRemoteVideoView(remoteUserId);
                    },
            ),
          ),
          Container(
                  width: double.infinity,
                  color: Colors.black54,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
                  _currentSubtitle,
              style: TextStyle(
                color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildControlButton(
                  onPressed: _toggleMute,
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
                _buildControlButton(
                  onPressed: _toggleVideo,
                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                  color: Colors.white,
                ),
                _buildControlButton(
                  onPressed: _switchCamera,
                  icon: Icons.switch_camera,
                  color: Colors.white,
                ),
                _buildControlButton(
                  onPressed: _endCall,
                  icon: Icons.call_end,
                  color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isAgendaVisible)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 300,
              child: Container(
                color: Colors.black87,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meeting Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: _toggleAgenda,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton('participants', 'Participants'),
                          ),
                          Expanded(
                            child: _buildTabButton('agendas', 'Agendas'),
                          ),
                          Expanded(
                            child: _buildTabButton('suggestions', 'AI Suggestions'),
                          ),
                            Expanded(
                              child: _buildTabButton('files', 'Files'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildSelectedTabContent(),
                    ),
                  ],
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    return InkWell(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _selectedTab == tab ? Colors.purple : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _selectedTab == tab ? Colors.purple : Colors.white70,
              fontWeight: _selectedTab == tab ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTab) {
      case 'participants':
        return ListView.builder(
          itemCount: _participants.length,
          itemBuilder: (context, index) {
            final participantEmail = _participants[index];
            final isCurrentUser = participantEmail == _currentUserId;
            final isCoHost = _coHosts.contains(participantEmail);
            final isHost = _participants.length == 1 && isCurrentUser;
            
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade800,
                  child: Text(
                    participantEmail.split('@')[0][0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
              ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            participantEmail,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                  if (isCurrentUser) 
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.withOpacity(0.5)),
                            ),
                            child: Text(
                              'You',
                              style: TextStyle(
                                color: Colors.purple[100],
                                fontSize: 12,
                              ),
                            ),
                    ),
                ],
              ),
                    if (isHost || isCoHost)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isHost ? Colors.amber : Colors.yellow).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isHost ? Colors.amber : Colors.yellow,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isHost ? 'Host' : 'Co-Host',
                          style: TextStyle(
                            color: isHost ? Colors.amber : Colors.yellow,
                            fontSize: 12,
                            fontWeight: isHost ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: !isCurrentUser && (isHost || _coHosts.contains(_currentUserId)) ? 
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (String value) {
                      if (value == 'make_cohost') {
                        _setCoHost(participantEmail);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      if (!isCoHost)
                        PopupMenuItem<String>(
                          value: 'make_cohost',
                          child: Text('Make Co-Host'),
                        ),
                    ],
                  ) : null,
              ),
            );
          },
        );
      case 'agendas':
        return Column(
          children: [
            if (widget.meeting['is_host'] == true)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Drag to reorder agenda items',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _agendaItems.length,
                onReorder: (int oldIndex, int newIndex) {
                  if (widget.meeting['is_host'] == true) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = _agendaItems.removeAt(oldIndex);
                      _agendaItems.insert(newIndex, item);
                    });
                  }
                },
                itemBuilder: (context, index) {
                  return Container(
                    key: ValueKey(_agendaItems[index]),
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.meeting['is_host'] == true)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.drag_handle, color: Colors.grey[400]),
                          ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _agendaItems[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 1,
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      case 'suggestions':
        return Column(
          children: [
            if (_isLoadingSuggestions)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Generating suggestions...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_aiSuggestions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No suggestions available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
          itemCount: _aiSuggestions.length,
          itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.grey[900],
                      child: ListTile(
                        leading: Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                        ),
                        title: Text(
                          _aiSuggestions[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _isLoadingSuggestions ? null : _fetchAISuggestions,
                icon: Icon(Icons.refresh),
                label: Text('Refresh Suggestions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      case 'files':
        return _buildFilesTab();
      default:
        return Container();
    }
  }

  Widget _buildTimelineItem(String title, String status, IconData icon, Color color, {
    required Key key,
    bool showDragHandle = false,
  }) {
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDragHandle)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.drag_handle,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }

  Widget _buildFilesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _isFileSending ? null : _shareFile,
            icon: Icon(_isFileSending ? Icons.hourglass_empty : Icons.upload_file),
            label: Text(_isFileSending ? 'Sending...' : 'Share File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: _sharedFiles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No files shared yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _sharedFiles.length,
                itemBuilder: (context, index) {
                  final fileData = _sharedFiles[index];
                  final fileName = fileData['fileName'] as String;
                  final sender = fileData['sender'] as String;
                  final uploadTime = DateTime.parse(fileData['uploadedAt']);

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: Icon(_getFileIcon(fileName), color: Colors.purple),
                      title: Text(
                        fileName,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Shared by: $sender\n${_formatDate(uploadTime)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildLocalVideoView() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: !_isVideoOff && _localStream != null
        ? RTCVideoView(
            _localRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple,
                  child: Text(
                    _userInitial,
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildRemoteVideoView(String remoteUserId) {
    final renderer = _remoteRenderers[remoteUserId];
    final stream = _remoteStreams[remoteUserId];
    
    if (renderer == null || stream == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Center(
          child: Text(
            'Connecting...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: RTCVideoView(
        renderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: true,
      ),
    );
  }

  @override
  void dispose() {
    _meetingTimer?.cancel();
    _subtitleTimer?.cancel();
    _connectivitySubscription?.cancel();
    _cleanupResources();
    _agendaScrollController.dispose();
    _peerConnections.forEach((_, pc) => pc.dispose());
    _remoteRenderers.forEach((_, renderer) => renderer.dispose());
    _stopListening();
    _speech.stop();
    _isListening = false;
    super.dispose();
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Add this method to initialize agenda items
  void _initializeAgendaItems() {
    final agendaDetails = widget.meeting['agenda_details']?.toString() ?? '';
    setState(() {
      _agendaItems = agendaDetails
          .split('\n')
          .where((item) => item.trim().isNotEmpty)
          .toList();
    });
  }

  // Add this method to save subtitles to Firestore
  Future<void> _saveSubtitleToFirestore(String subtitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meeting['meeting_code'])
          .collection('subs')
          .add({
        'text': subtitle,
        'timestamp': FieldValue.serverTimestamp(),
        'speaker': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
      });
    } catch (e) {
      print('Error saving subtitle: $e');
    }
  }
}
