import 'package:get/get.dart';

class ExpandableListController extends GetxController {
  // -1 means no item is expanded
  var expandedIndex = (-1).obs;

  void toggleItem(int index) {
    if (expandedIndex.value == index) {
      expandedIndex.value = -1;
    } else {
      expandedIndex.value = index;
    }
  }
} 