import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _titleController = TextEditingController();
  final _locController = TextEditingController();
  // Matching the filter logic in HomeScreen
  String _selectedStatus = 'Lost'; 

  void _saveToDatabase() async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Basic validation to prevent empty posts
    if (_titleController.text.isEmpty || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an item name"))
      );
      return;
    }

    // Saving with the field 'status' so your Home Screen filters work
    await FirebaseFirestore.instance.collection('items').add({
      'title': _titleController.text.trim(),
      'location': _locController.text.trim(),
      'status': _selectedStatus, // Use 'status' to match your home feed filter
      'ownerId': user.uid, 
      'ownerEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Item", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Segmented toggle for Lost vs Found
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Lost', label: Text("Lost"), icon: Icon(Icons.help_outline)),
                ButtonSegment(value: 'Found', label: Text("Found"), icon: Icon(Icons.thumb_up_off_alt)),
              ],
              selected: {_selectedStatus},
              onSelectionChanged: (val) => setState(() => _selectedStatus = val.first),
              style: ButtonStyle(
                side: WidgetStateProperty.all(const BorderSide(color: Color(0xFF673AB7))),
              ),
            ),
            const SizedBox(height: 30),
            
            TextField(
              controller: _titleController, 
              decoration: const InputDecoration(
                labelText: "Item Name", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2)
              )
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _locController, 
              decoration: const InputDecoration(
                labelText: "Location", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on)
              )
            ),
            
            const Spacer(),
            
            // Full-width Post Button
            SizedBox(
              width: double.infinity, 
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _saveToDatabase, 
                child: const Text("POST ITEM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
            )
          ],
        ),
      ),
    );
  }
}