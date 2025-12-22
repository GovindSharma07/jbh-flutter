import 'package:flutter/material.dart';
import 'package:videosdk/videosdk.dart';
import 'package:intl/intl.dart';

class ChatView extends StatefulWidget {
  final Room room;
  const ChatView({super.key, required this.room});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  List<PubSubMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // 1. Subscribe to Topic "CHAT"
    widget.room.pubSub.subscribe("CHAT", (PubSubMessage message) {
      if (mounted) {
        setState(() => _messages.add(message));
      }
    }).then((pubSubMessages) {
      // ✅ FIX: Access the '.messages' property from the wrapper object
      if (mounted && pubSubMessages != null) {
        setState(() => _messages.addAll(pubSubMessages.messages));
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 2. Publish Message
    widget.room.pubSub.publish(
      "CHAT",
      text,
      const PubSubPublishOptions(persist: true),
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Height: 70% of screen to act as a proper bottom sheet
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Dark background matching your theme
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar (Visual Indicator for drag)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "Live Chat",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("No messages yet. Say hi!", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isLocal = msg.senderId == widget.room.localParticipant.id;

                return Align(
                  alignment: isLocal ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isLocal ? Colors.blue[700] : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12).copyWith(
                        topRight: isLocal ? Radius.zero : null,
                        topLeft: !isLocal ? Radius.zero : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isLocal)
                          Text(
                            msg.senderName,
                            style: TextStyle(color: Colors.blue[200], fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          msg.message,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('hh:mm a').format(msg.timestamp.toLocal()),
                          style: const TextStyle(color: Colors.white54, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Field Area
          Padding(
            padding: EdgeInsets.only(
                left: 16,
                right: 16,
                // Add padding for keyboard + bottom safe area
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a doubt...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      fillColor: Colors.grey[900],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue[600],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}