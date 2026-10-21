import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'garden_data.dart';

class DashboardScreen extends StatelessWidget {
  // Принимаем данные напрямую из HomeScreen
  final GardenData gardenData;

  const DashboardScreen({super.key, required this.gardenData});

  // Вспомогательный метод для цветов (оставляем логику здесь для красоты)
  List<Color> _getDynamicColors() {
    final condition = gardenData.condition;
    if (condition == "Clear") return [const Color(0xFFFF9800), const Color(0xFFF44336)];
    if (condition == "Rain") return [const Color(0xFF1976D2), const Color(0xFF64B5F6)];
    if (condition == "Snow") return [const Color(0xFF4FC3F7), const Color(0xFF0277BD)];
    return [const Color(0xFF1B5E20), const Color(0xFF4CAF50)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getDynamicColors();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHealthCard(colors),
                  const SizedBox(height: 20),
                  _buildWeatherStatsRow(),
                  const SizedBox(height: 20),
                  _buildWeatherRow(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildSensorGrid(),
          SliverToBoxAdapter(child: _buildActivityLog()),
        ],
      ),
    );
  }

  // --- UI МЕТОДЫ ИСПОЛЬЗУЮТ gardenData ---

  Widget _buildWeatherStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _miniStat(Icons.air, "12.5 км/ч", "Ветер"), // Можно добавить в GardenData позже
        _miniStat(Icons.compress, "1013 hPa", "Давление"),
        _miniStat(Icons.wb_sunny_outlined, "4.2", "UV Индекс"),
      ],
    );
  }

  Widget _miniStat(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Умный Сад", style: TextStyle(color: Colors.grey)),
                Text(
                  gardenData.condition == "Rain" ? "Полив на паузе" : "Система Активна",
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ],
            ),
            _buildLiveBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.green),
          SizedBox(width: 5),
          Text("LIVE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHealthCard(List<Color> colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 35, lineWidth: 6, percent: 0.92,
            center: const Text("92%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            progressColor: Colors.white, backgroundColor: Colors.white24, animation: true,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Состояние растений", style: TextStyle(color: Colors.white70)),
                Text(
                  gardenData.condition == "Rain" ? "Идет дождь" : "Все показатели в норме",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherRow() {
    return Row(children: [
      _buildWeatherTile("${gardenData.temp.toStringAsFixed(1)}°C", "Температура", Icons.thermostat, Colors.orange),
      const SizedBox(width: 15),
      _buildWeatherTile("${gardenData.humidity}%", "Влажность", Icons.water_drop, Colors.blue),
    ]);
  }

  Widget _buildWeatherTile(String val, String label, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(icon, color: col),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))
          ])
        ]),
      ),
    );
  }

  Widget _buildSensorGrid() {
    final sensors = [
      {'t': 'Влажность почвы', 'v': '${gardenData.soilMoisture}%', 'i': Icons.grass, 'c': Colors.green},
      {'t': 'Освещение', 'v': '${gardenData.lux} лк', 'i': Icons.light_mode, 'c': Colors.amber},
      {'t': 'Температура почвы', 'v': '${gardenData.soilTemp.toStringAsFixed(1)}°C', 'i': Icons.landscape, 'c': Colors.brown},
      {'t': 'Бак', 'v': '${gardenData.waterLevel}%', 'i': Icons.waves, 'c': Colors.cyan}
    ];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.3),
        delegate: SliverChildBuilderDelegate(
                (c, i) => Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(sensors[i]['i'] as IconData, color: sensors[i]['c'] as Color),
                  const Spacer(),
                  Text(sensors[i]['v'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(sensors[i]['t'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12))
                ],
              ),
            ),
            childCount: 4),
      ),
    );
  }

  Widget _buildActivityLog() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Лог системы", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _logItem(gardenData.condition == "Rain" ? "Полив отменен (Осадки)" : "Полив по расписанию", "12:30"),
            const Divider(),
            _logItem("Проверка датчиков завершена", "10:00"),
          ],
        ),
      ),
    );
  }

  Widget _logItem(String text, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: const TextStyle(fontSize: 12)),
        Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}