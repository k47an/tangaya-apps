// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tangaya_apps/constant/constant.dart';
// import '../controllers/auth_controller.dart';

// class PhoneInputPage extends GetView<AuthController> {
//   PhoneInputPage({super.key});
//   final TextEditingController phoneController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Obx(
//                 () => Text(
//                   'Selamat Datang ${controller.googleUser.value?.displayName ?? 'Pengguna'}!',
//                   style: semiBold.copyWith(
//                     fontSize: ScaleHelper(context).scaleTextForDevice(24),
//                     color: Primary.mainColor,
//                   ),
//                 ),
//               ),
//               Obx(
//                 () => TextField(
//                   controller: phoneController,
//                   keyboardType: TextInputType.phone,
//                   decoration: InputDecoration(
//                     labelText: 'Nomor HP (+62...)',
//                     errorText:
//                         controller.isPhoneNumberValid.value
//                             ? null
//                             : 'Nomor HP tidak valid',
//                   ),
//                   onChanged: (value) {
//                     controller.validatePhoneNumber(value);
//                   },
//                 ),
//               ),
//               SizedBox(height: 20),
//               Obx(
//                 () =>
//                     controller.isLoading.value
//                         ? CircularProgressIndicator()
//                         : ElevatedButton(
//                           onPressed: () {
//                             final phone = phoneController.text.trim();
//                             controller.validatePhoneNumber(phone);

//                             if (controller.isPhoneNumberValid.value) {
//                               controller.verifyPhoneNumber(phone);
//                             } else {
//                               Get.snackbar(
//                                 'Error',
//                                 'Nomor HP tidak valid. Silakan periksa kembali.',
//                                 snackPosition: SnackPosition.BOTTOM,
//                               );
//                             }
//                           },
//                           child: Text('Kirim OTP'),
//                         ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
