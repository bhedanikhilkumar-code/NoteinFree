import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settings, auth, child) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: settings.isDarkMode,
                onChanged: (val) {
                  settings.toggleTheme(val);
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('App Lock'),
                subtitle: Text(auth.isLockEnabled ? 'Enabled' : 'Disabled'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLockDialog(context, auth);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLockDialog(BuildContext context, AuthProvider auth) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(auth.isLockEnabled ? 'Disable Lock' : 'Enable Lock'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter 4-digit PIN'),
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (auth.isLockEnabled) {
                  // To disable, verify current PIN
                  if (auth.verifyPin(controller.text)) {
                    auth.disableLock();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lock Disabled')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect PIN')));
                  }
                } else {
                  // To enable, set new PIN
                  if (controller.text.length == 4) {
                    auth.enableLock(controller.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lock Enabled')));
                  }
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
