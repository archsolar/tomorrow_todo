import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/components/stored_structs.dart';
import 'package:tomorrow_todo/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'darkModeProvider.dart';

// Idea: check if there are user settings available else fall back to this
TextTheme getTextTheme() {
  return const TextTheme(
    bodyMedium: TextStyle(fontSize: 25.0),
  );
}

final taskProvider = FutureProvider<List<Task>>((ref) async {
  return await Database.getAllTasks();
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Database.init();

  await Database.insertTask("Test task");
  runApp(const ProviderScope(child: MyApp()));
}

ThemeMode getThemeMode() {
  // Idea: check if there are user settings available else fall back to this
  return ThemeMode.system;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var darkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: getTextTheme(),
      ),
      darkTheme:
          ThemeData(brightness: Brightness.dark, textTheme: getTextTheme()),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
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
            Container(
                color: Theme.of(context).colorScheme.inversePrimary,
                child: const Center(child: Text(
                    // Idea: replace with some kind digital date?
                    "4 January 2024"))), // It either reads {today's date} or "Tomorrow"
            Expanded(
              child: TaskViewer(),
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

class TaskViewer extends StatelessWidget {
  TaskViewer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = Database.getAllTasks();

    return FutureBuilder<List<Task>>(
      future: tasks,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading spinner while waiting
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show error if something went wrong
        } else if (snapshot.data == null) {
          return Text("Wait for tomorrow/Something went wrong :)");
        } else {
          // Build the ListView with the data from snapshot
          return ListView(
            children: snapshot.data!.map((Task task) {
              return TaskEntry(
                task: task,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

// TODO what does this mean?
// ignore: must_be_immutable
class TaskEntry extends StatefulWidget {
  Task task;
  TaskEntry({super.key, required this.task});

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  // bool isChecked = false;
  // String taskName = widget.task.title;

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
        // Idea: different color checkbox when holding
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: widget.task.done,
          onChanged: (bool? value) {
            setState(() {
              Database.toggleDone(widget.task);
            });
          },
        ),
        Expanded(child: Text(widget.task.title)),
        // if (tomorrowTask) //TODO only show this when it's the tomorrow task.
        //   GestureDetector(
        //     onTap: () {
        //       print("Idea: navigate to the next day");
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.only(
        //           right: 8.0), // adjust the value as needed
        //       child: Transform.scale(
        //         scale: DefaultTextStyle.of(context).style.fontSize != null
        //             ? DefaultTextStyle.of(context).style.fontSize! /
        //                 imageScaleDivisor
        //             : 18.0 / imageScaleDivisor,
        //         child: const Icon(Icons.play_arrow),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
