// ignore_for_file: prefer_const_constructors

import 'package:authentico/camera/real_camera.dart';
import 'package:authentico/components/story_circles.dart';
import 'package:authentico/model/toothless.dart';
import 'package:authentico/pages/album_page.dart';
import 'package:authentico/pages/discovery_page.dart';
import 'package:authentico/pages/friends_page.dart';
import 'package:authentico/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference friendsCollection =
      FirebaseFirestore.instance.collection('friends');

  List<String> friendIds = [];
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  int _currentIndex = 0;
  bool appBarVisible = true;
  bool showStoryViews = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarVisible
          ? AppBar(
              leading: IconButton(
                icon: Icon(Icons.camera),
                onPressed: () {
                  // Navigate to camera screen or perform any desired action
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CameraPage()));
                },
              ),
              actions: [
                GestureDetector(
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ToothlessPage()),
                    );
                  },
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlbumPage()),
                      );
                    },
                    icon: Icon(Icons.photo_album),
                  ),
                ),
              ],
            )
          : null,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
              height:
                  showStoryViews ? 100 : 0, // Set height to 0 when not visible
              child: Visibility(
                visible: showStoryViews,
                child: FutureBuilder<QuerySnapshot>(
                    future: _firebaseFirestore.collection('themed_posts').get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("ERROR");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("LOADING...");
                      }

                      if (!snapshot.hasData) {
                        return const Text("No data found");
                      }

                      int numberOfPosts = snapshot.data!.docs.length;

                      return ListView.builder(
                        itemCount: numberOfPosts,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> postData =
                              snapshot.data!.docs[index].data()!
                                  as Map<String, dynamic>;

                          return StoryCircle(
                            challenge: postData[
                                'challenge'], // Replace with your story image URL field
                          );
                        },
                      );
                    }),
              )), // Display stories above user posts
          Expanded(
            child: _buildUserPostList(), // Display user posts
          ),
        ],
      ),
      bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.copyWith(
                  bodySmall: TextStyle(
                    fontFamily: 'Comfortaa',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Set your desired text color here
                  ),
                ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                appBarVisible = (_currentIndex == 0);
                showStoryViews = (_currentIndex == 0);
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_sharp),
                label: 'EXPLORE',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: 'MESSAGES',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.face),
                label: 'PROFILE',
              ),
            ],
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            selectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          )),
    );
  }

  Widget _buildUserPostList() {
    switch (_currentIndex) {
      case 0:
        return StreamBuilder<QuerySnapshot>(
          stream: _firebaseFirestore
              .collection('posts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("ERROR");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("LOADING...");
            }

            // Sort the documents based on the 'timestamp' field in descending order
            List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
            sortedDocs.sort((a, b) {
              // Convert timestamp strings to DateTime and compare them
              DateTime timeA = DateTime.parse(
                  (a.data() as Map<String, dynamic>)['timestamp']);
              DateTime timeB = DateTime.parse(
                  (b.data() as Map<String, dynamic>)['timestamp']);
              return timeB.compareTo(timeA);
            });

            return ListView(
              children: sortedDocs
                  .map<Widget>((doc) => _buildUserPostListItem(doc))
                  .toList(),
            );
          },
        );
      case 1:
        return DiscoveryPage(); // You need to implement the ProfilePage widget
      case 2:
        return FriendsPage();
      case 3:
        return ProfilePage(); // You need to implement the DiscoveryPage widget // You need to implement the PhotoAlbumPage widget
      default:
        return Container(); // Fallback case
    }
  }

  Widget _buildUserPostListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    String username = data['username'] as String? ?? 'Unknown';
    String profileImage = data['profileimage'] as String? ?? '';

    // Display all users post
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        tileColor: Colors.white,
        contentPadding: EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 30.0,
          backgroundImage: NetworkImage(profileImage),
        ),
        title: Text(
          username,
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Rear Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    data['frontImagePath'],
                    width: double.infinity,
                    height: 350.0,
                    fit: BoxFit.cover,
                  ),
                ),
                // Front Image
                Positioned(
                  left: 0.0,
                  top: -2.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      data['rearImagePath'],
                      width: 120.0,
                      height: 120.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              data['time'].toString(),
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Comfortaa',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
