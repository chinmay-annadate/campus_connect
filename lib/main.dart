import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Choose(title: 'Campus Connect'),
    );
  }
}

class Choose extends StatefulWidget {
  const Choose({Key? key, required this.title}) : super(key: key);
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
        dropDownList = (data as List).cast<String>();
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: dropDownValue,
                elevation: 2,
                style: const TextStyle(color: Colors.blue, fontSize: 16),
                items: dropDownList.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropDownValue = newValue!;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (dropDownValue != dropDownList[0]) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Home(
                        title: widget.title,
                        institute: dropDownValue,
                      ),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Please select an institute",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Start Virtual Tour',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
