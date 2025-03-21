part of 'constant.dart';

class ScaleHelper {
  final BuildContext context;

  ScaleHelper(this.context);

  static const double _figmaWidth = 360;
  double get _screenWidth => Get.width;

  double get _scaleFactor => _screenWidth / _figmaWidth;

  bool get _isTablet => _screenWidth >= 600;

  double scaleWidth(double inputWidth) {
    return (inputWidth / _figmaWidth) * _screenWidth;
  }

  double scaleHeight(double inputHeight) {
    return (inputHeight / _figmaWidth) * _screenWidth;
  }

  double scaleText(double inputTextSize) {
    return _scaleFactor * inputTextSize;
  }

  double scaleWidthForDevice(double inputWidth) {
    return _isTablet ? scaleWidth(inputWidth) * 1.5 : scaleWidth(inputWidth);
  }

  double scaleHeightForDevice(double inputHeight) {
    return _isTablet
        ? scaleHeight(inputHeight) * 1.5
        : scaleHeight(inputHeight);
  }

  double scaleTextForDevice(double inputTextSize) {
    return _isTablet
        ? scaleText(inputTextSize) * 1.5
        : scaleText(inputTextSize);
  }
}
