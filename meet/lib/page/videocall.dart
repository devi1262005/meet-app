import 'package:flutter/material.dart';
import 'package:meet/page/Home.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _isCameraSwitched = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoOff = !_isVideoOff;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _switchCamera() {
    setState(() {
      _isCameraSwitched = !_isCameraSwitched;
    });
  }

  void _endCall() {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Call'),
          content: const Text('Do you want to end the call?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                   Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
                // Add logic to end the call
                print('Call ended');
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/user_avatar.png'), // Replace with your image
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Team Meeting',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 28.0,
            ),
            onPressed: () {
              // Add more options functionality here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Stream Box
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                _isVideoOff
                    ? Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white,
                          size: 100.0,
                        ),
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Text(
                            'Video Stream',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          // Participant Box
          Container(
            color: Colors.black,
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              children: [
                _buildParticipant(),
                const SizedBox(width: 10),
                _buildParticipant(),
                const SizedBox(width: 10),
                _buildParticipant(),
              ],
            ),
          ),
          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildControlButton(
                  onPressed: _toggleMute,
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.white,
                ),
                _buildControlButton(
                  onPressed: _toggleVideo,
                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                  color: _isVideoOff ? Colors.red : Colors.white,
                ),
                _buildControlButton(
                  onPressed: _toggleSpeaker,
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  color: _isSpeakerOn ? Colors.white : Colors.red,
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
                  isEndCall: true,
                  
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipant() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white, width: 2.0),
        image: const DecorationImage(
          image: AssetImage('assets/images/avatar.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    bool isEndCall = false,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: isEndCall ? Colors.grey[800] : Colors.grey[800],
      child: Icon(
        icon,
        color: color,
        size: 28.0,
      ),
    );
  }
}
