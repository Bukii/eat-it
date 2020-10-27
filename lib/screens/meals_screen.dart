import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/model/meal_model.dart';
import 'package:flutter/material.dart';

bool _today = false;

class MealsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("What to eat today?"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("meals").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("fail!");

                  // List<Meal> meals = snapshot.data.documents.map((QueryDocumentSnapshot e) => Meal.fromCloud(e)).toList();
                  List<Meal> meals = List<Meal>();
                  snapshot.data.documents.forEach((e) {
                    meals.add(Meal.fromCloud(e));
                  });
                  meals.sort((a, b) => a.timestamp
                      .toDate()
                      .difference(b.timestamp.toDate())
                      .inDays);

                  return ListView.separated(
                    itemCount: snapshot.data.documents.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.only(
                          left: 32,
                          right: 32,
                          top: 4,
                        ),
                        title: Text(
                          meals[index].title,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Vor ${DateTime.now().difference(meals[index].timestamp.toDate()).inDays.toString()} Tagen",
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onLongPress: () => FirebaseFirestore.instance
                            .collection("meals")
                            .doc(meals[index].id)
                            .set({
                          "timestamp": Timestamp.now(),
                        }, SetOptions(merge: true)),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();

    _today = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Füge ein neues Gericht hinzu!"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name für Gericht",
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Gib einen Namen für dein Gericht ein!";
                      }
                      return null;
                    },
                  ),
                  CheckboxField(),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Approve"),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  FirebaseFirestore.instance.collection("meals").add({
                    "name": _nameController.text,
                    "timestamp": (_today)
                        ? Timestamp.fromDate(DateTime.now())
                        : Timestamp.fromDate(DateTime.utc(2000, 1, 1)),
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class CheckboxField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CheckboxFieldState();
}

class CheckboxFieldState extends State<CheckboxField> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text("Machst du dieses Gericht heute?"),
      value: _today,
      onChanged: (bool value) {
        setState(() {
          _today = !_today;
        });
      },
    );
  }
}
