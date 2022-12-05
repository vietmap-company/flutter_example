import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// To parse this JSON data, do
//
//     final Routings = RoutingsFromJson(jsonString);

import 'dart:convert';

import 'package:vietmap_sample_api/models/Routes.dart';

Routings RoutingsFromJson(String str) => Routings.fromJson(json.decode(str));

String RoutingsToJson(Routings data) => json.encode(data.toJson());

class Routings {
  Routings({
    required this.distance,
    required this.weight,
    required this.time,
    required this.transfers,
    required this.pointsEncoded,
    required this.bbox,
    required this.points,
    required this.instructions,
    required this.snappedWaypoints,
  });

  double distance;
  double weight;
  int time;
  int transfers;
  bool pointsEncoded;
  List<double> bbox;
  String points;
  List<Instruction> instructions;
  String snappedWaypoints;

  factory Routings.fromJson(Map<String, dynamic> json) => Routings(
        distance: json["distance"].toDouble(),
        weight: json["weight"].toDouble(),
        time: json["time"],
        transfers: json["transfers"],
        pointsEncoded: json["points_encoded"],
        bbox: List<double>.from(json["bbox"].map((x) => x.toDouble())),
        points: json["points"],
        instructions: List<Instruction>.from(
            json["instructions"].map((x) => Instruction.fromJson(x))),
        snappedWaypoints: json["snapped_waypoints"],
      );

  Map<String, dynamic> toJson() => {
        "distance": distance,
        "weight": weight,
        "time": time,
        "transfers": transfers,
        "points_encoded": pointsEncoded,
        "bbox": List<dynamic>.from(bbox.map((x) => x)),
        "points": points,
        "instructions": List<dynamic>.from(instructions.map((x) => x.toJson())),
        "snapped_waypoints": snappedWaypoints,
      };
}

class Instruction {
  Instruction({
    required this.distance,
    required this.heading,
    required this.sign,
    required this.interval,
    required this.text,
    required this.time,
    required this.streetName,
    required this.lastHeading,
  });

  double distance;
  double heading;
  int sign;
  List<int> interval;
  String text;
  int time;
  String streetName;
  double lastHeading;

  factory Instruction.fromJson(Map<String, dynamic> json) => Instruction(
        distance: json["distance"].toDouble(),
        heading: json["heading"].toDouble(),
        sign: json["sign"],
        interval: List<int>.from(json["interval"].map((x) => x)),
        text: json["text"],
        time: json["time"],
        streetName: json["street_name"],
        lastHeading: json["last_heading"] == null
            ? null
            : json["last_heading"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "distance": distance,
        "heading": heading,
        "sign": sign,
        "interval": List<dynamic>.from(interval.map((x) => x)),
        "text": text,
        "time": time,
        "street_name": streetName,
        "last_heading": lastHeading == null ? null : lastHeading,
      };
}

class Routes with ChangeNotifier {
  Routings _routes = Routings(
      distance: 0,
      weight: 0,
      time: 0,
      transfers: 0,
      pointsEncoded: false,
      bbox: List.empty(),
      points: '',
      instructions: List.empty(),
      snappedWaypoints: '');
  Routings get routes {
    return _routes;
  }

  Future<void> fetchAndSetRoutings(String startPoint, String endPoint) async {
    final url = Uri.parse(
        "https://maps.vietmap.vn/api/route?api-version=1.1&apikey=%YOURAPIKEY%&point=${startPoint}&point=${endPoint}");
    try {
      final response = await http.get(url);
      final convertDataToJson =
          (json.decode(response.body) as Map<String, dynamic>)["paths"];
      final paths = (convertDataToJson as List).first;

      var routings = Routings(
          distance: double.parse(paths['distance'].toString()),
          weight: double.parse(paths['weight'].toString()),
          time: int.parse(paths['time'].toString()),
          transfers: int.parse(paths['transfers'].toString()),
          pointsEncoded: true,
          bbox: (paths['bbox'] as List)
              .map((e) => double.parse(e.toString()))
              .toList(),
          points: paths['points'],
          instructions: (paths['instructions'] as List)
              .map((instr) => Instruction(
                  distance: double.parse(instr['distance'].toString()),
                  heading: double.parse(instr['heading'].toString()),
                  sign: int.parse(instr['sign'].toString()),
                  interval: (instr['interval'] as List)
                      .map((e) => int.parse(e.toString()))
                      .toList(),
                  text: instr['text'].toString(),
                  time: int.parse(instr['time'].toString()),
                  streetName: instr['streetName'] ?? '',
                  lastHeading: instr['lastHeading'] ?? 0))
              .toList(),
          snappedWaypoints: paths['snappedWaypoints'].toString());
      _routes = routings;
    } catch (e) {
      print(e.toString());
      throw new Exception(e.toString());
    }
  }
}
