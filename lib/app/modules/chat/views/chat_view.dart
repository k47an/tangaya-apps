import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Ensure this import is present
import 'package:tangaya_apps/constant/constant.dart';
import 'package:tangaya_apps/app/modules/chat/controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customer Service Chat',
          style: extraBold.copyWith(
            color: Primary.subtleColor,
            fontSize: ScaleHelper.scaleTextForDevice(18),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: ScaleHelper.scaleWidthForDevice(16),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Primary.subtleColor,
        ),
        centerTitle: true,
        backgroundColor: Primary.darkColor,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Primary.darkColor,
                Primary.mainColor,
                Primary.subtleColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.5, 0.9],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      final isUserMessage = message.isUserMessage;
                      return Row(
                        mainAxisAlignment:
                            isUserMessage
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          if (!isUserMessage)
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/dummy/profile.JPG',
                              ),
                              radius: ScaleHelper.scaleWidthForDevice(20),
                            ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isUserMessage
                                      ? Primary.subtleColor
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color:
                                        isUserMessage
                                            ? Primary.darkColor
                                            : Colors.black,
                                    fontSize: ScaleHelper.scaleTextForDevice(14),
                                  ),
                                ),
                                SizedBox(
                                  height: ScaleHelper.scaleHeightForDevice(5),
                                ),
                                Text(
                                  DateFormat(
                                    'hh:mm a',
                                  ).format(message.timestamp),
                                  style: TextStyle(
                                    color:
                                        isUserMessage
                                            ? Primary.darkColor
                                            : Colors.black54,
                                    fontSize: ScaleHelper.scaleTextForDevice(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUserMessage)
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/dummy/profile.JPG',
                              ),
                              radius: 20,
                            ),
                        ],
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          controller.isTextFieldFocused.value = hasFocus;
                        },
                        child: Obx(() {
                          return TextField(
                            controller: controller.messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color:
                                      controller.isTextFieldFocused.value
                                          ? Primary.mainColor
                                          : Colors.grey,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: controller.sendMessage,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
