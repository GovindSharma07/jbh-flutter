import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'participant_tile.dart';

class LiveClassScreen extends StatefulWidget {
  final String roomId;
  final String token;
  final String displayName;

  const LiveClassScreen({
    super.key,
    required this.roomId,
    required this.token,
    required this.displayName,
  });

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  Room? _room;
  bool _joined = false;
  Map<String, Participant> _participants = {};

  // -- PAGINATION & UI STATE --
  int _currentPage = 0;
  final int _itemsPerPage = 4; // Number of videos per page

  // Local state for instantaneous button feedback
  bool _localMicState = false;
  bool _localCamState = false;

  @override
  void initState() {
    super.initState();
    _initMeeting();
  }

  @override
  void dispose() {
    // Clean up room listeners if needed
    super.dispose();
  }

  Future<void> _initMeeting() async {
    // 1. Configure Room (Mic & Cam OFF by default)
    _room = VideoSDK.createRoom(
      roomId: widget.roomId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: false, // Default Closed
      camEnabled: false, // Default Closed
      defaultCameraIndex: 0,
    );

    // Initialize local state to match config
    _localMicState = false;
    _localCamState = false;

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
      if (mounted) {
        setState(() {
          _participants.remove(participantId);
          // Adjust page if empty
          if (_participants.length < _currentPage * _itemsPerPage) {
            if(_currentPage > 0) _currentPage--;
          }
        });
      }
    });

    _room!.on(Events.roomLeft, () {
      if (mounted) Navigator.pop(context);
    });

    // Listen for real stream changes to keep local state in sync (failsafe)
    _room!.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'audio') setState(() => _localMicState = true);
      if (stream.kind == 'video') setState(() => _localCamState = true);
    });

    _room!.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'audio') setState(() => _localMicState = false);
      if (stream.kind == 'video') setState(() => _localCamState = false);
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

    // --- PAGINATION LOGIC ---
    // Create a single list of ALL participants (Local + Remote)
    final List<Participant> allUsers = [
      _room!.localParticipant,
      ..._participants.values
    ];

    final int totalItems = allUsers.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();

    // Ensure current page is valid
    if (_currentPage >= totalPages && totalPages > 0) _currentPage = totalPages - 1;
    if (_currentPage < 0) _currentPage = 0;

    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage < totalItems)
        ? startIndex + _itemsPerPage
        : totalItems;

    // Get the slice of users for the current page
    final List<Participant> pageUsers = (totalItems > 0)
        ? allUsers.sublist(startIndex, endIndex)
        : [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Room: ${widget.roomId} (Page ${_currentPage + 1}/$totalPages)"),
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
            child: pageUsers.isEmpty
                ? const Center(child: Text("No Participants", style: TextStyle(color: Colors.white)))
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: pageUsers.length,
              itemBuilder: (context, index) {
                final p = pageUsers[index];
                return ParticipantTile(
                  // KEY IS CRITICAL FOR PREVENTING LAG/REBUILDS
                  key: ValueKey(p.id),
                  participant: p,
                  isLocal: p.id == _room!.localParticipant.id,
                );
              },
            ),
          ),

          // 2. Pagination Controls
          if (totalPages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  "Page ${_currentPage + 1} of $totalPages",
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),

          // 3. Controls
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
              // Optimistic Update
              setState(() => _localMicState = !_localMicState);

              if (_localMicState) {
                _room!.unmuteMic();
              } else {
                _room!.muteMic();
              }
            },
            icon: Icon(
              _localMicState ? Icons.mic : Icons.mic_off,
              color: _localMicState ? Colors.white : Colors.red,
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
          // Toggle Camera
          IconButton(
            onPressed: () async {
              // 1. Optimistic Update
              setState(() => _localCamState = !_localCamState);

              if (_localCamState) {
                try {
                  // ALWAYS use low/standard quality for mobile students to save data/battery
                  CustomVideoTrackConfig config = CustomVideoTrackConfig.h180p_w320p;

                  CustomTrack? track = await VideoSDK.createCameraVideoTrack(
                    encoderConfig: config,
                    multiStream: false,
                  );

                  // 3. Enable Cam with the created track
                  if (track != null) {
                    _room!.enableCam(track);
                  } else {
                    print("Error: Camera track creation returned null");
                    setState(() => _localCamState = false); // Revert UI
                  }

                } catch (e) {
                  print("Error starting camera: $e");
                  setState(() => _localCamState = false); // Revert UI
                }
              } else {
                _room!.disableCam();
              }
            },
            icon: Icon(
              _localCamState ? Icons.videocam : Icons.videocam_off,
              color: _localCamState ? Colors.white : Colors.red,
            ),
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
          ),
        ],
      ),
    );
  }
}