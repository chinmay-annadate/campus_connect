import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:panorama/panorama.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:campus_connect/about.dart';
import 'package:campus_connect/about_app.dart';
import 'package:campus_connect/feedback.dart';

import 'package:flutter_tts/flutter_tts.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title, required this.institute})
      : super(key: key);
  final String title;
  final String institute;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Map map = {};
  String current = '';
  String description = '';
  Map floors = {};

  List<String> dropDownList = [];
  String dropDownValue = '';

  List<Hotspot> hotspots = [];

  final storage = FirebaseStorage.instance.ref();

  String bg = '';
  String drawerHeader = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  MapController mapController = MapController();
  double lat = 0.0, long = 0.0;

  void updateCurrent(String next) async {
    current = next;
    final response =
        await storage.child(map[current]['image']).getDownloadURL();
    final newBg = response;

    _zoomController.reset();
    _zoomController.forward().then((value) {
      _fadeController.reverse().then((value) {
        setState(() {
          bg = newBg;
          description = map[current]['description'];
          final angles = map[current]['hotspots'];
          hotspots = [];
          angles.forEach((key, value) {
            hotspots.addAll([
              hotspotMapIcon(double.parse(key)),
              hotspotLabel(double.parse(key) + 8, value),
              hotspotArrowIcon(double.parse(key), value),
            ]);
          });
          _fadeController.forward();
        });
      });
      _zoomController.reset();
      _zoomController.forward();
    });
  }

  Hotspot hotspotMapIcon(double long) {
    return Hotspot(
        longitude: long,
        height: 40,
        width: 35,
        widget: Image.asset('assets/images/map-icon.png'));
  }

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

  void getDrawerHeader(String name) async {
    final response = await storage.child(name).getDownloadURL();
    setState(() {
      drawerHeader = response;
    });
  }

  @override
  void initState() {
    super.initState();
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

    DatabaseReference ref = FirebaseDatabase.instance.ref(widget.institute);
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        map = data as Map;
        updateCurrent(map['start']);
        getDrawerHeader(map['drawer-header']);
        floors = map['floors'];
        dropDownList = floors.keys.toList().cast<String>();
        dropDownValue = dropDownList[0];
        lat = double.parse(map['lat']);
        long = double.parse(map['long']);
      });
    });

    _zoomController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(current),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
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

            // About college
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(
                'About college',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => About(
                          title: map['acronym'],
                          about: map['about'],
                        )),
              ),
            ),

            // Floors dropdown
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: dropDownValue,
                items: dropDownList.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 18),
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

            // map widget
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                  height: 300,
                  width: 500,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(lat, long),
                      zoom: 15,
                    ),
                    nonRotatedChildren: [
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
                          )
                        ],
                      )
                    ],
                  )),
            ),

            // about app
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

            // feedback
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
          ],
        ),
      ),
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
      floatingActionButton: FAB(
          text: description,
        )
    );
  }
}

class FAB extends StatefulWidget {
  const FAB({super.key, required this.text});
  final String text;

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> {
  FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  Future<void> _toggleSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
    } else {
      await flutterTts.speak(widget.text);
    }

    setState(() {
      isSpeaking = !isSpeaking;
    });
  }

  void _onComplete() {
    setState(() {
      isSpeaking = false;
    });
  }

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(_onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: FloatingActionButton(
        onPressed: _toggleSpeaking,
        tooltip: isSpeaking ? 'Stop Speaking' : 'Speak',
        backgroundColor: isSpeaking ? Colors.red : Colors.blue,
        child: Icon(
          isSpeaking ? Icons.volume_off : Icons.volume_up,
          size: 28,
        ),
      ),
      childWhenDragging: Container(), // Empty container when dragging
      child: FloatingActionButton(
        onPressed: _toggleSpeaking,
        tooltip: isSpeaking ? 'Stop Speaking' : 'Speak',
        backgroundColor: isSpeaking ? Colors.red : Colors.blue,
        child: Icon(
          isSpeaking ? Icons.volume_off : Icons.volume_up,
        ),
      ),
    );
  }
}
