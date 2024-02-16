import 'package:authentico/components/text_field.dart';
import 'package:authentico/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserUsername;
  final String receiverUserUID;
  final String receiverUserPhoto;
  final String currentUserPhoto;
  const ChatPage({
    super.key,
    required this.receiverUserUsername,
    required this.receiverUserUID,
    required this.receiverUserPhoto,
    required this.currentUserPhoto,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // Only send message when there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserUID, _messageController.text);
      // Clear text controller after sending the message
      _messageController.clear();
      // Force rebuild the widget tree
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 80,
          automaticallyImplyLeading: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 115), // Add some padding to the left
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.receiverUserPhoto),
                    radius: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.receiverUserUsername,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PT Sans',
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
        body:
        Column(
          children: [
            //messages

            Expanded(
              child: _buildMessageList(),
            ),

            //user input
            _buildMessageInput(),

            const SizedBox(
              height: 10,
            )
          ],
        ));
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserUID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('LOADING...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox(); // or a placeholder widget if data is null
    }

    bool isCurrentUser = (data['senderId'] == _firebaseAuth.currentUser?.uid);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverUserPhoto),
              radius: 24,
            ),
          if (!isCurrentUser) const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(
                maxWidth: 250), // Adjust the maxWidth as needed
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: isCurrentUser ? Colors.blue : Colors.grey,
            ),
            child: Text(
              data['message'] ?? '',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundImage: NetworkImage(widget.currentUserPhoto),
              radius: 24,
            ),
        ],
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          //textfield
          Expanded(
              child: MyTextField(
            controller: _messageController,
            hintText: 'Enter Message',
            obscureText: false,
          )),

          //send button
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward_rounded,
                size: 40,
              ))
        ],
      ),
    );
  }
}
