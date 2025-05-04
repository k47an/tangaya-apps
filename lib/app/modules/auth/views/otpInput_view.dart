// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/auth_controller.dart';

// class OtpInputPage extends GetView<AuthController> {
//   OtpInputPage({super.key});
//   final TextEditingController otpController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Masukkan OTP')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(labelText: 'Kode OTP'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 final smsCode = otpController.text.trim();
//                 controller.verifyOtp(smsCode);
//               },
//               child: Text('Verifikasi'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
