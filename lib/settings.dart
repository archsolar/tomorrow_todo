import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tomorrow_todo/providers.dart';

class Settings extends ConsumerWidget {
  String _fontFamily = 'Roboto';
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Query whether darkmode is on
    var preference = ref.watch(preferenceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0), // adjust the value as needed
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Dark mode'),
              trailing: Switch(
                value: preference.darkMode,
                onChanged: (value) {
                  ref.read(preferenceProvider.notifier).toggleDarkMode();
                },
              ),
            ),
            ListTile(
              title: const Text('Font size'),
              trailing: DropdownButton<double>(
                value: _fontSize,
                items: const <DropdownMenuItem<double>>[
                  DropdownMenuItem<double>(
                    value: 14.0,
                    child: Text('14'),
                  ),
                  DropdownMenuItem<double>(
                    value: 18.0,
                    child: Text('18'),
                  ),
                  DropdownMenuItem<double>(
                    value: 22.0,
                    child: Text('22'),
                  ),
                ],
                onChanged: (double? newValue) {
                  // setState(() {
                  //   _fontSize = newValue!;
                  // });
                },
              ),
            ),
            ListTile(
              title: const Text('Font type'),
              trailing: DropdownButton<String>(
                value: _fontFamily,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Roboto',
                    child: Text('Roboto'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Arial',
                    child: Text('Arial'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Courier',
                    child: Text('Courier'),
                  ),
                ],
                onChanged: (String? newValue) {
                  // setState(() {
                  //   _fontFamily = newValue!;
                  // });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
