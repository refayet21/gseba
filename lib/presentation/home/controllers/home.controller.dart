import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gseba/const/image_constant.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class HomeController extends GetxController {
  late final WebViewController controller;

  @override
  void onInit() {
    super.onInit();
    setupWebView();
  }

  void setupWebView() {
    controller = WebViewController()
      ..setBackgroundColor(Color.fromARGB(0, 255, 254, 254))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(ImageConstant.url))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: handleNavigationRequest,
      ));

    configureGeolocationPermissions();
  }

  Future<NavigationDecision> handleNavigationRequest(
      NavigationRequest navigation) async {
    final url = navigation.url;
    print('Download URL: $url');

    if (url.toLowerCase().contains('/vouchar_print')) {
      final fileName = generateFileName();
      try {
        final filePath = await downloadFile(url, fileName);
        showDownloadSnackBar(filePath);
        return NavigationDecision.prevent;
      } catch (e) {
        print('Error downloading file: $e');
      }
    }

    return NavigationDecision.navigate;
  }

  String generateFileName() {
    final randomInt = Random().nextInt(10000);
    return 'invoice_$randomInt.pdf';
  }

  Future<String> downloadFile(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final directory = await getGsebaDirectory();

    // Save the PDF file inside the "gseba" directory
    final filePath = '${directory}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    print('directory is $filePath');
    // Open the downloaded file
    OpenFile.open('${directory}/$fileName');

    return filePath;
  }

  Future<String> getGsebaDirectory() async {
    final dir = Directory((Platform.isAndroid
                ? await Directory("/storage/emulated/0/Download")
                // ? await getApplicationSupportDirectory()
                : await getApplicationSupportDirectory() //FOR IOS
            )
            .path +
        '/gseba');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  }

  void configureGeolocationPermissions() {
    final platformController = controller.platform;
    if (platformController is AndroidWebViewController) {
      platformController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (request) async {
          final locationPermissionStatus =
              await Permission.locationWhenInUse.request();
          return GeolocationPermissionsResponse(
            allow: locationPermissionStatus == PermissionStatus.granted,
            retain: false,
          );
        },
      );
    }
  }

  void showDownloadSnackBar(String filePath) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
          content: Text('Download completed: ${filePath.split('/').last}')),
    );
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
