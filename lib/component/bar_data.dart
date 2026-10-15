import 'package:self_made_app/component/individual_bar.dart';

class BarData {
  final double cloths;
  final double eat;
  final double traffic;
  final double entertainment;
  final double others;

  BarData({required this.cloths, required this.eat, required this.traffic, required this.entertainment, required this.others});

  List<IndividualBar> barData = [];

  void initializeBarData(){
    barData = [
      IndividualBar(x: 0, y: cloths),
      IndividualBar(x: 1, y: eat),
      IndividualBar(x: 2, y: traffic),
      IndividualBar(x: 3, y: entertainment),
      IndividualBar(x: 4, y: others),
    ];
  }
}