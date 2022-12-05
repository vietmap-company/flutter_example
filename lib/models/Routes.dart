// To parse this JSON data, do
//
//     final Route = RouteFromJson(jsonString);

import 'dart:convert';

Route RouteFromJson(String str) => Route.fromJson(json.decode(str));

String RouteToJson(Route data) => json.encode(data.toJson());

class  Route {
  Route({
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

  factory Route.fromJson(Map<String, dynamic> json) => Route(
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
