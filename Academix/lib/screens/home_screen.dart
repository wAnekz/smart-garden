import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard_screen.dart';
import 'automation_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';
import 'garden_data.dart';
import 'garden_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isUpdating = false;
  bool _initialLoading = true;

  // Изначальный объект данных (Заглушка до загрузки)
  GardenData _currentData = GardenData(
    temp: 0,
    humidity: 0,
    condition: "Загрузка...",
    soilTemp: 0,
    lux: 0,
    waterLevel: 0,
    soilMoisture: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchData(isInitial: true);
  }

  // Метод получения данных по API
  Future<void> _fetchData({bool isInitial = false}) async {
    if (isInitial) {
      setState(() => _initialLoading = true);
    } else {
      setState(() => _isUpdating = true);
    }

    try {
      // API Open-Meteo (данные для Алматы но можно поменять легко, даже наверно чтобы юзер сам
      // задавал свой регион)
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=43.25&longitude=76.95&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        int code = current['weather_code'];
        String cond = "Clouds";
        if (code == 0) cond = "Clear";
        else if (code >= 51) cond = "Rain";

        setState(() {
          _currentData = GardenData(
            temp: current['temperature_2m'].toDouble(),
            humidity: current['relative_humidity_2m'].toInt(),
            condition: cond,
            soilTemp: current['temperature_2m'].toDouble() + 2.5,
            lux: cond == "Clear" ? 9000 : 1500,
            waterLevel: 85,
            soilMoisture: 42, // Здесь в будущем будут данные с ESP32
          );
          _initialLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Ошибка обновления данных: $e");
      setState(() => _initialLoading = false);
    } finally {
      if (!isInitial) {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
        ),
      );
    }

    // --- ПОРЯДОК ЭКРАНОВ (Важно для IndexedStack) ---
    final List<Widget> screens = [
      DashboardScreen(gardenData: _currentData), // 0: Статус
      const GardenMapScreen(),                   // 1: Интерактивная карта (Вместо истории)
      AIChatScreen(gardenData: _currentData),    // 2: AI Помощник
      AutomationScreen(),                        // 3: Настройки полива
      ProfileScreen(),                           // 4: Личный кабинет
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            // Авто-обновление данных при переходе на Dashboard или AI
            if (index == 0 || index == 2) {
              _fetchData();
            }
          },
          selectedItemColor: const Color(0xFF1B5E20),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Статус',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded), // Иконка для карты лицея
              label: 'Карта',
            ),
            BottomNavigationBarItem(
              icon: _isUpdating && _currentIndex == 2
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00BCD4),
                ),
              )
                  : const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00BCD4)),
              label: 'AI Помощь',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_input_component),
              label: 'Авто',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}