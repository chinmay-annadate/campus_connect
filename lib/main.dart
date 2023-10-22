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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const Choose(title: 'Campus Connect'),
        initialRoute: '/',
        routes: {
          '/wit': (context) => const Home(
                  title: 'Campus Connect',
                  institute: 'Walchand Institute of Technology, Solapur',
                  map: {
                    "2-Wheeler parking": {
                      "building": "Outdoor",
                      "description": "2-Wheeler parking",
                      "floor": "NA",
                      "hotspots": {
                        "0": "Main Entrance",
                        "90": "Library",
                        "180": "Back gate"
                      },
                      "image": "WIT/buildings/outdoor/2-wheeler-parking.jpg"
                    },
                    "Back gate": {
                      "building": "Outdoor",
                      "description": "Back gate",
                      "floor": "NA",
                      "hotspots": {
                        "6": "Parking",
                        "125": "Sports ground",
                        "-85": "2-Wheeler parking"
                      },
                      "image": "WIT/buildings/outdoor/back-gate.jpg"
                    },
                    "Canteen": {
                      "building": "Outdoor",
                      "description": "Canteen",
                      "floor": "NA",
                      "hotspots": {
                        "90": "Main Entrance",
                        "-90": "Xerox centre"
                      },
                      "image": "WIT/buildings/outdoor/canteen.jpg"
                    },
                    "Civil-Mech": {
                      "building": "Outdoor",
                      "description": "Civil-Mech building and workcentre",
                      "floor": "NA",
                      "hotspots": {"150": "Parking"},
                      "image": "WIT/buildings/outdoor/civil-mech.jpg"
                    },
                    "Library": {
                      "building": "Outdoor",
                      "description":
                          "The central library has over 20 million books, 81 journals, 542 e-journals and 10 newspapers",
                      "floor": "NA",
                      "hotspots": {
                        "43": "2-Wheeler parking",
                        "-40": "Xerox centre"
                      },
                      "image": "WIT/buildings/outdoor/library.jpg"
                    },
                    "Main Entrance": {
                      "building": "Outdoor",
                      "description":
                          "Walchand Institute of Technology, one of the pioneering self financed Institution in engineering education & research was established in 1983 by SAPDJ Pathshala Trust ( established 1885).",
                      "floor": "NA",
                      "hotspots": {"65": "2-Wheeler parking", "-65": "Canteen"},
                      "image": "WIT/buildings/outdoor/main-entrance.jpg"
                    },
                    "Parking": {
                      "building": "Outdoor",
                      "description": "Parking",
                      "floor": "NA",
                      "hotspots": {
                        "15": "Civil-Mech",
                        "-125": "Back gate",
                        "-40": "Xerox centre"
                      },
                      "image": "WIT/buildings/outdoor/parking.jpg"
                    },
                    "Reading room": {
                      "building": "Main Building",
                      "description": "Reading room",
                      "floor": "Ground floor",
                      "hotspots": {"180": "Library lobby"},
                      "image": "WIT/buildings/library/reading-room.jpg"
                    },
                    "Sports ground": {
                      "building": "Outdoor",
                      "description": "Sports ground",
                      "floor": "NA",
                      "hotspots": {"-110": "Back gate"},
                      "image": "WIT/buildings/outdoor/sports-ground.jpg"
                    },
                    "Xerox centre": {
                      "building": "Outdoor",
                      "description": "Xerox centre",
                      "floor": "NA",
                      "hotspots": {
                        "5": "Library",
                        "90": "Canteen",
                        "-90": "Parking"
                      },
                      "image": "WIT/buildings/outdoor/xerox-shop.jpg"
                    },
                    "about": {
                      "address":
                          "Walchand Institute of Technology, Solapur P.B.No.634, Walchand Hirachand Marg, Ashok Chowk, Solapur – 413006 (Maharashtra)",
                      "clubs": [
                        "Google Developer Student Club",
                        "LOL Coding Club"
                      ],
                      "email": "principal@witsolapur.org",
                      "phone": ["02172652700", "02172653040"],
                      "placement-report":
                          "https://witsolapur.org/training-and-placements/",
                      "programmes": [
                        "Civil Engineering",
                        "Computer Science and Engineering",
                        "Electronics and Computer Engineering",
                        "Electronics and Telecommunication Engineering",
                        "Information Technology",
                        "Mechanical and Automation Engineering",
                        "General Engineering"
                      ],
                      "website": "https://witsolapur.org/"
                    },
                    "acronym": "WIT",
                    "buildings": {
                      "Outdoor": {
                        "NA": [
                          [
                            "Main Entrance",
                            "Canteen",
                            "Xerox centre",
                            "Parking",
                            "Civil-Mech",
                            "2-Wheeler parking",
                            "Sports ground",
                            "Library",
                            "Back gate"
                          ],
                          "WIT/buildings/outdoor/outdoor-floorplan.jpg"
                        ]
                      }
                    },
                    "drawer-header": "WIT/drawer-header.jpg",
                    "lat": "17.668871374166493",
                    "long": "75.922801866673",
                    "query": "Walchand Institute Of Technology ( W.I.T )",
                    "start": "Main Entrance"
                  })
        });
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
                                    map: value),
                              ),
                            ));
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
