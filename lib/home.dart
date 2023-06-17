import 'package:flutter/material.dart';

// firebase rtdb and cloud storage
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

// panorama
import 'package:panorama/panorama.dart';
import 'package:cached_network_image/cached_network_image.dart';

// map widget
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// files
import 'package:campus_connect/about.dart';
import 'package:campus_connect/about_app.dart';
import 'package:campus_connect/feedback.dart';
import 'package:campus_connect/components/random_navigation.dart';
import 'package:campus_connect/components/audio_guide.dart';
import 'package:campus_connect/components/exit_dialog.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title, required this.institute})
      : super(key: key);

  // name of the app, required only for about app page
  final String title;

  // name of selected institute
  final String institute;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  // map of selected institute
  Map map = {};

  // current information
  String currentRoom = '';
  String currentBuilding = '';
  String currentFloor = '';

  // description for audio guide
  String description = '';

  // map of buildings for campus building:{floor:[rooms]}
  Map buildings = {};

  // list of hotspots for panorama
  List<Hotspot> hotspots = [];

  // firebase cloud storage instance
  final storage = FirebaseStorage.instance.ref();

  // current bg
  String bg = '';

  // drawer header for current institute
  String drawerHeader = '';

  // animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  // map controllers and coordinates for institute
  MapController mapController = MapController();
  double lat = 0.0, long = 0.0;

  // used for reverse navigation of current path
  List tourStack = [];

  // default parameter reverse=false
  void updateCurrent(String next, {bool reverse = false}) async {
    // add next state to tourStack
    tourStack.add(next);

    // change current room
    currentRoom = next;

    // get bg image src
    final response =
        await storage.child(map[currentRoom]['image']).getDownloadURL();

    // if reverse is set true then no zoom animation, only fade
    if (reverse) {
      // fade out animation
      _fadeController.reverse().then((value) {
        setState(() {
          // change bg
          bg = response;

          // change current information
          currentBuilding = map[currentRoom]['building'];
          currentFloor = map[currentRoom]['floor'];

          // change audio description
          description = map[currentRoom]['description'];

          // setup hotspots
          final angles = map[currentRoom]['hotspots'];
          hotspots = [];
          angles.forEach((key, value) {
            hotspots.addAll([
              hotspotMapIcon(double.parse(key)),
              hotspotLabel(double.parse(key) + 8, value),
              hotspotArrowIcon(double.parse(key), value),
            ]);
          });
          // fade in animation
          _fadeController.forward();
        });
      });
    } else {
      // zoom in and fade out animation
      _zoomController.reset();
      _zoomController.forward().then((value) {
        _fadeController.reverse().then((value) {
          setState(() {
            // change bg
            bg = response;

            // change current information
            currentBuilding = map[currentRoom]['building'];
            currentFloor = map[currentRoom]['floor'];

            // change audio description
            description = map[currentRoom]['description'];

            // setup hotspots
            final angles = map[currentRoom]['hotspots'];
            hotspots = [];
            angles.forEach((key, value) {
              // converting the string key to double
              final long = double.parse(key);
              hotspots.addAll([
                hotspotMapIcon(long),
                hotspotLabel(long + 8, value),
                hotspotArrowIcon(long, value),
              ]);
            });
            // fade in animation
            _fadeController.forward();
          });
        });
        // zoom out animation
        _zoomController.reset();
        _zoomController.forward();
      });
    }
  }

  // (x, y) => (longitude, latitude)
  // returns a map icon hotspot at (long,0)
  Hotspot hotspotMapIcon(double long) {
    return Hotspot(
        longitude: long,
        height: 40,
        width: 35,
        widget: Image.asset('assets/images/map-icon.png'));
  }

  // returns an arrow icon hotspot that calls updateCurrent(value) onTap at (long+8,-10)
  Hotspot hotspotArrowIcon(double long, String value) {
    return Hotspot(
        height: 120,
        width: 120,
        longitude: long,
        latitude: -10,
        widget: InkWell(
          key: UniqueKey(),
          onTap: () => updateCurrent(value),
          child: Image.asset('assets/images/arrow-icon.png'),
        ));
  }

  // returns a label hotspot with prompt text at (long, -1)
  Hotspot hotspotLabel(double long, String prompt) {
    return Hotspot(
        latitude: -1,
        longitude: long,
        width: 100,
        widget: Text(
          prompt,
          style: const TextStyle(backgroundColor: Colors.blue),
        ));
  }

  // get image src for drawer header
  void getDrawerHeader(String name) async {
    final response = await storage.child(name).getDownloadURL();
    setState(() {
      drawerHeader = response;
    });
  }

  @override
  void initState() {
    super.initState();
    // initialize animation and animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _zoomController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeInOut,
      ),
    );

    _zoomAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _zoomController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _zoomController.stop();
      }
    });

    // reference to rtdb instance
    DatabaseReference ref = FirebaseDatabase.instance.ref(widget.institute);
    ref.onValue.listen((DatabaseEvent event) {
      setState(() {
        // initialize values
        map = event.snapshot.value as Map;
        updateCurrent(map['start']);
        getDrawerHeader(map['drawer-header']);
        buildings = map['buildings'];
        lat = double.parse(map['lat']);
        long = double.parse(map['long']);
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // customizes the functionality of back button
    return WillPopScope(
      onWillPop: () async {
        // removes the last state in tourStack
        tourStack.removeLast();

        // if tour stack is empty, back button will redirect to main.dart
        if (tourStack.isEmpty) {
            return true;
        }

        // else updateCurrent() is called with reverse set true
        // note that last state is removed twice to prevent infinite loop
        // updateCurrent() adds the first parameter to tourStack, this causes the infinte loop
        updateCurrent(tourStack.removeLast(), reverse: true);

        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(currentRoom),
            actions: [
              // random navigation
              IconButton(
                icon: const Icon(Icons.navigation_outlined),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        // pass buildings map, updateCurrent() and current info
                        return PopupMenu(
                            buildings: buildings,
                            updateCurrent: updateCurrent,
                            currentBuilding: currentBuilding,
                            currentFloor: currentFloor,
                            currentRoom: currentRoom);
                      });
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                // drawerheader: image
                DrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: CachedNetworkImageProvider(drawerHeader),
                    ),
                  ),
                  child: const Column(
                    children: [],
                  ),
                ),

                // About college: navagates to about college page
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text(
                    'About college',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        // pass institute acronym and about information
                        builder: (_) => About(
                              title: map['acronym'],
                              about: map['about'],
                            )),
                  ),
                ),

                // map widget
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      height: 300,
                      width: 500,
                      child: FlutterMap(
                        options: MapOptions(
                          // center around institute coordinates
                          center: LatLng(lat, long),
                          zoom: 15,
                        ),
                        nonRotatedChildren: [
                          // flutter map contributer
                          RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                                onTap: () => launchUrl(Uri.parse(
                                    'https://openstreetmap.org/copyright')),
                              ),
                            ],
                          ),
                        ],
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              // map icon that redirects to google map
                              Marker(
                                point: LatLng(lat, long),
                                builder: (ctx) => InkWell(
                                  onTap: () =>
                                      MapsLauncher.launchQuery(map['query']),
                                  child: Image.asset(
                                      height: 50,
                                      width: 50,
                                      'assets/images/map-icon.png'),
                                ),
                              ),

                              // label for map icon
                              Marker(
                                point: LatLng(lat - 0.0002, long + 0.0013),
                                builder: (ctx) => InkWell(
                                  onTap: () =>
                                      MapsLauncher.launchQuery(map['query']),
                                  child: Text(
                                    map['acronym'],
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                ),

                // divider
                const Divider(
                  // thickness: 3,
                  color: Colors.black26,
                  indent: 5,
                  endIndent: 5,
                ),

                // about app: navigates to about app screen
                ListTile(
                  leading: const Icon(Icons.question_mark_outlined),
                  title: const Text(
                    'About app',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutApp(),
                    ),
                  ),
                ),

                // feedback: navigates to feedback page
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text(
                    'Feedback',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeedbackForm(),
                    ),
                  ),
                ),

                // exit virtual tour: redirect to main.dart
                ListTile(
                    leading: const Icon(Icons.exit_to_app_outlined),
                    title: const Text(
                      'Exit Virtual Tour',
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: () async {
                      // wait for confirmation from dialog box
                      bool? exitConfirmed =
                          await showExitConfirmationDialog(context);

                      // if confirmed
                      if (exitConfirmed != null && exitConfirmed) {
                        // if contex mounted
                        if (context.mounted) {
                          // pop drawer
                          Navigator.of(context).pop();

                          // pop home.dart
                          Navigator.of(context).pop();
                        }
                      }
                    }),
              ],
            ),
          ),

          // body: fade, zoom, panorama
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _zoomAnimation,
              child: Panorama(
                  key: UniqueKey(),
                  hotspots: hotspots,
                  child: Image(image: CachedNetworkImageProvider(bg))),
            ),
          ),

          // pass description
          floatingActionButton: FAB(
            text: description,
          )),
    );
  }
}
