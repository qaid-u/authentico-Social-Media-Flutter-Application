import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendRequestsPageState createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> acceptRequest(String friendRequestId) async {
    // Add friend to the 'friends' collection for both users
    await _firestore
        .collection('friends')
        .doc(currentUserId)
        .collection('user_friends')
        .doc(friendRequestId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('friends')
        .doc(friendRequestId)
        .collection('user_friends')
        .doc(currentUserId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Remove friend request from 'friend_requests' collection
    await _firestore
        .collection('friend_requests')
        .doc(currentUserId)
        .collection('requests')
        .doc(friendRequestId)
        .delete();
  }

  Future<void> declineRequest(String friendRequestId) async {
    // Remove friend request from 'friend_requests' collection
    await _firestore
        .collection('friend_requests')
        .doc(currentUserId)
        .collection('requests')
        .doc(friendRequestId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Friend Requests'),
        ),
        body: StreamBuilder(
          stream: _firestore
              .collection('friend_requests')
              .doc(currentUserId)
              .collection('requests')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var requests = snapshot.data?.docs;

            if (requests!.isEmpty) {
              return const Center(
                child: Text('No friend requests.'),
              );
            }

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var request = requests[index];
                var friendRequestId = request.id;

                return FutureBuilder(
                  future: _firestore
                      .collection('friend_requests')
                      .doc(currentUserId)
                      .collection('requests')
                      .doc(friendRequestId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (userSnapshot.hasError) {
                      return const Text('Error loading user data');
                    }

                    var senderUsername = userSnapshot.data?['username'];
                    var profileImageUrl = userSnapshot.data?[
                        'profileimage']; // Replace with the actual field name for the profile image URL

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            profileImageUrl), // Load the profile image from the network
                      ),
                      title: const Text('Friend Request'),
                      subtitle: Text('From: $senderUsername'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () => acceptRequest(friendRequestId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => declineRequest(friendRequestId),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}
