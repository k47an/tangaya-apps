import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather/weather.dart';
import '../controllers/weather_controller.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Obx(() {
              if (controller.currentWeather.value == null) {
                return const Text('Cuaca belum tersedia');
              }
              final weather = controller.currentWeather.value!;
              return WeatherBox(weather: weather);
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.getCurrentLocation,
              child: const Text('Dapatkan Lokasi'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherBox extends StatelessWidget {
  final Weather weather;

  const WeatherBox({required this.weather, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'http://openweathermap.org/img/w/${weather.weatherIcon}.png',
              width: 100,
              height: 100,
            ),
            Text(
              'Cuaca: ${weather.weatherDescription}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Suhu: ${weather.temperature?.celsius?.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelembaban: ${weather.humidity}%',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
