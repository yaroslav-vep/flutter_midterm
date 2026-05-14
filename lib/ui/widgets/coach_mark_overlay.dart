import 'package:flutter/material.dart';

/// Данные одной подсказки: ключ элемента, текст и позиция текста
class CoachMarkStep {
  final GlobalKey targetKey;
  final String title;
  final String description;

  const CoachMarkStep({
    required this.targetKey,
    required this.title,
    required this.description,
  });
}

/// Overlay-виджет, который затемняет экран и подсвечивает нужный элемент
class CoachMarkOverlay extends StatefulWidget {
  final List<CoachMarkStep> steps;
  final VoidCallback onFinish;

  const CoachMarkOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _animController.reverse().then((_) {
        setState(() => _currentStep++);
        _animController.forward();
      });
    } else {
      _animController.reverse().then((_) => widget.onFinish());
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStep];
    final renderBox =
        step.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final targetPosition = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;

    // Центр подсвечиваемого элемента
    final center = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Радиус «дырки» вокруг элемента
    final spotlightRadius =
        (targetSize.width > targetSize.height ? targetSize.width : targetSize.height) / 2 + 20;

    // Определяем, показывать подсказку сверху или снизу элемента
    final screenHeight = MediaQuery.of(context).size.height;
    final showBelow = center.dy < screenHeight / 2;

    return FadeTransition(
      opacity: _fadeAnim,
      child: GestureDetector(
        onTap: _nextStep,
        child: Stack(
          children: [
            // Затемнённый фон с вырезом
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _SpotlightPainter(
                center: center,
                radius: spotlightRadius,
              ),
            ),

            // Пульсирующее кольцо вокруг элемента
            Positioned(
              left: center.dx - spotlightRadius,
              top: center.dy - spotlightRadius,
              child: _PulsingRing(radius: spotlightRadius),
            ),

            // Текст подсказки
            Positioned(
              left: 24,
              right: 24,
              top: showBelow ? center.dy + spotlightRadius + 20 : null,
              bottom: showBelow ? null : screenHeight - center.dy + spotlightRadius + 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Индикатор шагов
                        Text(
                          '${_currentStep + 1} из ${widget.steps.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        // Кнопка
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentStep < widget.steps.length - 1
                                ? 'Далее →'
                                : 'Понятно ✓',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Рисует затемнённый фон с прозрачным вырезом (spotlight)
class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;

  _SpotlightPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.7);

    // Рисуем затемнённый фон
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Вырезаем «дырку» вокруг элемента
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawCircle(center, radius, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      center != oldDelegate.center || radius != oldDelegate.radius;
}

/// Пульсирующее кольцо для привлечения внимания
class _PulsingRing extends StatefulWidget {
  final double radius;

  const _PulsingRing({required this.radius});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final scale = 1.0 + _controller.value * 0.15;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.6 - _controller.value * 0.4),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
