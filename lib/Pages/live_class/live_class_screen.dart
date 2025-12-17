import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

import 'participant_tile.dart';

class LiveClassScreen extends StatefulWidget {
  final String roomId;
  final String token;
  final bool isInstructor;
  final String displayName; // User's name (e.g. "Instructor John")

  const LiveClassScreen({
    super.key,
    required this.roomId,
    required this.token,
    required this.isInstructor,
    required this.displayName,
  });

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  Room? _room;
  bool _joined = false;
  Map<String, Participant> _participants = {};

  @override
  void initState() {
    super.initState();
    _initMeeting();
  }

  Future<void> _initMeeting() async {
    // 1. Configure Room
    _room = VideoSDK.createRoom(
      roomId: widget.roomId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: true,
      camEnabled: true,
      defaultCameraIndex: 0, // 0 = Front Camera
    );

    // 2. Setup Listeners
    _setupRoomListeners();

    // 3. Join
    await _room!.join();
  }

  void _setupRoomListeners() {
    _room!.on(Events.roomJoined, () {
      if (mounted) setState(() => _joined = true);
    });

    _room!.on(Events.participantJoined, (Participant p) {
      if (mounted) setState(() => _participants[p.id] = p);
    });

    _room!.on(Events.participantLeft, (String participantId) {
      if (mounted) setState(() => _participants.remove(participantId));
    });

    _room!.on(Events.roomLeft, () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_joined) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Connecting to Classroom..."),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Room: ${widget.roomId}",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Video Grid
          Expanded(
            child: _participants.isEmpty
                // If alone, just show self
                ? Center(
                    child: SizedBox(
                            width: 300,
                            height: 400,
                            child: ParticipantTile(
                              participant: _room!.localParticipant,
                            ),
                          ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                    // +1 to include Local User
                    itemCount: _participants.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ParticipantTile(
                          participant: _room!.localParticipant,
                        );
                      }
                      var pId = _participants.keys.elementAt(index - 1);
                      return ParticipantTile(participant: _participants[pId]!);
                    },
                  ),
          ),

          // 2. Controls
          _buildControlBar(),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Toggle Mic
          IconButton(
            onPressed: () {
              if (_isMicOn) {
                _room!.muteMic();
              } else {
                _room!.unmuteMic();
              }
              // We rely on the event listeners to update the UI,
              // but a setState here ensures immediate feedback for the button tap.
              setState(() {});
            },
            icon: Icon(
              _isMicOn ? Icons.mic : Icons.mic_off,
              color: _isMicOn ? Colors.white : Colors.red,
            ),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),

          // End Call
          IconButton(
            onPressed: () {
              _room!.leave();
            },
            icon: const Icon(Icons.call_end, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.red),
            padding: const EdgeInsets.all(16),
          ),

          // Toggle Camera
          IconButton(
            onPressed: () {
              if (_isCamOn) {
                _room!.disableCam();
              } else {
                _room!.enableCam();
              }
              setState(() {});
            },
            icon: Icon(
              _isCamOn ? Icons.videocam : Icons.videocam_off,
              color: _isCamOn ? Colors.white : Colors.red,
            ),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
        ],
      ),
    );
  }

  // Helper to check if Local Mic is On
  bool get _isMicOn {
    if (_room?.localParticipant == null) return false;
    // Check if any audio stream exists in the streams map
    return _room!.localParticipant.streams.values.any(
      (stream) => stream.kind == 'audio',
    );
  }

  // Helper to check if Local Camera is On
  bool get _isCamOn {
    if (_room?.localParticipant == null) return false;
    // Check if any video stream exists in the streams map
    return _room!.localParticipant.streams.values.any(
      (stream) => stream.kind == 'video',
    );
  }
}
