import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  String id;
  String title;
  String detail;
  bool fav = false;
  int nCooked;
  Timestamp timestamp;

  Meal({this.id, this.title, this.detail, this.nCooked, this.timestamp});

  factory Meal.fromCloud(QueryDocumentSnapshot snapshot) {
    return Meal(
      id: snapshot.documentID as String,
      title: snapshot["name"] as String,
      nCooked: snapshot["nCooked"] as int,
      timestamp: snapshot["timestamp"] as Timestamp,
    );
  }
}
