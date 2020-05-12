import 'dart:collection';

import 'package:eatit/model/MealModel.dart';
import 'package:flutter/cupertino.dart';

class DishesModel extends ChangeNotifier {

  ListQueue<MealModel> mealList = ListQueue(); //contains all the meals

  addMealInList(String mealName){
    MealModel mealModel = MealModel(mealName, detail: "desc");
    mealList.add(mealModel);
    notifyListeners();
  }

  deleteMealInList(int index){
    mealList.remove(mealList.elementAt(index));
    notifyListeners();
  }

}