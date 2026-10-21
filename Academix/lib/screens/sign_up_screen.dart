import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Добавили шрифты
import 'sign_in_screen.dart';
import '../custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Для индикатора загрузки на кнопке
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, заполните все поля'))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'country': null,
        'created_at': DateTime.now(),
      });

      if (mounted) {
        Navigator.pushReplacement( // Используем replacement, чтобы нельзя было вернуться назад
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ошибка: ${e.message}';
      if (e.code == 'email-already-in-use') message = 'Этот Email уже используется';
      if (e.code == 'weak-password') message = 'Слишком слабый пароль';
      if (e.code == 'invalid-email') message = 'Некорректный формат почты';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Твой стандартный фон
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // 1. Красивая иконка или изображение
              Container(
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B5E20).withOpacity(0.05),
                ),
                child: const Center(
                  child: Icon(
                      Icons.local_florist_rounded,
                      size: 100,
                      color: Color(0xFF1B5E20)
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Заголовок
              Text(
                "Регистрация",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
              Text(
                "Создайте профиль для управления садом",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // 3. Поля ввода (оборачиваем в контейнеры для стиля, если CustomTextField позволяет)
              CustomTextField(
                labelText: 'Имя',
                hintText: 'Ваше имя',
                controller: _nameController,
                suffixIcon: const Icon(Icons.account_circle_outlined, color: Color(0xFF1B5E20)),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                labelText: 'Электронная почта',
                hintText: 'name@example.com',
                controller: _emailController,
                suffixIcon: const Icon(Icons.mail_outline, color: Color(0xFF1B5E20)),
              ),

              const SizedBox(height: 20),

              CustomTextField(
                labelText: 'Пароль',
                hintText: 'Минимум 6 символов',
                obscureText: !_isPasswordVisible,
                controller: _passwordController,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // 4. Кнопка регистрации
              GestureDetector(
                onTap: _isLoading ? null : _signUp,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E20).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Создать аккаунт',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 5. Текст "Войти"
              RichText(
                text: TextSpan(
                  text: "Уже есть аккаунт? ",
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: "Войти",
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}