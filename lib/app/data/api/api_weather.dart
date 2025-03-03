class ApiWeather {
  static const String apiKey = "2e6aa4ecac0835843c2b6d0412b1319c";
  static const String baseUrl = "https://api.openweathermap.org/data/2.5";

  static String currentWeather(double lat, double lon) {
    return "$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
  }

  static String forecast(double lat, double lon) {
    return "$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
  }
}