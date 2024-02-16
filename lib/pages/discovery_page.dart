// ignore_for_file: prefer_const_constructors

import 'package:authentico/components/like_button.dart';
import 'package:authentico/pages/others_page.dart';
import 'package:authentico/pages/themed_posts_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String _searchQuery = '';

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  TabController? _tabController;

  void _initializeTabController() {
    _tabController = TabController(
      length: 3, // Number of tabs
      vsync: this,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _toggleLike(String postId) async {
    String currentUserId = _auth.currentUser?.uid ?? '';

    DocumentReference postRef =
        _firebaseFirestore.collection('posts').doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      List<String> likes = List<String>.from(postSnapshot['likes'] ?? []);

      if (likes.contains(currentUserId)) {
        // User already liked, so unlike
        likes.remove(currentUserId);
      } else {
        // User didn't like, so like
        likes.add(currentUserId);
      }

      await postRef.update({'likes': likes});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "DISCOVERY",
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildUserPostList(),
    );
  }

  Widget _buildUserPostList() {
    return Column(
      children: [
        // Menu Section
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Text(
                'Explore',
                style: TextStyle(
                    fontFamily: 'Comfortaa', fontWeight: FontWeight.normal),
              ),
            ),
            Tab(
              child: Text(
                'Friends Post',
                style: TextStyle(
                    fontFamily: 'Comfortaa', fontWeight: FontWeight.normal),
              ),
            ),
            Tab(
              child: Text(
                'Challenges',
                style: TextStyle(
                    fontFamily: 'Comfortaa', fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _updateSearchQuery,
            style: const TextStyle(
                fontFamily: 'PT Sans',
                fontStyle: FontStyle.italic,
                color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Enter username to search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        // Expanded ListView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1 content
              _buildTabContent(1),
              // Tab 2 content
              _buildTabContent(2),
              // Tab 3 content (Challenges)
              _buildTabContent(3),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<String>> _fetchFriendUids() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
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

  Widget _buildTabContent(int tabIndex) {
    if (tabIndex == 3) {
      // Return Challenges Page content
      return _buildChallengesList();
    } else if (tabIndex == 2) {
      return FutureBuilder<List<String>>(
        future: _fetchFriendUids(),
        builder: (context, friendSnapshot) {
          if (friendSnapshot.connectionState == ConnectionState.waiting) {
            return const Text("LOADING...");
          }

          if (friendSnapshot.hasError) {
            return const Text("ERROR");
          }

          List<String> friendUids = friendSnapshot.data ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: _firebaseFirestore.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("ERROR");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("LOADING...");
              }

              List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
              sortedDocs.sort((a, b) {
                DateTime timeA = DateTime.parse(
                    (a.data() as Map<String, dynamic>)['timestamp']);
                DateTime timeB = DateTime.parse(
                    (b.data() as Map<String, dynamic>)['timestamp']);
                return timeB.compareTo(timeA);
              });

              return ListView(
                children: sortedDocs
                    .where((doc) {
                      String username = doc['username'] as String? ?? 'Unknown';
                      return friendUids.contains(doc['uid']) &&
                          username.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              );
                    })
                    .map<Widget>((doc) => _buildUserPostListItem(doc))
                    .toList(),
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore.collection('posts').snapshots(),
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
            DateTime timeA =
                DateTime.parse((a.data() as Map<String, dynamic>)['timestamp']);
            DateTime timeB =
                DateTime.parse((b.data() as Map<String, dynamic>)['timestamp']);
            return timeB.compareTo(timeA);
          });

          return ListView(
            children: sortedDocs
                .where((doc) {
                  // Filter the list based on the search query
                  String username = doc['username'] as String? ?? 'Unknown';
                  return username.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                })
                .map<Widget>((doc) => _buildUserPostListItem(doc))
                .toList(),
          );
        },
      );
    }
  }

  Widget _buildUserPostListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    String postId = document.id;
    String username = data['username'] as String? ?? 'Unknown';
    String uid = data['uid'] as String? ?? '';
    String profileImage = data['profileimage'] as String? ?? '';

    // Display all users except the current user
    if (_auth.currentUser?.uid != uid) {
      return Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          tileColor: Colors.white, // Adjust the background color
          contentPadding: EdgeInsets.all(16.0), // Adjust padding
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OthersProfilePage(viewuid: uid),
                  ));
              // ignore: avoid_print
              print('Profile image tapped for user: $username');
            },
            child: CircleAvatar(
              radius: 30.0, // Adjust the avatar size
              backgroundImage: NetworkImage(profileImage),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.bold, // Adjust text style
                  fontSize: 18.0, // Adjust the font size
                ),
              ),
              SizedBox(height: 8.0), // Add some space below the username
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
                    left: 0.0, // Adjust the left position as needed
                    top: -2.0, // Adjust the top position as needed
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        data['rearImagePath'],
                        width: 120.0, // Adjust the width of the front image
                        height: 120.0, // Adjust the height of the front image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Text(
            data['time'].toString(),
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontStyle: FontStyle.italic, // Adjust text style
              color: Colors.grey,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeButton(
                isLiked: data['likes'] != null &&
                    data['likes'].contains(_auth.currentUser?.uid),
                onTap: () {
                  _toggleLike(postId);
                },
              ),
              Text((data['likes'] ?? []).length.toString()),
            ],
          ),
        ),
      );
    } else {
      // Return an empty container for the current user
      return Container();
    }
  }

  Widget _buildChallengesList() {
    // Replace this with your logic to fetch and display challenges
    return ListView(
      children: [
        _buildChallengeItem('Natures Canvas',
            'Share a post showcasing the beauty of nature around you.'),
        _buildChallengeItem('Tech Talk Tuesday:',
            'Share a post related to your favorite tech gadget, app, or a tech-related achievement.'),
        _buildChallengeItem('Minty Monday - Decades Edition:',
            'Post a photo or content inspired by a specific decade (e.g., 80s fashion, 90s music).'),
        // Add more challenges as needed
      ],
    );
  }

  Widget _buildChallengeItem(String challengeName, String challengeDesc) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(challengeName, 
        style: TextStyle(
          fontFamily: 'Comfortaa',
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold
        ),),
        subtitle: Text(challengeDesc,
        style: TextStyle(
          fontFamily: 'Comfortaa',
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.normal
        )),
        onTap: () {
          // Add navigation or action when a challenge is tapped
          _navigateToChallengeDetail(challengeName);
        },
      ),
    );
  }

  void _navigateToChallengeDetail(String challengeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ThemedPostGalleryPage(challengeName: challengeName),
      ),
    );
  }
}


