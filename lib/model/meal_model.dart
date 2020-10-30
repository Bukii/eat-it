import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String id;
  String title;
  String detail;
  bool fav;
  Timestamp timestamp;

  Meal({this.id, this.title, this.detail, this.fav, this.timestamp});

  factory Meal.fromCloud(QueryDocumentSnapshot snapshot) {
    return Meal(
      id: snapshot.documentID as String,
      title: snapshot["name"] as String,
      fav: snapshot["fav"] as bool,
      timestamp: snapshot["timestamp"] as Timestamp,
    );
  }
}
