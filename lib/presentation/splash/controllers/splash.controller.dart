import 'dart:async';

import 'package:get/get.dart';

import '../../../infrastructure/navigation/routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('SplashScreenController initialized');
  }

  @override
  void onReady() {
    // Future.delayed(const Duration(milliseconds: 3000), () {
    //   Get.offAllNamed(
    //     Routes.HOME,
    //   );
    // });

    Timer(
        Duration(seconds: 3),
        () => Get.offAllNamed(
              Routes.HOME,
            ));
  }

  @override
  void onClose() {
    super.onClose();
  }
}
