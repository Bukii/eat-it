class MealModel {

  String _title;
  String detail;
  DateTime _lastTimeCooked;

  String get getTitle => _title;

  String get getDetail => detail;

  DateTime get getLastTimeCooked => _lastTimeCooked;

  MealModel(this._title, {this.detail});

}