import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SensorConnectScreen extends StatefulWidget {
  const SensorConnectScreen({super.key});

  @override
  State<SensorConnectScreen> createState() => _SensorConnectScreenState();
}

class _SensorConnectScreenState extends State<SensorConnectScreen> {
  bool _isConnecting = false;

  void _handleConnect() async {
    setState(() => _isConnecting = true);

    // Имитируем поиск и подключение датчика (2 секунды)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка подключения
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(
                  Icons.sensors_rounded,
                  size: 80,
                  color: const Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "Подключение датчика",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Убедитесь, что ваш контроллер ESP32 включен и находится в режиме сопряжения",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 60),

              // Кнопка подключения
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isConnecting ? null : _handleConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                  child: _isConnecting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Найти устройство",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen())
                ),
                child: Text(
                  "Пропустить (демо-режим)",
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}