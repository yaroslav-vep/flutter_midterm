import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.quiz_rounded,
      iconColor: Color(0xFF6C63FF),
      bgColor: Color(0xFFEEECFF),
      title: 'Добро пожаловать!',
      subtitle: 'Это приложение поможет вам\nпроверить свои знания по Dart и Flutter.',
    ),
    _OnboardingPage(
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Color(0xFFFF9800),
      bgColor: Color(0xFFFFF3E0),
      title: 'Отвечайте на вопросы',
      subtitle: 'Выбирайте один вариант ответа\nи переходите к следующему вопросу.',
    ),
    _OnboardingPage(
      icon: Icons.emoji_events_rounded,
      iconColor: Color(0xFF4CAF50),
      bgColor: Color(0xFFE8F5E9),
      title: 'Узнайте результат',
      subtitle: 'В конце теста вы увидите ваш балл\nи разбор всех ошибок.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка "Пропустить"
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text(
                  'Пропустить',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

            // Слайды
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildSlide(page);
                },
              ),
            ),

            // Индикаторы (точки)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == i ? 24 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFFD1D1D1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Кнопка "Далее" / "Начать"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Далее' : 'Начать тест!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка в круглом контейнере
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: page.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 90,
              color: page.iconColor,
            ),
          ),

          const SizedBox(height: 48),

          // Заголовок
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Описание
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Вспомогательный класс для хранения данных каждого слайда
class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });
}
