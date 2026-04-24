import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _unlock() {
    final AuthProvider authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String pin = _pinController.text.trim();

    if (pin.length != 4) {
      setState(() {
        _errorText = 'Enter your 4-digit PIN';
      });
      return;
    }

    if (authProvider.verifyPin(pin)) {
      setState(() {
        _errorText = null;
      });
      _pinController.clear();
      return;
    }

    setState(() {
      _errorText = 'Incorrect PIN';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Unlock Notein',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your notes stay on this device. Enter the PIN to continue.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.68),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _pinController,
                        autofocus: true,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textInputAction: TextInputAction.done,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        onSubmitted: (_) => _unlock(),
                        decoration: InputDecoration(
                          labelText: 'Security PIN',
                          hintText: '••••',
                          errorText: _errorText,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _unlock,
                          icon: const Icon(Icons.lock_open_rounded),
                          label: const Text('Unlock notes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
