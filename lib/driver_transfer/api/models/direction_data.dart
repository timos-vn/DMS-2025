// To parse this JSON data, do
//
//     final directionData = directionDataFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

DirectionData directionDataFromJson(String str) => DirectionData.fromJson(json.decode(str));

String directionDataToJson(DirectionData data) => json.encode(data.toJson());

class DirectionData {
  int? status;
  Data? data;
  String? message;
  CurrentLocation? currentLocation;

  DirectionData({
    this.status,
    this.data,
    this.message,
    this.currentLocation,
  });

  factory DirectionData.fromJson(Map<String, dynamic> json) => DirectionData(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
        currentLocation: json["current_location"] == null
            ? null
            : CurrentLocation.fromJson(json["current_location"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
        "message": message,
        "current_location": currentLocation?.toJson(),
      };
}

class Data {
  List<GeocodedWaypoint>? geocodedWaypoints;
  List<Route>? routes;

  Data({
    this.geocodedWaypoints,
    this.routes,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        geocodedWaypoints: json["geocoded_waypoints"] == null
            ? []
            : List<GeocodedWaypoint>.from(
                json["geocoded_waypoints"]!.map((x) => GeocodedWaypoint.fromJson(x))),
        routes: json["routes"] == null
            ? []
            : List<Route>.from(json["routes"]!.map((x) => Route.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "geocoded_waypoints": geocodedWaypoints == null
            ? []
            : List<dynamic>.from(geocodedWaypoints!.map((x) => x.toJson())),
        "routes": routes == null ? [] : List<dynamic>.from(routes!.map((x) => x.toJson())),
      };
}

class GeocodedWaypoint {
  String? geocoderStatus;
  String? placeId;

  GeocodedWaypoint({
    this.geocoderStatus,
    this.placeId,
  });

  factory GeocodedWaypoint.fromJson(Map<String, dynamic> json) => GeocodedWaypoint(
        geocoderStatus: json["geocoder_status"],
        placeId: json["place_id"],
      );

  Map<String, dynamic> toJson() => {
        "geocoder_status": geocoderStatus,
        "place_id": placeId,
      };
}

class Route {
  Bounds? bounds;
  List<Leg>? legs;
  Polyline? overviewPolyline;
  String? summary;
  List<dynamic>? warnings;
  List<dynamic>? waypointOrder;

  Route({
    this.bounds,
    this.legs,
    this.overviewPolyline,
    this.summary,
    this.warnings,
    this.waypointOrder,
  });

  factory Route.fromJson(Map<String, dynamic> json) => Route(
        bounds: json["bounds"] == null ? null : Bounds.fromJson(json["bounds"]),
        legs: json["legs"] == null ? [] : List<Leg>.from(json["legs"]!.map((x) => Leg.fromJson(x))),
        overviewPolyline:
            json["overview_polyline"] == null ? null : Polyline.fromJson(json["overview_polyline"]),
        summary: json["summary"],
        warnings:
            json["warnings"] == null ? [] : List<dynamic>.from(json["warnings"]!.map((x) => x)),
        waypointOrder: json["waypoint_order"] == null
            ? []
            : List<dynamic>.from(json["waypoint_order"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "bounds": bounds?.toJson(),
        "legs": legs == null ? [] : List<dynamic>.from(legs!.map((x) => x.toJson())),
        "overview_polyline": overviewPolyline?.toJson(),
        "summary": summary,
        "warnings": warnings == null ? [] : List<dynamic>.from(warnings!.map((x) => x)),
        "waypoint_order":
            waypointOrder == null ? [] : List<dynamic>.from(waypointOrder!.map((x) => x)),
      };
}

class Bounds {
  Bounds();

  factory Bounds.fromJson(Map<String, dynamic> json) => Bounds();

  Map<String, dynamic> toJson() => {};
}

class Leg {
  Distance? distance;
  Distance? duration;
  String? endAddress;
  Location? endLocation;
  String? startAddress;
  Location? startLocation;
  List<Step>? steps;

  Leg({
    this.distance,
    this.duration,
    this.endAddress,
    this.endLocation,
    this.startAddress,
    this.startLocation,
    this.steps,
  });

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        distance: json["distance"] == null ? null : Distance.fromJson(json["distance"]),
        duration: json["duration"] == null ? null : Distance.fromJson(json["duration"]),
        endAddress: json["end_address"],
        endLocation: json["end_location"] == null ? null : Location.fromJson(json["end_location"]),
        startAddress: json["start_address"],
        startLocation:
            json["start_location"] == null ? null : Location.fromJson(json["start_location"]),
        steps: json["steps"] == null
            ? []
            : List<Step>.from(json["steps"]!.map((x) => Step.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "distance": distance?.toJson(),
        "duration": duration?.toJson(),
        "end_address": endAddress,
        "end_location": endLocation?.toJson(),
        "start_address": startAddress,
        "start_location": startLocation?.toJson(),
        "steps": steps == null ? [] : List<dynamic>.from(steps!.map((x) => x.toJson())),
      };
}

class Distance {
  String? text;
  int? value;

  Distance({
    this.text,
    this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
        text: json["text"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "value": value,
      };
}

class Location {
  double? lat;
  double? lng;

  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        lat: json["lat"]?.toDouble(),
        lng: json["lng"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Step {
  Distance? distance;
  Distance? duration;
  Location? endLocation;
  String? htmlInstructions;
  String? maneuver;
  Polyline? polyline;
  Location? startLocation;
  String? travelMode;

  Step({
    this.distance,
    this.duration,
    this.endLocation,
    this.htmlInstructions,
    this.maneuver,
    this.polyline,
    this.startLocation,
    this.travelMode,
  });

  factory Step.fromJson(Map<String, dynamic> json) => Step(
        distance: json["distance"] == null ? null : Distance.fromJson(json["distance"]),
        duration: json["duration"] == null ? null : Distance.fromJson(json["duration"]),
        endLocation: json["end_location"] == null ? null : Location.fromJson(json["end_location"]),
        htmlInstructions: json["html_instructions"],
        maneuver: json["maneuver"],
        polyline: json["polyline"] == null ? null : Polyline.fromJson(json["polyline"]),
        startLocation:
            json["start_location"] == null ? null : Location.fromJson(json["start_location"]),
        travelMode: json["travel_mode"],
      );

  Map<String, dynamic> toJson() => {
        "distance": distance?.toJson(),
        "duration": duration?.toJson(),
        "end_location": endLocation?.toJson(),
        "html_instructions": htmlInstructions,
        "maneuver": maneuver,
        "polyline": polyline?.toJson(),
        "start_location": startLocation?.toJson(),
        "travel_mode": travelMode,
      };
}

class Polyline {
  List<PointLatLng>? polylinePoints;

  Polyline({
    this.polylinePoints,
  });

  factory Polyline.fromJson(Map<String, dynamic> json) => Polyline(
        polylinePoints: PolylinePoints().decodePolyline(json["points"]),
      );

  Map<String, dynamic> toJson() => {
        "points": polylinePoints,
      };
}

class CurrentLocation {
  int? id;
  String? employeeId;
  double? lng;
  double? lat;
  DateTime? timeUpdated;

  CurrentLocation({
    this.id,
    this.employeeId,
    this.lng,
    this.lat,
    this.timeUpdated,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) => CurrentLocation(
        id: json["id"],
        employeeId: json["employee_id"],
        lng: json["lng"]?.toDouble(),
        lat: json["lat"]?.toDouble(),
        timeUpdated: json["time_updated"] == null ? null : DateTime.parse(json["time_updated"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "lng": lng,
        "lat": lat,
        "time_updated": timeUpdated?.toIso8601String(),
      };
}
