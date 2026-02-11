import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF4B0082),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          
          // --- ACCOUNT SECTION ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Account", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text("Edit Profile"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () { /* Future Logic */ },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () { /* Future Logic */ },
          ),

          const Divider(),

          // --- APP SETTINGS ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text("Push Notifications"),
            value: true, 
            onChanged: (bool value) { /* Toggle logic */ },
          ),

          const Divider(),

          // --- SUPPORT ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Support", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Help Center"),
            onTap: () { /* Future Logic */ },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About FindIt"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}