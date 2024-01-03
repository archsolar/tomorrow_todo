import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _darkMode = false;
  String _fontFamily = 'Roboto';
  double _fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0), // adjust the value as needed
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Dark mode'),
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Font size'),
              trailing: DropdownButton<double>(
                value: _fontSize,
                items: <DropdownMenuItem<double>>[
                  DropdownMenuItem<double>(
                    value: 14.0,
                    child: const Text('14'),
                  ),
                  DropdownMenuItem<double>(
                    value: 18.0,
                    child: const Text('18'),
                  ),
                  DropdownMenuItem<double>(
                    value: 22.0,
                    child: const Text('22'),
                  ),
                ],
                onChanged: (double? newValue) {
                  setState(() {
                    _fontSize = newValue!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Font type'),
              trailing: DropdownButton<String>(
                value: _fontFamily,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Roboto',
                    child: const Text('Roboto'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Arial',
                    child: const Text('Arial'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Courier',
                    child: const Text('Courier'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _fontFamily = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
