import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/model/meal_model.dart';
import 'package:flutter/material.dart';

bool _today = false;
String collection = "test-meals";

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
                stream: FirebaseFirestore.instance
                    .collection(collection)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("fail!");

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
                          left: 16,
                          right: 16,
                          top: 4,
                        ),
                        leading: IconButton(
                            icon: (meals[index].fav) ? Icon(Icons.star) : Icon(Icons.star_border_rounded),
                            color: (meals[index].fav) ? Colors.redAccent : Colors.grey,
                            splashColor: Colors.redAccent[200],
                            onPressed: () => FirebaseFirestore.instance
                                    .collection(collection)
                                    .doc(meals[index].id)
                                    .set({
                                  "fav": !meals[index].fav,
                                }, SetOptions(merge: true))),
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
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline),
                          splashColor: Colors.red,
                          splashRadius: 30.0,
                          onPressed: () =>
                              _showDeleteDialog(context, meals[index].id),
                        ),
                        onLongPress: () => FirebaseFirestore.instance
                            .collection(collection)
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

  _showDeleteDialog(BuildContext context, String id) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Are you sure?"),
              content: Text("Willst du es wirklich löschen?"),
              actions: <Widget>[
                FlatButton(
                    textColor: Theme.of(context).disabledColor,
                    onPressed: () => Navigator.pop(context),
                    child: Text("NEIN")),
                FlatButton(
                    onPressed: () => FirebaseFirestore.instance
                        .collection(collection)
                        .doc(id)
                        .delete()
                        .then((value) => Navigator.pop(context)),
                    child: Text("JA"))
              ]);
        });
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
                  FirebaseFirestore.instance.collection(collection).add({
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
