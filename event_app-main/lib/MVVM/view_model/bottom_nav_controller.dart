import 'package:get/get.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  BottomNavController({int initialIndex = 0}) {
    selectedIndex.value = initialIndex;
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}

