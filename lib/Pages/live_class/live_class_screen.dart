import 'dart:async';

import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

import 'chat_view.dart';

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
  // --- SDK STATE ---
  Room? _room;
  bool _joined = false;
  Participant? _instructor;
  Stream? _instructorVideoStream;
  final Map<String, Participant> _participants = {};

  // --- UI STATE ---
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initMeeting();
    _resetControlsTimer(); // Start timer to auto-hide initially
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    if (_room != null) {
      _room!.leave();
    }
    super.dispose();
  }

  // --- UI CONTROL LOGIC ---
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _resetControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  // --- SDK INITIALIZATION ---
  Future<void> _initMeeting() async {
    _room = VideoSDK.createRoom(
      roomId: widget.roomId,
      token: widget.token,
      displayName: widget.displayName,
      micEnabled: false,
      camEnabled: false,
      defaultCameraIndex: 0,
    );

    _setupRoomListeners();
    await _room!.join();
  }

  void _setupRoomListeners() {
    _room!.on(Events.roomJoined, () {
      if (mounted) setState(() => _joined = true);
      _room!.participants.forEach((key, p) {
        setState(() => _participants[p.id] = p);
        _handleParticipant(p);
      });
    });

    _room!.on(Events.participantJoined, (Participant p) {
      setState(() => _participants[p.id] = p);
      _handleParticipant(p);
    });

    _room!.on(Events.participantLeft, (String participantId) {
      if (mounted) {
        setState(() {
          _participants.remove(participantId);
          if (_instructor?.id == participantId) {
            _instructor = null;
            _instructorVideoStream = null;
          }
        });
      }
    });

    _room!.on(Events.roomLeft, () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _handleParticipant(Participant p) {
    p.streams.forEach((key, stream) {
      if (_isVisualStream(stream)) {
        setState(() {
          _instructor = p;
          _instructorVideoStream = stream;
        });
      }
    });

    p.on(Events.streamEnabled, (Stream stream) {
      if (_isVisualStream(stream)) {
        if (mounted) {
          setState(() {
            _instructor = p;
            _instructorVideoStream = stream;
          });
        }
      }
    });

    p.on(Events.streamDisabled, (Stream stream) {
      if (_isVisualStream(stream) && _instructorVideoStream?.id == stream.id) {
        if (mounted) {
          setState(() => _instructorVideoStream = null);
          // Retry check for race conditions
          p.streams.forEach((key, s) {
            if (_isVisualStream(s) && s.id != stream.id) {
              setState(() => _instructorVideoStream = s);
            }
          });
        }
      }
    });
  }

  bool _isVisualStream(Stream stream) {
    return stream.kind == 'video' ||
        stream.kind == 'share' ||
        stream.kind == 'screen';
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    // Note: We use a Stack to layer Controls ON TOP of Video
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // LAYER 1: The Video (Full Screen Tap Detector)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleControls,
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: _buildVideoContent(),
              ),
            ),
          ),

          // LAYER 2: Top Bar (Animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -100,
            // Hide by moving up
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // LAYER 3: Bottom Bar (Animated)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -100,
            // Hide by moving down
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildVideoContent() {
    if (!_joined) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    // Fallback check
    if (_instructor != null && _instructorVideoStream == null) {
      try {
        final fallback = _instructor!.streams.values.firstWhere(
          (s) => _isVisualStream(s),
        );
        _instructorVideoStream = fallback;
      } catch (e) {
        // No stream
      }
    }

    // 1. VIDEO VIEW
    if (_instructor != null && _instructorVideoStream != null) {
      return AspectRatio(
        aspectRatio: 16 / 9, // Keep 16:9 ratio
        child: RTCVideoView(
          _instructorVideoStream!.renderer!,
          // 'contain' ensures the whole whiteboard is visible without cropping
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        ),
      );
    }

    // 2. AUDIO ONLY VIEW
    if (_instructor != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[800],
            child: Text(
              _instructor!.displayName.isNotEmpty
                  ? _instructor!.displayName.substring(0, 1).toUpperCase()
                  : "I",
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${_instructor!.displayName} (Audio Only)",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Waiting for video feed...",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    }

    // 3. WAITING VIEW
    return const Text(
      "Waiting for Instructor...",
      style: TextStyle(color: Colors.white54),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8, // Safe Area
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.transparent,
          ], // Gradient for visibility
        ),
      ),
      child: Row(
        children: [
          // const Icon(Icons.live_tv, color: Colors.red, size: 20),
          // const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "LIVE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Live Class",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Important for keyboard view
                backgroundColor: Colors.transparent,
                builder: (context) => ChatView(room: _room!),
              );
            },
            tooltip: "Chat",
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
            onPressed: _showParticipantsSheet,
            tooltip: "Classmates",
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                _room!.leave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_end, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Leave",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipantsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final users = _participants.values.toList();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Classmates (${users.length})",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: users.isEmpty
                    ? const Center(
                        child: Text(
                          "No other students yet.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final p = users[index];
                          if (p.id == _instructor?.id)
                            return const SizedBox.shrink();
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                p.displayName.isNotEmpty
                                    ? p.displayName
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : "?",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              p.displayName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 12,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
