import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Sign Out'),
                          content: Text('Do you want ot Sign Out??'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance
                                    .signOut()
                                    .then((value) => Navigator.pop(context));
                              },
                              child: Text(
                                'Log Out',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      });
                },
                icon: Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                ))
          ],
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 10,
          title: Text(
            'ChatApp',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .where('uid', isNotEqualTo: user!.uid)
                .snapshots(),
            builder: (context, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshots.hasData) {
                return ListView.separated(
                    itemCount: snapshots.data!.size,
                    itemBuilder: (context, index) {
                      var userinfo = snapshots.data?.docs[index].data();
                      return InkWell(
                        onTap: () {
                          var docRef = FirebaseFirestore.instance
                              .collection('ChatRooms');
                          String chatRoomID = generateChatRoomWithID(
                              user!.uid.toString(),
                              userinfo!['uid'].toString());
                          docRef
                              .doc(chatRoomID)
                              .get()
                              .then((docSnapshot) async {
                            if (!docSnapshot.exists) {
                              docRef.doc(chatRoomID).set({
                                'username1': user?.displayName,
                                'username2': userinfo['name'],
                                'ChatRoomID': chatRoomID,
                                'uid1': user!.uid,
                                'uid2': userinfo['uid'],
                                'email1': user!.email,
                                'email2': userinfo['email'],
                              });
                              docRef.doc(chatRoomID).get().then((value) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        chatRoomData: value.data())));
                              });
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        chatRoomData: docSnapshot.data(),
                                      )));
                            }
                          });
                        },
                        child: ListTile(
                          title: Text(userinfo?['name']),
                          subtitle: Text('Tap to message'),
                        ),
                      );
                    }, separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(thickness: 1,color: Colors.grey,),
                      );
                },);
              }
              return Center(
                child: Text('Something Went Wrong'),
              );
            }),
      ),
    );
  }
}

generateChatRoomWithID(String user1, String user2) {
  List<String> sortedNames = [user1, user2]..sort();
  String chatRoomID = sortedNames.join('');
  return chatRoomID;
}
