import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/weather_controller.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return const CircularProgressIndicator();
            }
            return Text(
              controller.currentPosition.value != null
                  ? 'Lat: ${controller.currentPosition.value?.latitude}\nLong: ${controller.currentPosition.value?.longitude}'
                  : 'Lokasi belum tersedia',
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.getCurrentLocation,
            child: const Text('Dapatkan Lokasi'),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.currentWeather.value == null) {
              return const Text('Cuaca belum tersedia');
            }
            final weather = controller.currentWeather.value!;
            return Column(
              children: [
                Text('Cuaca: ${weather.weatherDescription}'),
                Text(
                  'Suhu: ${weather.temperature?.celsius?.toStringAsFixed(1)} °C',
                ),
                Text('Kelembaban: ${weather.humidity}%'),
              ],
            );
          }),
        ],
      ),
    );
  }
}
