import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vietmap_sample_api/providers/search_map.dart';
import 'package:vietmap_sample_api/screens/search_screen.dart';

import '../providers/routings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String routeName = '/home-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng _latLngLocationStart = LatLng(0, 0);
  LatLng _latLngLocationEnd = LatLng(0, 0);
  LatLng _latLngCenter = LatLng(10.7591746, 106.6760146);
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  late final MapController _mapController;
  List<LatLng> _latLngs = [];
  int _eventKey = 0;
  late final StreamSubscription<MapEvent> mapEventSubscription;
  IconData icon = Icons.gps_not_fixed;
  bool isUserLocation = false;
  bool isRouting = false;
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    mapEventSubscription = _mapController.mapEventStream.listen(
      (event) {
        onMapEvent(event);
      },
    );
    getLocationUser();
  }

  @override
  void dispose() {
    mapEventSubscription.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  void selectSearchScreen(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(SearchScreen.routeName).then((value) {
      if (value != null) {
        List<double> coordinates = value as List<double>;
        _latLngLocationStart = LatLng(coordinates.last, coordinates.first);
        _mapController.move(_latLngLocationStart, _mapController.zoom);
      }
      print(value);
    }).whenComplete(() {
      setState(() {});
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return false;
      }
    }
    return true;
  }

  void getLocationUser() async {
    await getCurrentLocation().then((value) {
      _latLngCenter = LatLng(value.latitude, value.longitude);
      isUserLocation = true;
    });
  }

  void setIcon(IconData newIcon) {
    if (newIcon != icon && mounted) {
      setState(() {
        icon = newIcon;
      });
    }
  }

  void onMapEvent(MapEvent mapEvent) {
    if (mapEvent is MapEventMove && mapEvent.id != _eventKey.toString()) {
      setIcon(Icons.gps_not_fixed);
      print(mapEvent.zoom);
    }
    print(mapEvent);
    if (mapEvent is MapEventLongPress) {
      isRouting = false;
      showDialog(
          context: context,
          builder: (context) {
            return SizedBox(
              height: 100,
              width: 100,
              child: AlertDialog(
                title: const Text("Vui Lòng Chọn"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _latLngLocationStart = LatLng(mapEvent.center.latitude,
                            mapEvent.center.longitude);
                        _latLngs.clear();
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.radio_button_checked,
                            color: Color.fromARGB(66, 26, 25, 25),
                          ),
                          Expanded(child: Text("Điểm Xuất Phát"))
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _latLngLocationEnd = LatLng(mapEvent.center.latitude,
                            mapEvent.center.longitude);
                        _latLngs.clear();
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.radio_button_checked,
                            color: Color.fromARGB(66, 26, 25, 25),
                          ),
                          Expanded(child: Text("Điểm Đến"))
                        ],
                      ),
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"))
                ],
              ),
            );
          });

      print(_latLngLocationStart);
    }
  }

  Future<Position> getCurrentLocation() async {
    var checkPermission = await _handlePermission();
    late Position positionT;
    if (checkPermission) {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      positionT = position;
      //return position;
      // setState(() {});
    }
    return positionT;
  }

  void _moveToCurrent() async {
    _eventKey++;

    try {
      late Position position;
      await getCurrentLocation().then((value) {
        position = value;
        isUserLocation = true;
      });
      final moved = _mapController.move(
        LatLng(position.latitude, position.longitude),
        _mapController.zoom,
        id: _eventKey.toString(),
      );

      setIcon(moved ? Icons.gps_fixed : Icons.gps_not_fixed);
    } catch (e) {
      print(e.toString());
      setIcon(Icons.gps_off);
    }
  }

  @override
  Widget build(BuildContext context) {
    var routingProvider = Provider.of<Routes>(context);

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Vietmap",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
                onPressed: () {
                  selectSearchScreen(context);
                },
                icon: const Icon(Icons.search))
          ],
        ),
        body: Stack(
          children: [
            // ignore: prefer_const_constructors

            FlutterMap(
              options: MapOptions(
                center: _latLngCenter,
                minZoom: 13,
                maxZoom: 18,
              ),
              mapController: _mapController,
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://maps.vietmap.vn/tm/{z}/{x}/{y}@2x.png?apikey=%YOURAPIKEY%',
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayerOptions(polylines: [
                  Polyline(
                      points: _latLngs,
                      color: Colors.blueAccent,
                      strokeWidth: 4),
                ]),
                MarkerLayerOptions(markers: [
                  Marker(
                    point: _latLngCenter,
                    builder: (context) {
                      return !isUserLocation
                          ? Container()
                          : AnimatedOpacity(
                              opacity: 0.8,
                              duration: const Duration(seconds: 2),
                              child: Image.asset(
                                'assets/images/location_user.png',
                                fit: BoxFit.cover,
                                width: 20,
                                height: 20,
                              ),
                            );
                    },
                  ),
                  Marker(
                      point: _latLngLocationStart,
                      builder: (context) {
                        return _latLngLocationStart == LatLng(0, 0)
                            ? Container()
                            : const Icon(
                                Icons.location_on,
                                color: Color.fromARGB(255, 247, 92, 81),
                              );
                      }),
                  Marker(
                      point: _latLngLocationEnd,
                      builder: (context) {
                        return _latLngLocationEnd == LatLng(0, 0)
                            ? Container()
                            : const Icon(
                                Icons.location_on,
                                color: Color.fromARGB(255, 36, 149, 241),
                              );
                      }),
                ], rotate: true),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 16.0, bottom: 8.0),
                    width: 40,
                    child: FloatingActionButton(
                      hoverElevation: 10,
                      onPressed: () {
                        _moveToCurrent();
                      },
                      child: Icon(icon),
                      backgroundColor: Color.fromARGB(204, 242, 242, 241),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16.0, bottom: 8.0),
                    width: 40,
                    child: FloatingActionButton(
                      hoverElevation: 10,
                      onPressed: () async {
                        await routingProvider
                            .fetchAndSetRoutings(
                                "${_latLngLocationStart.latitude},${_latLngLocationStart.longitude}",
                                "${_latLngLocationEnd.latitude},${_latLngLocationEnd.longitude}")
                            .then((value) {
                          decodePolyline(routingProvider.routes.points)
                              .forEach((element) {
                            _latLngs.add(LatLng(element.first.toDouble(),
                                element.last.toDouble()));
                          });
                        }).whenComplete(() {
                          setState(() {});
                        });
                      },
                      child: const Icon(Icons.directions, color: Colors.blue),
                      backgroundColor: Color.fromARGB(204, 242, 242, 241),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
