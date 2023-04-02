import 'package:get/get.dart';

class Dimensions {
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double homePageScreenHeight = screenHeight / 1.04;

  static double height10 = screenHeight / 84.4;
  static double height20 = screenHeight / 42.2;
  static double height15 = screenHeight / 56.27;
  static double height30 = screenHeight / 28.13;
  static double height45 = screenHeight / 18.76;

  static double width10 = screenWidth / 84.4;
  static double width20 = screenWidth / 42.2;
  static double width15 = screenWidth / 56.27;
  static double width30 = screenWidth / 28.13;

  // Font size
  static double font20 = screenHeight / 42.2;
  static double font26 = screenHeight / 32.46;
  static double font16 = screenHeight / 52.7;

  // Radius
  static double radius20 = screenHeight / 42.2;
  static double radius30 = screenHeight / 28.13;
  static double radius15 = screenHeight / 56.27;

  // Icon size
  static double iconSize24 = screenHeight / 35.17;
  static double iconSize16 = screenHeight / 52.75;

  // List view size iphone 12 = 390
  static double listViewImgSize = screenWidth / 3.25;
  static double listViewTextConSize = screenWidth / 3.9;

  // popular food
  static double popularFoodImgSize = screenHeight / 2.41;

  // Bottom Height
  static double bottomHeightBar = screenHeight / 7.03;
}
