// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

import 'package:campus_connect/about_app.dart';
import 'package:campus_connect/about.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title, required this.institute});
  final String title;
  final String institute;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map map = {};
  String current = '';
  // String bg = 'assets/images/loading.png';
  // String drawerHeader = 'assets/images/loading.png';
  Map floors = {};
  List<String> dropDownList = [];
  String dropDownValue = '';
  List<Hotspot> hotspots = [];
  final storage = FirebaseStorage.instance.ref();
  var bg =
      '';
  var drawerHeader = '';

  void updateCurrent(String value) {
    current = value;
    // bg = map[current]['image'];
    getBG(map[current]['image']);
    updateHotspots(map[current]['hotspots']);
  }

  void updateHotspots(angles) {
    hotspots = [];

    angles.forEach((key, value) {
      setState(() {
        hotspots.addAll([
          hotspotMapIcon(double.parse(key)),
          hotspotLabel(double.parse(key) + 8, value),
          hotspotArrowIcon(double.parse(key), value),
        ]);
      });
    });
  }

  Hotspot hotspotMapIcon(double long) {
    return Hotspot(
        longitude: long,
        height: 40,
        width: 35,
        widget: Image(image: AssetImage('assets/images/map-icon.png')));
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
            child: Image(image: AssetImage('assets/images/arrow-icon.png'))));
  }

  Hotspot hotspotLabel(double long, String prompt) {
    return Hotspot(
        latitude: -1,
        longitude: long,
        width: 100,
        widget: Text(
          prompt,
          style: TextStyle(backgroundColor: Colors.blue),
        ));
  }

  void getBG(String name) async {
    final response = await storage.child(name).getDownloadURL();
    setState(() {
      bg = response;
    });
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
    DatabaseReference ref = FirebaseDatabase.instance.ref(widget.institute);
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        map = data as Map;
        current = map['start'];
        // getBG(map[current]['image']);
        // getDrawerHeader(map['drawer-header']);
        floors = map['floors'];
        dropDownList = (floors.keys.toList()).map((item) => item as String).toList();
        dropDownValue = dropDownList[0];
        updateHotspots(map[current]['hotspots']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fill,
                image: drawerHeader != 'noImage'
                    ? NetworkImage(drawerHeader)
                    : AssetImage('assets/images/noImageAvailable.png')
                        as ImageProvider,
              )),
              child: Column(
                children: const [],
              )),
          // About college
          TextButton(
              style: ButtonStyle(),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => About(title: widget.title))),
              child: Text(
                'About college',
                style: TextStyle(fontSize: 20),
              )),

          // Floors drop down menu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: dropDownValue,
              items: dropDownList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropDownValue = newValue!;
                });
              },
            ),
          ),

          // Map widget
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 200,
              width: 100,
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Text("Map")],
              ),
            ),
          ),

          // About app
          TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AboutApp(title: widget.title))),
              child: Text(
                'About app',
                style: TextStyle(fontSize: 20),
              ))
        ],
      )),
      body: Panorama(
        key: UniqueKey(),
        hotspots: hotspots,
        child: Image.network(bg.toString()),
      ),
    );
  }
}
