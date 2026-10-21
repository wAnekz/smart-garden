import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AutomationScreen extends StatefulWidget {
  @override
  _AutomationViewState createState() => _AutomationViewState();
}

class _AutomationViewState extends State<AutomationScreen> {
  double threshold = 35;
  bool isAutoEnabled = true;
  bool rainSkip = true;
  String selectedPreset = 'Баланс';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Устанавливаем твой стандартный цвет фона
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок в стиле Dashboard
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Умный Сад", style: TextStyle(color: Colors.grey)),
                Text(
                  "Автоматика",
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20)
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 1. ГЛАВНЫЙ ПЕРЕКЛЮЧАТЕЛЬ (Теперь с мягкой тенью как в Dashboard)
            _buildMainToggle(),

            const SizedBox(height: 24),

            _buildSectionTitle("Режим полива"),
            _buildPresetSelector(),

            const SizedBox(height: 24),

            _buildSectionTitle("Порог запуска"),
            _buildThresholdCard(),

            const SizedBox(height: 24),

            _buildSectionTitle("Умные функции"),
            _buildAdvancedSettings(),

            const SizedBox(height: 24),

            _buildSectionTitle("Ближайшие события"),
            _buildScheduleItem("Утренний цикл", "06:00", Icons.wb_twilight, Colors.orange),
            _buildScheduleItem("Вечерний цикл", "20:30", Icons.nightlight_round, Colors.indigo),
          ],
        ),
      ),
    );
  }

  // --- КОМПОНЕНТЫ С ТВОИМИ ЦВЕТАМИ ---

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAutoEnabled ? const Color(0xFF1B5E20) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Авто-режим",
                  style: TextStyle(
                      color: isAutoEnabled ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )
              ),
              Text(
                  isAutoEnabled ? "Система активна" : "Ручное управление",
                  style: TextStyle(color: isAutoEnabled ? Colors.white70 : Colors.grey)
              ),
            ],
          ),
          Switch(
            value: isAutoEnabled,
            onChanged: (v) => setState(() => isAutoEnabled = v),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF81C784),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector() {
    final presets = ['Эко', 'Баланс', 'Турбо'];
    return Row(
      children: presets.map((p) {
        bool isSelected = selectedPreset == p;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedPreset = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected ? [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 8)] : [],
              ),
              child: Center(
                child: Text(
                    p,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThresholdCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Начать полив при", style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                  "${threshold.toInt()}%",
                  style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 18)
              ),
            ],
          ),
          Slider(
            value: threshold, min: 10, max: 80,
            activeColor: const Color(0xFF1B5E20),
            inactiveColor: const Color(0xFFF5F7FA),
            onChanged: isAutoEnabled ? (v) => setState(() => threshold = v) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        children: [
          _buildActionSwitch("Пропуск в дождь", "Использовать данные Open-Meteo", rainSkip, (v) => setState(() => rainSkip = v)),
          _buildActionSwitch("Защита от солнца", "Не поливать в пик жары", true, (v) {}, isLast: true),
        ],
      ),
    );
  }

  Widget _buildActionSwitch(String title, String sub, bool val, Function(bool) onCh, {bool isLast = false}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: val,
        onChanged: isAutoEnabled ? onCh : null,
        activeColor: const Color(0xFF1B5E20),
      ),
      shape: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
    );
  }

  Widget _buildScheduleItem(String title, String time, IconData icon, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]
      ),
      child: Row(
        children: [
          Icon(icon, color: col),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }
}