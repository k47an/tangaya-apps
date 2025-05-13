part of '../../constant/constant.dart';

class ScaleHelper {
  static const double _figmaWidth = 360;
  static const double _figmaHeight = 800;

  static double get _screenWidth => Get.width;
  static double get _screenHeight => Get.height;
  static double get _scaleWidthFactor => _screenWidth / _figmaWidth;
  static double get _scaleHeightFactor => _screenHeight / _figmaHeight;

  static bool get _isTablet => _screenWidth >= 600;

  // WIDTH
  static double scaleWidth(double inputWidth) => inputWidth * _scaleWidthFactor;

  static double scaleWidthForDevice(double inputWidth) =>
      _isTablet ? scaleWidth(inputWidth) * 1.5 : scaleWidth(inputWidth);

  // HEIGHT
  static double scaleHeight(double inputHeight) =>
      inputHeight * _scaleHeightFactor;

  static double scaleHeightForDevice(double inputHeight) =>
      _isTablet ? scaleHeight(inputHeight) * 1.5 : scaleHeight(inputHeight);

  // TEXT
  static double scaleText(double inputTextSize) =>
      inputTextSize * _scaleWidthFactor;

  static double scaleTextForDevice(double inputTextSize) =>
      _isTablet ? scaleText(inputTextSize) * 1.5 : scaleText(inputTextSize);

  // PADDING
  static EdgeInsets paddingAll(double value) =>
      EdgeInsets.all(scaleWidthForDevice(value));

  static EdgeInsets paddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) => EdgeInsets.symmetric(
    horizontal: scaleWidthForDevice(horizontal),
    vertical: scaleHeightForDevice(vertical),
  );

  static EdgeInsets paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: scaleWidthForDevice(left),
    top: scaleHeightForDevice(top),
    right: scaleWidthForDevice(right),
    bottom: scaleHeightForDevice(bottom),
  );
}
