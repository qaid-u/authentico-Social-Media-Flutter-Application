// ignore_for_file: prefer_const_constructors

import 'package:authentico/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String currentUserProfileImage = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserProfileImage(); // Fetch the current user's profile image on initialization
  }

  Future<void> _fetchCurrentUserProfileImage() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserUid)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentUserProfileImage = userDoc['profileimage'] as String? ?? '';
        });
      }
    } catch (error) {
      // ignore: avoid_print
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text("MESSAGES",
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: _buildUserList(),
      // Add the widget or code for displaying messages her
    );
  }

  //build a list of users except for the current logged in user
Widget _buildUserList() {
  return FutureBuilder<List<String>>(
    future: _fetchFriendUids(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("LOADING...");
      }

      if (snapshot.hasError) {
        return const Text("ERROR");
      }

      List<String> friendUids = snapshot.data ?? [];

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("ERROR");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("LOADING...");
          }

          return ListView(
            children: snapshot.data!.docs
                .where((doc) =>
                    _auth.currentUser?.uid != doc['uid'] &&
                    friendUids.contains(doc['uid']))
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        },
      );
    },
  );
}

Future<List<String>> _fetchFriendUids() async {
  try {
    var friendSnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .doc(currentUserUid)
        .collection('user_friends')
        .get();

    return friendSnapshot.docs.map((doc) => doc.id).toList();
  } catch (error) {
    // Handle error
    return [];
  }
}


//build individual user list names
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    String username = data['username'] as String? ?? 'Unknown';
    String profileImage = data['profileimage'] as String? ??
        'https://icons8.com/icon/12438/customer';

    String currentUserProfileImage = this.currentUserProfileImage.isNotEmpty
        ? this.currentUserProfileImage
        : 'https://icons8.com/icon/12438/customer';

    //display all users except current user
    if (_auth.currentUser?.uid != data['uid']) {
      return ListTile(
        tileColor: Colors.grey[700],
        title: Text(
          username,
          style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(profileImage),
        ),
        onTap: () {
          //pass the clicked user's uid to the chat page
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiverUserUsername: username,
                        receiverUserUID: data['uid'],
                        receiverUserPhoto: profileImage,
                        currentUserPhoto: currentUserProfileImage,
                      )));
        },
      );
    } else {
      //return empty container
      return Container();
    }
  }
}
