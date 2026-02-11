import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart'; 
import 'chat.dart';
import 'report.dart';
import 'chat_list.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables for Search and Filter
  String searchQuery = "";
  String filterStatus = "All"; // Options: "All", "Lost", "Found"

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("FindIt Feed", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Color(0xFF673AB7), size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined, color: Color(0xFF673AB7), size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatListPage())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF673AB7), size: 28),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // --- NEW: SEARCH & FILTER UI ---
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                // Modern Search Bar
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search by item name...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF673AB7)),
                    filled: true,
                    fillColor: const Color(0xFFF0F0F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter Choice Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ["All", "Lost", "Found"].map((status) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: filterStatus == status,
                        selectedColor: const Color(0xFF673AB7),
                        labelStyle: TextStyle(
                          color: filterStatus == status ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => filterStatus = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // --- FEED LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Client-side filtering logic
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String title = (data['title'] ?? "").toString().toLowerCase();
                  String status = data['status'] ?? "Lost"; // Default to Lost if not set

                  bool matchesSearch = title.contains(searchQuery);
                  bool matchesFilter = (filterStatus == "All" || status == filterStatus);
                  
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No matching items found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var item = doc.data() as Map<String, dynamic>;
                    String? ownerId = item['ownerId'];
                    String status = item['status'] ?? "Lost";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['title'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                            // --- NEW: STATUS TRACKING BADGE ---
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == "Lost" ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: status == "Lost" ? Colors.red : Colors.green),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: status == "Lost" ? Colors.red : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("📍 ${item['location'] ?? 'Unknown'}"),
                        ),
                        trailing: (ownerId == currentUser?.uid) 
                          ? const Chip(
                              label: Text("My Post", style: TextStyle(fontSize: 12)), 
                              backgroundColor: Color(0xFFF3E5F5),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF673AB7),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () {
                                if (ownerId != null) {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (c) => ChatPage(ownerId: ownerId, itemName: item['title'] ?? "Item")
                                    )
                                  );
                                }
                              },
                              child: const Text("Message"),
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}