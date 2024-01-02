import 'package:flutter/material.dart';

// Idea: check if there are user settings available else fall back to this
TextTheme defaultTextTheme() {
  return const TextTheme(
    bodyMedium: TextStyle(fontSize: 25.0),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: defaultTextTheme(),
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, textTheme: defaultTextTheme()),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // Idea: replace
      home: const MyHomePage(title: 'Tomorrow TODO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text("Settings"),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  // Idea an animation of a plant that slowly grows with consistent usage of the app
                  Stack(
                    children: [
                      Center(child: Text("2 January 2024")),
                      Placeholder(
                        fallbackHeight: 200,
                        fallbackWidth: 300,
                      ),
                    ],
                  ),
                  TaskEntry(),
                ],
              ),
            ),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tomorrow\'s tasks',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEntry extends StatefulWidget {
  const TaskEntry({super.key});

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  bool isChecked = false;
  String taskName = "Add task(s) for tomorrow";

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Row(
      children: [
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
          },
        ),
        Expanded(child: Text(taskName)),
        const Icon(Icons.arrow_forward), // Add this line
      ],
    );
  }
}
