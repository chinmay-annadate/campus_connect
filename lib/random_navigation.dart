import 'package:flutter/material.dart';

// firebase cloud storage
import 'package:firebase_storage/firebase_storage.dart';

// photoview
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PopupMenu extends StatefulWidget {
  const PopupMenu(
      {super.key,
      required this.buildings,
      required this.updateCurrent,
      required this.currentBuilding,
      required this.currentFloor,
      required this.currentRoom});

  // map of buildings in campus
  final Map buildings;

  // to be called when room value is changed
  final Function(String) updateCurrent;

  // current info
  final String currentBuilding;
  final String currentFloor;
  final String currentRoom;

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  List<String> buildingsDropDownList = [];
  String buildingsDropDownValue = '';

  Map floors = {};
  List<String> floorsDropDownList = [];
  String floorsDropDownValue = '';

  List<String> roomsDropDownList = [];
  String roomsDropDownValue = '';

  // image src for floor plan
  String floorPlan = '';

  // firebase cloud storage instance
  final storage = FirebaseStorage.instance.ref();

  // initialize nav to current room, floor & building
  @override
  void initState() {
    super.initState();
    // extract keys from buildings{} and cast to list<String>: list of buildings
    buildingsDropDownList = widget.buildings.keys.toList().cast<String>();

    // set selected building to current building
    buildingsDropDownValue = widget.currentBuilding;

    // extract floors of current building
    floors = widget.buildings[buildingsDropDownValue];

    // extract keys from floors of current building and cast to list<String>: list of floors in current building
    floorsDropDownList = floors.keys.toList().cast<String>();

    // set selected floor to current floor
    floorsDropDownValue = widget.currentFloor;

    // get list of rooms from current floor
    roomsDropDownList = (floors[floorsDropDownValue][0] as List).cast<String>();

    // set selected room to collected room
    roomsDropDownValue = widget.currentRoom;

    // set image src for current floor
    getFloorPlan(floors[floorsDropDownValue][1]);
  }

  void getFloorPlan(String name) async {
    final response = await storage.child(name).getDownloadURL();
    setState(() {
      floorPlan = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Buildings dropdown
            DropdownButton<String>(
              value: buildingsDropDownValue,
              items: buildingsDropDownList.map<DropdownMenuItem<String>>(
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
                  buildingsDropDownValue = newValue!;

                  floors = widget.buildings[buildingsDropDownValue];
                  floorsDropDownList = floors.keys.toList().cast<String>();
                  floorsDropDownValue = floorsDropDownList[0];

                  roomsDropDownList =
                      (floors[floorsDropDownValue][0] as List).cast<String>();
                  roomsDropDownValue = roomsDropDownList[0];

                  // set image src for current floor
                  getFloorPlan(floors[floorsDropDownValue][1]);
                });
              },
            ),

            // floors dropdown
            DropdownButton<String>(
              value: floorsDropDownValue,
              items: floorsDropDownList.map<DropdownMenuItem<String>>(
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
                  floorsDropDownValue = newValue!;
                  roomsDropDownList =
                      (floors[floorsDropDownValue][0] as List).cast<String>();
                  roomsDropDownValue = roomsDropDownList[0];

                  // set image src for current floor
                  getFloorPlan(floors[floorsDropDownValue][1]);
                });
              },
            ),

            // rooms dropdown
            DropdownButton<String>(
              value: roomsDropDownValue,
              items: roomsDropDownList.map<DropdownMenuItem<String>>(
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
                  roomsDropDownValue = newValue!;
                  Navigator.pop(context);
                  widget.updateCurrent(roomsDropDownValue);
                });
              },
            ),

            // floor plan image
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: PhotoView(
                          minScale: PhotoViewComputedScale.contained,
                          imageProvider: CachedNetworkImageProvider(floorPlan),
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: floorPlan,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            )
          ],
        ),
      ),
    );
  }
}
