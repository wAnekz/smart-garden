import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'ТВОЙ_API_КЛЮЧ';
  final String city = 'Moscow'; // Можно заменить на любой город

  Future<Map<String, dynamic>> getSimulatedSensorData() async {
    try {
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        double realTemp = data['main']['temp'].toDouble();
        int realHumidity = data['main']['humidity'];

        // Имитируем, что в саду чуть теплее и влажнее, чем в среднем по городу
        return {
          'temp': realTemp + (Random().nextDouble() * 2), // + 0..2 градуса
          'humidity': (realHumidity + Random().nextInt(5)).clamp(0, 100),
          'condition': data['weather'][0]['main'], // Rain, Clear, Clouds
        };
      }
    } catch (e) {
      print("Ошибка API: $e");
    }
    // Если интернета нет или ошибка — возвращаем дефолтные данные
    return {'temp': 22.0, 'humidity': 45, 'condition': 'Offline'};
  }
}