import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';

class ParticipantTile extends StatefulWidget {
  final Participant participant;

  const ParticipantTile({super.key, required this.participant});

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  Stream? _videoStream;
  Stream? _audioStream;

  @override
  void initState() {
    super.initState();
    _initStreams();
    _addListeners();
  }

  void _initStreams() {
    // Check initially active streams
    widget.participant.streams.forEach((key, stream) {
      if (stream.kind == 'video') {
        _videoStream = stream;
      } else if (stream.kind == 'audio') {
        _audioStream = stream;
      }
    });
  }

  void _addListeners() {
    widget.participant.on(Events.streamEnabled, (Stream stream) {
      if (mounted) {
        setState(() {
          if (stream.kind == 'video') {
            _videoStream = stream;
          } else if (stream.kind == 'audio') {
            _audioStream = stream;
          }
        });
      }
    });

    widget.participant.on(Events.streamDisabled, (Stream stream) {
      if (mounted) {
        setState(() {
          if (stream.kind == 'video') {
            _videoStream = null;
          } else if (stream.kind == 'audio') {
            _audioStream = null;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          // 1. Video Layer
          if (_videoStream != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: RTCVideoView(
                _videoStream!.renderer!,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            )
          else
            const Center(
              child: Icon(Icons.person, size: 50, color: Colors.grey),
            ),

          // 2. Name Tag
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.participant.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

          // 3. Mic Status Icon
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              _audioStream == null ? Icons.mic_off : Icons.mic,
              color: _audioStream == null ? Colors.red : Colors.green,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}