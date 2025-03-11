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
              final weather = controller.currentWeather.value;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'http://openweathermap.org/img/w/${weather?.weatherIcon ?? '01d'}.png',
                        height: 500,
                        width: 500,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        'Cuaca: ${weather?.weatherDescription ?? 'Tidak tersedia'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Suhu: ${weather?.temperature?.celsius?.toStringAsFixed(1) ?? '0.0'} °C',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kelembaban: ${weather?.humidity ?? 0}%',
                        style: const TextStyle(fontSize: 16),
                      ),
                       Text(
                        'Curah Hujan Terakhir: ${weather?.rainLast3Hours ?? 0} mm',
                        style: const TextStyle(fontSize: 16),
                      ),
           
                    ],
                  ),
                ),
              );
  },),
          ],
        ),
      ),
    );
  }
}
