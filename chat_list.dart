import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Messages", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the entire chats collection
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading chats"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter: Show rooms where the Current User's ID is part of the document ID
          var myChats = snapshot.data!.docs.where((doc) {
            return doc.id.contains(currentUser!.uid);
          }).toList();

          if (myChats.isEmpty) {
            return const Center(child: Text("No messages yet", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: myChats.length,
            itemBuilder: (context, index) {
              String roomId = myChats[index].id;
              
              // Extract the OTHER user's ID (the person you are talking to)
              String otherUserId = roomId.replaceAll(currentUser!.uid, "").replaceAll("_", "");

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF673AB7),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text("User ID: ${otherUserId.substring(0, 8)}..."),
                subtitle: const Text("Tap to view conversation"),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => ChatPage(
                        ownerId: otherUserId,
                        itemName: "Conversation",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}