import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String id;
  String title;
  String detail;
  Timestamp timestamp;

  Meal({this.id, this.title, this.detail, this.timestamp});

  factory Meal.fromCloud(QueryDocumentSnapshot snapshot) {
    return Meal(
      id: snapshot.documentID as String,
      title: snapshot["name"] as String,
      timestamp: snapshot["timestamp"] as Timestamp,
    );
  }
}
