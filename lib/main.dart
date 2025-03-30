import 'package:flutter/material.dart';
import 'package:project_flutter/home.dart';

//void main() => runApp(new MyApp());
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Home(),
    );
  }
}