import 'package:intl/intl.dart';
import 'package:eatit/model/DishesModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'eat-it',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        home: ChangeNotifierProvider(
            child: MyHomePage(), create: (context) => DishesModel()));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "What meal do I eat next?",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white70),
          onPressed: () {},
        ),
      ),
      body: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              Text(
                "Meal for today!",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 45,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Things you should cook next",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20)
            ],
          ), //to show the clock
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50),
                  topLeft: Radius.circular(50),
                ),
                color: Colors.white,
              ),
              child: Consumer<DishesModel>(
                builder: (context, dishes, child) {
                  return ListView.builder(
                    itemCount: (dishes.mealList.length > 7)
                        ? 7
                        : dishes.mealList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: ListTile(
                          contentPadding: EdgeInsets.only(
                            left: 32,
                            right: 32,
                            top: 4,
                          ),
                          title: Text(
                            dishes.mealList.elementAt(index).getTitle,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            dishes.mealList.elementAt(index).getDetail,
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onLongPress: () => {
                            dishes.deleteMealInList(index),
                          },
                        ),
                        margin: EdgeInsets.only(bottom: 8, left: 16, right: 16),
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Consumer<DishesModel>(
        builder: (context, dishesmodel, child) {
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _displayDialog(context, dishesmodel);
            },
          );
        },
      ),
    );
  }

  _displayDialog(BuildContext context, DishesModel dishesModel) {
    final TextEditingController _textFieldController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Meal'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Meal name"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('Save'),
              onPressed: () {
                dishesModel.addMealInList(_textFieldController.text);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
