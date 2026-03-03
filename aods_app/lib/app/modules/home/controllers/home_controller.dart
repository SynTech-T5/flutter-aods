import 'package:get/get.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  // Track the current index of the bottom navigation bar
  // Default to 1 (Home = center tab)
  final currentIndex = 1.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // Function to change the active page (3 pages: Alert, Home, Dashboard)
  void changePage(int index) {
    if (index >= 0 && index < 3) {
      currentIndex.value = index;
    }
  }
}
