import 'package:flutter/material.dart';
import 'package:tomorrow_todo/settings.dart';

// Idea: check if there are user settings available else fall back to this
TextTheme getTextTheme() {
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
        textTheme: getTextTheme(),
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, textTheme: getTextTheme()),
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
              PopupMenuItem(
                value: 1,
                child: const Text("Settings"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings()),
                  );
                },
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
                children: [
                  // Idea an animation of a plant that slowly grows with consistent usage of the app
                  // Idea or a star for each time you finished all the tasks.
                  // Allow the user to admit they lied, and remove stars.
                  Stack(
                    children: [
                      Container(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          child: const Center(child: Text(
                              // Idea: replace with some kind digital date?
                              "2 January 2024"))), // It either reads {today's date} or "Tomorrow"
                      // Idea: add a plant that grows with consistent usage of the app
                      // Image.asset('assets/images/plant.png'),
                    ],
                  ),
                  const TaskEntry(),
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

    const imageScaleDivisor = 14.0;
    return Row(
      children: [
        // Idea: different color checkbox when holding
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
        GestureDetector(
          onTap: () {
            print("Idea: navigate to the next day");
          },
          child: Padding(
            padding:
                const EdgeInsets.only(right: 8.0), // adjust the value as needed
            child: Transform.scale(
              scale: DefaultTextStyle.of(context).style.fontSize != null
                  ? DefaultTextStyle.of(context).style.fontSize! /
                      imageScaleDivisor
                  : 18.0 / imageScaleDivisor,
              child: const Icon(Icons.play_arrow),
            ),
          ),
        ),
      ],
    );
  }
}
