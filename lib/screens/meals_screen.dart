import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatit/model/meal_model.dart';
import 'package:flutter/material.dart';

bool _today = false;
String collection = "test-meals";

class MealsScreen extends StatelessWidget {
  final List<Meal> meals = List<Meal>();

  _getFavorites() {
    // Get the ten most cooked ones
    List<Meal> ten = List<Meal>();
    for (int i = 0; i < 10; i++) {
      Meal toAdd;
      meals.forEach((e) {
        if (!ten.contains(e)) {
          if (toAdd != null && e.nCooked > toAdd.nCooked) {
            toAdd = e;
          } else {
            toAdd = e;
          }
        }
      });
      if (toAdd != null) {
        ten.add(toAdd);
      }
    }

    // Favorite this ten meals
    meals.forEach((e) {
      if (ten.contains(e)) {
        e.fav = true;
      }
    });
  }

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
                  if (!snapshot.hasData)
                    return const Center(child: Text("fail!"));

                  // We have to clear the meals list first, because if
                  // we don't do that, meals may get added twice
                  meals.clear();

                  // Loop through all the snapshots/meals convert them to
                  // an object and add them to the list
                  snapshot.data.documents.forEach((e) {
                    meals.add(Meal.fromCloud(e));
                  });
                  // Sort the list by their timestamp, so the ones, that got
                  // cooked lately are at the bottom
                  meals.sort((a, b) => a.timestamp
                      .toDate()
                      .difference(b.timestamp.toDate())
                      .inDays);

                  _getFavorites();

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
                            icon: (meals[index].fav)
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border_rounded),
                            color: (meals[index].fav)
                                ? Colors.redAccent
                                : Colors.grey,
                            splashColor: Colors.redAccent[200],
                            onPressed: () {}),
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
                        onLongPress: () {
                          int nc = meals[index].nCooked + 1;
                          FirebaseFirestore.instance
                              .collection(collection)
                              .doc(meals[index].id)
                              .update({
                            "timestamp": Timestamp.now(),
                            "nCooked": nc,
                          });
                        },
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
          _showAddDialog(context);
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

  _showAddDialog(BuildContext context) {
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
                    "nCooked": 0,
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
