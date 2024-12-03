import 'package:flutter/material.dart';

import 'app/widgets/macos_docker_example.dart';

/// Entry point of the Flutter application.
void main() {
  runApp(const MyApp());
}

/// Root widget of the application.
///
/// This widget is a [StatefulWidget] to allow potential state management
/// at the root level, though it currently doesn't manage any state.
class MyApp extends StatefulWidget {
  /// Constructs the [MyApp] widget.
  ///
  /// The constructor is marked as `const` since the widget is immutable.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// The state class for [MyApp].
///
/// This class builds the widget tree for the application.
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      /// The home screen of the application.
      ///
      /// This widget serves as the starting point of the app and is defined
      /// in the `macos_docker_example.dart` file.
      home: MacosDockerExample(),
    );
  }
}