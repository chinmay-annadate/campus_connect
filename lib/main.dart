import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

class _ChooseState extends State<Choose> with WidgetsBindingObserver {
  String selectedInstitute = '';
  List<String> institutesList = [];
  List<String> filteredList = [];
  bool isOptionsVisible = false;

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    DatabaseReference ref = FirebaseDatabase.instance.ref('index');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        institutesList = (data as List).cast<String>();
        filteredList = institutesList;
      });
    });

    // Add WidgetsBindingObserver
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove WidgetsBindingObserver
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updateFilteredList(String value) {
    setState(() {
      filteredList = institutesList
          .where((institute) =>
              institute.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void selectInstitute(String institute) {
    setState(() {
      selectedInstitute = institute;
      isOptionsVisible = false;
      searchController.text = selectedInstitute;
    });

    searchFocusNode.requestFocus();
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );
  }

  // Listen for keyboard visibility changes
  @override
  void didChangeMetrics() {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    setState(() {
      isOptionsVisible = keyboardVisible && filteredList.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Search for an institute',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: updateFilteredList,
                    onTap: () {
                      setState(() {
                        isOptionsVisible = true;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        isOptionsVisible = false;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedInstitute.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Home(
                            title: widget.title,
                            institute: selectedInstitute,
                          ),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please select an institute',
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
            if (isOptionsVisible)
              Positioned(
                top: 250,
                left: 16,
                right: 16,
                bottom: 0,
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final institute = filteredList[index];
                      return ListTile(
                        title: Text(institute),
                        onTap: () {
                          selectInstitute(institute);
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
