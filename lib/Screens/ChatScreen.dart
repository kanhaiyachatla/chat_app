import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  var chatRoomData;
  ChatScreen({super.key, required this.chatRoomData});

  @override
  State<ChatScreen> createState() => _ChatScreenState(chatRoomData);
}

class _ChatScreenState extends State<ChatScreen> {
  var chatRoomData;
  final _scrollController = ScrollController();
  User? user = FirebaseAuth.instance.currentUser;
  final _messageController = TextEditingController();

  _ChatScreenState(this.chatRoomData);

  @override
  Widget build(BuildContext context) {
    var chatDocRef = FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(chatRoomData['ChatRoomID']);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 10,
          title: (user!.uid == chatRoomData['uid1'])
              ? Text(chatRoomData['username2'])
              : Text(chatRoomData['username1']),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: chatDocRef
                      .collection('Messages')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (snapshots.hasData) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: snapshots.data!.size,
                            itemBuilder: (context, index) {
                              var message = snapshots.data?.docs[index].data();
                              if (message?['sentbyID'] == user!.uid) {
                                return BubbleSpecialTwo(
                                  text: message?['message'],
                                  color: Colors.green,
                                  tail: false,
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                );
                              } else {
                                return BubbleSpecialTwo(
                                  text: message?['message'],
                                  color: Colors.blue,
                                  isSender: false,
                                  tail: false,
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                );
                              }
                            }),
                      );
                    }
                    return Container();
                  }),
            ),
            _inputField(),
          ],
        ),
      ),
    );
  }

  _inputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey.shade200,
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Message',
              ),
              controller: _messageController,
            ),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: () async {
                if (_messageController.text.trim().isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('ChatRooms')
                      .doc(chatRoomData['ChatRoomID'])
                      .collection('Messages')
                      .add({
                    'message': _messageController.text.trim(),
                    'sentbyID': user?.uid,
                    'sentbyName': user?.displayName,
                    'time': DateTime.now().millisecondsSinceEpoch.toString(),
                  });
                  _messageController.clear();
                }
              },
              icon: Icon(Icons.send)
// backgroundColor: ColorConstant.lightBlueA100,
              ),
        ],
      ),
    );
  }
}

//
