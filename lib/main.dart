import 'package:flutter/material.dart';
import 'package:campus_connect/home.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Choose(title: 'Campus Connect'),
    );
  }
}

class Choose extends StatefulWidget {
  const Choose({super.key, required this.title});
  final String title;

  @override
  State<Choose> createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  String dropDownValue = '';
  List<String> dropDownList = [];

  @override
  void initState() {
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref('index');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        dropDownList = (data as List).map((item) => item as String).toList();
        dropDownValue = dropDownList[0];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: dropDownValue,
              items: dropDownList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValue = newValue!;
                });
              },
            ),

            // Start virtual tour button
            TextButton(
                onPressed: (() {
                  if (dropDownValue != dropDownList[0]) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => Home(
                                  title: widget.title,
                                  institute: dropDownValue,
                                )));
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please select an institute",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }),
                child: const Text('Start Virtual Tour'))
          ],
        ),
      ),
    );
  }
}
