import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime eventDate;
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventDate,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json, String docId) {
    return Event(
      id: docId,
      title: json['title'],
      description: json['description'],
      location: json['location'],
      eventDate: (json['eventDate'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'eventDate': eventDate,
      'imageUrl': imageUrl,
    };
  }
}
