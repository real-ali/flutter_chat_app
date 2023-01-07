import 'package:flutter/material.dart';

import 'composition_root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CompositionRoot.configur();
  final firstPage = CompositionRoot.start();
  runApp(MyApp(firstPage));
}

class MyApp extends StatelessWidget {
  final Widget firstPage;
  const MyApp(this.firstPage, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: firstPage,
    );
  }
}
