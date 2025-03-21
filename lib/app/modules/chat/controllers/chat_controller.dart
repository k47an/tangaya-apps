import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChatController extends GetxController {
  var messages = <Message>[].obs;
  var messageController = TextEditingController();
  var isTextFieldFocused = false.obs; // Add this line

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      messages.add(
        Message(
          text: messageController.text,
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
      );
      messageController.clear();
    }
  }

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
    messageController.dispose();
    super.onClose();
  }
}

class Message {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}
