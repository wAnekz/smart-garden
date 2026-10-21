class GardenData {
  final double temp;
  final int humidity;
  final String condition;
  final double soilTemp;
  final int lux;
  final int waterLevel;
  final int soilMoisture; // Добавили влажность почвы

  GardenData({
    required this.temp,
    required this.humidity,
    required this.condition,
    required this.soilTemp,
    required this.lux,
    required this.waterLevel,
    required this.soilMoisture, // Не забываем в конструкторе
  });

  String toSystemPrompt() {
    return "Данные сада: Воздух $temp°C, влажность $humidity%, погода $condition. "
        "Почва: влажность $soilMoisture%, температура $soilTemp°C. "
        "Свет: $lux лк. Бак: $waterLevel%.";
  }
}