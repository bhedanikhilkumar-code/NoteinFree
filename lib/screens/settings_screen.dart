import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_fonts.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<bool> _checkNotificationPermission() async {
    final NotificationService service = NotificationService();
    await service.init();
    return service.hasPermission();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (
          BuildContext context,
          SettingsProvider settings,
          AuthProvider auth,
          Widget? child,
        ) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              _SettingsSection(
                title: 'Appearance',
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Cleaner contrast for longer sessions'),
                    value: settings.isDarkMode,
                    onChanged: settings.toggleTheme,
                  ),
                  ListTile(
                    title: const Text('Font style'),
                    subtitle: Text(settings.fontOption.label),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showFontPicker(context, settings),
                  ),
                  ListTile(
                    title: const Text('Font scale'),
                    subtitle: Text('${(settings.fontScale * 100).round()}%'),
                  ),
                  Slider(
                    value: settings.fontScale,
                    min: 0.9,
                    max: 1.3,
                    divisions: 4,
                    label: '${(settings.fontScale * 100).round()}%',
                    onChanged: settings.setFontScale,
                  ),
                  ListTile(
                    title: const Text('Sort notes by'),
                    subtitle: Text(settings.sortLabel(settings.sortOrder)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showSortPicker(context, settings),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Notifications',
                children: <Widget>[
                  ListTile(
                    title: const Text('Reminder notifications'),
                    subtitle: const Text('Get notified when a note reminder is due'),
                    trailing: FutureBuilder<bool>(
                      future: _checkNotificationPermission(),
                      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        final bool granted = snapshot.data ?? false;
                        return Switch(
                          value: granted,
                          onChanged: (bool value) async {
                            if (value) {
                              final NotificationService service = NotificationService();
                              await service.init();
                              await service.requestPermissions();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'Privacy & security',
                children: <Widget>[
                  ListTile(
                    title: const Text('App lock'),
                    subtitle: Text(auth.isLockEnabled ? 'PIN enabled' : 'Disabled'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showLockDialog(context, auth),
                  ),
                  SwitchListTile(
                    title: const Text('Auto-lock on background'),
                    subtitle: const Text('Relock when the app leaves the foreground'),
                    value: settings.autoLockEnabled,
                    onChanged: auth.isLockEnabled ? settings.setAutoLockEnabled : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'PIN is now stored as a hash instead of plain text. For even stronger privacy later, shift note storage from SharedPreferences to encrypted local storage.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: 'About',
                children: <Widget>[
                  const ListTile(
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Notein Free'),
                    subtitle: const Text('Fast, private, offline notes'),
                    trailing: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFontPicker(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: AppFonts.options.map((FontOption option) {
              final bool selected = option.id == settings.fontPresetId;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                ),
                title: Text(
                  option.label,
                  style: TextStyle(fontFamily: option.fontFamily),
                ),
                subtitle: Text(
                  option.preview,
                  style: TextStyle(fontFamily: option.fontFamily),
                ),
                onTap: () async {
                  await settings.setFontPreset(option.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSortPicker(BuildContext context, SettingsProvider settings) {
    final List<int> sortOptions = <int>[
      SettingsProvider.sortNewestFirst,
      SettingsProvider.sortOldestFirst,
      SettingsProvider.sortAlphabetical,
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortOptions.map((int order) {
              return RadioListTile<int>(
                value: order,
                groupValue: settings.sortOrder,
                title: Text(settings.sortLabel(order)),
                onChanged: (int? value) async {
                  if (value == null) {
                    return;
                  }
                  await settings.setSortOrder(value);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLockDialog(BuildContext context, AuthProvider auth) {
    final TextEditingController controller = TextEditingController();
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(auth.isLockEnabled ? 'Disable app lock' : 'Enable app lock'),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter 4-digit PIN',
                  errorText: errorText,
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final String pin = controller.text.trim();
                    final bool wasEnabled = auth.isLockEnabled;

                    if (pin.length != 4) {
                      setState(() {
                        errorText = 'PIN should be exactly 4 digits';
                      });
                      return;
                    }

                    if (wasEnabled) {
                      if (!auth.verifyPin(pin)) {
                        setState(() {
                          errorText = 'Incorrect PIN';
                        });
                        return;
                      }
                      await auth.disableLock();
                    } else {
                      await auth.enableLock(pin);
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(wasEnabled ? 'App lock disabled' : 'App lock enabled'),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}