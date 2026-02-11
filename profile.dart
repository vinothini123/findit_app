import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_list.dart';
import 'login.dart';
import 'my_reports.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true; // Added state for Notifications

  // Logic: Send Firebase Password Reset Email
  Future<void> _handlePasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Reset link sent to ${user.email}")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${e.toString()}")),
          );
        }
      }
    }
  }

  // Logic: Delete Account Confirmation
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("This action is permanent and cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false);
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please re-login to delete account")));
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Account Settings", 
          style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black)),
        centerTitle: true,
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF673AB7),
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: CircleAvatar(
                          radius: 18, backgroundColor: const Color(0xFF673AB7),
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                            onPressed: () => _showComingSoon(context, "Profile Photo Upload"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(user?.email ?? "User Email", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionLabel("Activity"),
            _buildSettingCard(context, icon: Icons.chat_bubble_outline, title: "My Messages", subtitle: "Active conversations", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChatListPage()))),
            _buildSettingCard(context, icon: Icons.assignment_outlined, title: "My Reports", subtitle: "Lost and found items", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MyReportsPage()))),

            const SizedBox(height: 20),
            _buildSectionLabel("Preferences"),
            _buildToggleCard(icon: Icons.dark_mode_outlined, title: "Dark Mode", value: _isDarkMode, onChanged: (v) => setState(() => _isDarkMode = v)),
            
            // --- WORKING NOTIFICATION TOGGLE ---
            _buildToggleCard(
              icon: Icons.notifications_none, 
              title: "Notifications", 
              value: _notificationsEnabled, 
              onChanged: (v) => setState(() => _notificationsEnabled = v)
            ),

            const SizedBox(height: 20),
            _buildSectionLabel("Account Management"),
            
            // --- WORKING PASSWORD RESET ---
            _buildSettingCard(
              context, 
              icon: Icons.lock_outline, 
              title: "Change Password", 
              subtitle: "Send reset link to email", 
              onTap: _handlePasswordReset
            ),
            
            // --- WORKING DELETE ACCOUNT ---
            _buildSettingCard(
              context, 
              icon: Icons.delete_forever_outlined, 
              title: "Delete Account", 
              subtitle: "Remove your data permanently", 
              onTap: _confirmDeleteAccount
            ),

            const SizedBox(height: 40),
            _buildLogoutButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10),
      child: Align(alignment: Alignment.centerLeft, child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF673AB7))),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : Colors.black)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildToggleCard({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        secondary: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF673AB7))),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: _isDarkMode ? Colors.white : Colors.black)),
        activeColor: const Color(0xFF673AB7),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false);
          },
          child: const Text("LOG OUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$feature coming soon!")));
  }
}