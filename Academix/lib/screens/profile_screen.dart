import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in_screen.dart'; // Путь к твоему экрану логина

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileScreen> {
  bool notificationsEnabled = true;
  bool ecoMode = false;

  @override
  Widget build(BuildContext context) {
    // Убираем передачу user, так как заголовок сам его берет
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Исправлено: вызываем без аргумента
            _buildUserHeader(),

            const SizedBox(height: 30),
            _buildStatsRow(),
            const SizedBox(height: 32),
            _buildSectionTitle("Управление устройством"),
            _buildMenuCard([
              _buildMenuItem(Icons.router, "Статус контроллера", trailing: _buildStatusBadge("В сети")),
              _buildMenuItem(Icons.wifi, "Сеть: Smart_Garden_5G", isLast: true),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle("Настройки приложения"),
            _buildMenuCard([
              _buildSwitchItem("Push-уведомления", notificationsEnabled, (v) {
                setState(() => notificationsEnabled = v);
              }),
              _buildSwitchItem("Эко-режим", ecoMode, (v) {
                setState(() => ecoMode = v);
              }, isLast: true),
            ]),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF1B5E20),
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            GestureDetector(
              onTap: () async {
                // Теперь метод внутри класса, и await сработает
                await _showEditProfileSheet(context, currentUser);
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          currentUser?.displayName ?? "Садовод",
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
        ),
        Text(
          currentUser?.email ?? "expert@eco-garden.com",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // ПЕРЕНЕСЕНО ВНУТРЬ КЛАССА: теперь setState здесь определен
  Future<void> _showEditProfileSheet(BuildContext context, User? user) async {
    final TextEditingController nameController = TextEditingController(text: user?.displayName);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 25),
              Text("Редактировать профиль",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20))),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Ваше имя",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    try {
                      String newName = nameController.text.trim();
                      if (newName.isNotEmpty) {
                        await user?.updateDisplayName(newName);
                        await user?.reload();

                        if (context.mounted) Navigator.pop(context);

                        // Теперь это работает, так как мы внутри State
                        setState(() {});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Профиль обновлен!"), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      debugPrint("Ошибка обновления: $e");
                    }
                  },
                  child: Text("Сохранить", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Остальные виджеты без изменений
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem("128л", "Сэкономлено", Icons.savings_outlined),
        const SizedBox(width: 16),
        _buildStatItem("98%", "Здоровье сада", Icons.favorite_border),
      ],
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.green.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Widget? trailing, bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1B5E20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool val, Function(bool) onChanged, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: val,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.red[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text("Выйти из аккаунта",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}