import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// To parse this JSON data, do
//
//     final searchMap = searchMapFromJson(jsonString);

import 'dart:convert';

SearchMap searchMapFromJson(String str) => SearchMap.fromJson(json.decode(str));
Properties propertiesJson(String str) => Properties.fromJson(json.decode(str));

class SearchMap {
  SearchMap({
    required this.features,
    required this.type,
    required this.bbox,
    required this.license,
  });

  List<Feature> features;
  String type;
  List<double> bbox;
  String license;

  factory SearchMap.fromJson(Map<String, dynamic> json) => SearchMap(
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
        type: json["Type"],
        bbox: List<double>.from(json["bbox"].map((x) => x.toDouble())),
        license: json["License"],
      );
}

class Feature {
  Feature({
    required this.type,
    required this.geometry,
    required this.properties,
    required this.bbox,
    required this.id,
  });

  String type;
  Geometry? geometry;
  Properties? properties;
  List<double>? bbox;
  String id;

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"] == null ? null : json["type"],
        geometry: json["geometry"] == null
            ? null
            : Geometry.fromJson(json["geometry"]),
        properties: json["properties"] == null
            ? null
            : Properties.fromJson(json["properties"]),
        bbox: json["bbox"] == null
            ? null
            : List<double>.from(json["bbox"].map((x) => x.toDouble())),
        id: json["Id"] == null ? null : json["Id"],
      );
}

class Geometry {
  Geometry({
    required this.type,
    required this.coordinates,
  });

  String type;
  List<double> coordinates;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };
}

class Properties {
  Properties({
    required this.layer,
    required this.name,
    required this.housenumber,
    required this.street,
    required this.distance,
    required this.accuracy,
    required this.region,
    required this.regionGid,
    required this.county,
    required this.countyGid,
    required this.locality,
    required this.localityGid,
    required this.label,
  });

  String layer;
  String name;
  String housenumber;
  String street;
  double distance;
  String accuracy;
  String region;
  String regionGid;
  String county;
  String countyGid;
  String locality;
  String localityGid;
  String label;

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        layer: json["layer"],
        name: json["name"],
        housenumber: json["housenumber"],
        street: json["street"],
        distance: json["distance"].toDouble(),
        accuracy: json["accuracy"],
        region: json["region"],
        regionGid: json["region_gid"],
        county: json["county"],
        countyGid: json["county_gid"],
        locality: json["locality"],
        localityGid: json["locality_gid"],
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "layer": layer,
        "name": name,
        "housenumber": housenumber,
        "street": street,
        "distance": distance,
        "accuracy": accuracy,
        "region": region,
        "region_gid": regionGid,
        "county": county,
        "county_gid": countyGid,
        "locality": locality,
        "locality_gid": localityGid,
        "label": label,
      };
}

class Addendum {
  Addendum({
    required this.address,
  });

  String address;

  factory Addendum.fromJson(Map<String, dynamic> json) => Addendum(
        address: json["address"] == null ? null : json["address"],
      );

  Map<String, dynamic> toJson() => {
        "address": address == null ? null : address,
      };
}

class SearchApi with ChangeNotifier {
  List<Feature> _listFeature = [];
  List<Feature> get featureItem {
    return [..._listFeature];
  }

  // call api
  Future<void> fetchAndSetFeatureSearch(String text) async {
    final url = Uri.parse(
        "https://maps.vietmap.vn/api/search?api-version=1.1&apikey=%YOURAPIKEY%&text=${text}");
    List<Feature> exitsData = [];
    if (text.isNotEmpty) {
      try {
        final response = await http.get(url);
        if (response.statusCode >= 404) {
          print("Error Call Api");
          return;
        }
        final exitsFeature = (json.decode(response.body)
            as Map<String, dynamic>)['data']['features'] as List;
        for (var f in exitsFeature) {
          exitsData.add(Feature(
              type: f['type'].toString(),
              geometry:
                  Geometry.fromJson(f['geometry'] as Map<String, dynamic>),
              properties:
                  Properties.fromJson(f['properties'] as Map<String, dynamic>),
              bbox: (f['bbox'] as List)
                  .map((e) => double.parse(e.toString()))
                  .toList(),
              id: f['Id'].toString()));
        }
      } catch (e) {
        print(e.toString());
        throw new Exception(e.toString());
      }
    }
    _listFeature = exitsData;
    notifyListeners();
  }

  Future<void> clearSearchItem() async {
    _listFeature.clear();
    notifyListeners();
  }
}
