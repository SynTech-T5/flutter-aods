import 'package:get/get.dart';

class HomeController extends GetxController {
  final count = 0.obs;

  // Track the current index of the bottom navigation bar
  final currentIndex = 0.obs;

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

  // Function to change the active page
  void changePage(int index) {
    if (index >= 0 && index < 4) {
      // Update to 4 pages
      currentIndex.value = index;
    }
  }
}
