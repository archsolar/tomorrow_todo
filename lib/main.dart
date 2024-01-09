import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tomorrow_todo/components/database.dart';
import 'package:tomorrow_todo/components/stored_structs.dart';
import 'package:tomorrow_todo/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'darkModeProvider.dart';
// import 'package:simple_permissions/simple_permissions.dart';

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

class TaskViewer extends StatefulWidget {
  TaskViewer({Key? key}) : super(key: key);

  @override
  _TaskViewerState createState() => _TaskViewerState();
}

class _TaskViewerState extends State<TaskViewer> {
  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Database.getAllTasks();

    return FutureBuilder<List<Task>>(
      future: tasks,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return Text("Wait for tomorrow/Something went wrong :)");
        } else {
          return ListView(
            children: snapshot.data!.map((Task task) {
              return TaskEntry(
                task: task,
                onUpdate: updateState,
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class TaskEntry extends StatefulWidget {
  final Task task;
  final Function onUpdate;

  const TaskEntry({Key? key, required this.task, required this.onUpdate})
      : super(key: key);

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.task.title;
  }

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

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Edit Task'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Task title'),
            ),
            actions: [
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    Database.changeTaskTitle(widget.task, _controller.text);
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                //TODO something's weird here.
                child: Text('Delete'),
                onPressed: () {
                  Database.deleteTask(widget.task.id).then((value) {
                    widget.onUpdate();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: Row(
        children: [
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
        ],
      ),
    );
  }
}
