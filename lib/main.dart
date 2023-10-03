import 'package:flutter/material.dart';

// for exit app
import 'package:flutter/services.dart';

// fluttertoast
import 'package:fluttertoast/fluttertoast.dart';

// firebase core, options and rtdb
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

// files
import 'package:campus_connect/home.dart';
import 'package:campus_connect/components/exit_dialog.dart';

void main() async {
  // initialize firebase
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
        // initialRoute: '/',
        // routes: {
        //   '/wit': (context) => const Home(
        //       title: 'Campus Connect',
        //       institute: 'Walchand Institute of Technology, Solapur')
        // }
        );
  }
}

// choose widget: a search box(text + list field) and a submit button
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

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<List<String>> getIndex() async {
    final snapshot = await ref.child('index').get();
    if (snapshot.exists) {
      return (snapshot.value as List).cast<String>();
    }
    return [];
  }

  Future<Map> getData() async {
    final snapshot = await ref.child(selectedInstitute).get();
    if (snapshot.exists) {
      return snapshot.value as Map;
    }
    return {};
  }

  @override
  void initState() {
    super.initState();

    getIndex().then((value) {
      setState(() {
        institutesList = value;
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

  // creates filtered list based on input text
  void updateFilteredList(String value) {
    setState(() {
      filteredList = institutesList
          .where((institute) =>
              institute.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // selects institute
  void selectInstitute(String institute) {
    setState(() {
      selectedInstitute = institute;

      // disables list
      isOptionsVisible = false;

      // sets text field value
      searchController.text = selectedInstitute;
    });

    // changes focus back to text field
    searchFocusNode.requestFocus();

    // positions cursor to the end of the input text
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
    return WillPopScope(
      onWillPop: () async {
        // wait for confirmation from dialog box
        bool? exitConfirmed = await showExitConfirmationDialog(context);

        // if confirmed
        if (exitConfirmed != null && exitConfirmed) {
          // exit app
          SystemNavigator.pop();
        }
        return false;
      },
      child: Scaffold(
        // appbar
        appBar: AppBar(
          title: Text(widget.title),
        ),

        // body
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // input text field
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

                  // start virtual tour button
                  ElevatedButton(
                    onPressed: () {
                      // navigates to home page, send selected institute data
                      if (selectedInstitute.isNotEmpty) {
                        getData().then((value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Home(
                              title: widget.title,
                              institute: selectedInstitute,
                              map: value
                            ),
                          ),
                        ))
                        ;
                      }

                      // show toast message if no input
                      else {
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        'Start Virtual Tour',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),

              // options list
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
      ),
    );
  }
}
