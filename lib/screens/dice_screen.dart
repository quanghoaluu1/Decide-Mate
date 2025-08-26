import 'package:flutter/material.dart';
import 'dart:math';
import '../services/decision_services.dart';
import '../utils/colors.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key});

  @override
  _DiceScreenState createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen>
    with TickerProviderStateMixin {
  int diceValue = 1;
  bool isRolling = false;

  // Controllers cho các animation khác nhau
  late AnimationController _rotationController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  // Animations
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animation xoay (rotation)
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Animation nảy (bounce)
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.bounceOut),
    );

    // Animation scale
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _rollDice() async {
    if (isRolling) return;

    setState(() {
      isRolling = true;
    });

    // Reset tất cả animations
    _rotationController.reset();
    _bounceController.reset();
    _scaleController.reset();

    // Bắt đầu animation xoay và nảy cùng lúc
    _rotationController.forward();
    _bounceController.forward();

    // Hiệu ứng lăn - thay đổi số liên tục
    List<int> rollingSequence = [];
    for (int i = 0; i < 20; i++) {
      rollingSequence.add(Random().nextInt(6) + 1);
    }

    // Animate qua các số trong sequence
    for (int i = 0; i < rollingSequence.length; i++) {
      await Future.delayed(Duration(milliseconds: 80));
      if (mounted && isRolling) {
        setState(() {
          diceValue = rollingSequence[i];
        });
      }
    }

    // Kết quả cuối cùng
    await Future.delayed(Duration(milliseconds: 200));
    final finalValue = DecisionService.rollDice();

    // Scale effect khi ra kết quả
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    setState(() {
      diceValue = finalValue;
      isRolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Roll Dice'),
        backgroundColor: AppColors.diceColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.diceColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Roll for random number',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),

            // Xúc xắc với animation phức tạp
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotationController,
                _bounceController,
                _scaleController,
              ]),
              builder: (context, child) {
                return Transform.translate(
                  // Hiệu ứng nảy lên xuống
                  offset: Offset(0, -50 * _bounceAnimation.value * (isRolling ? 1 : 0)),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: _buildRealistic3DDice(),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 60),

            // Hiển thị trạng thái
            if (isRolling)
              Column(
                children: [
                  // Hiệu ứng loading với dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoadingDot(0),
                      _buildLoadingDot(200),
                      _buildLoadingDot(400),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rolling...',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.diceColor,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.diceColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.diceColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.casino, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Result: $diceValue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _getDiceMessage(diceValue),
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

            SizedBox(height: 60),

            // Nút tung xúc xắc với hiệu ứng
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: isRolling ? null : _rollDice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRolling ? Colors.grey : AppColors.diceColor,
                  foregroundColor: Colors.white,
                  elevation: isRolling ? 2 : 8,
                  shadowColor: AppColors.diceColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isRolling)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Icon(Icons.casino, size: 12),
                    SizedBox(width: 12),
                    Text(
                      isRolling ? 'ROLLING' : 'ROLLLl!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildRealistic3DDice() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shadow
          Container(
            width: 120,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(60),
            ),
            margin: EdgeInsets.only(top: 110),
          ),

          // Main dice
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(5, 10),
                ),
                // Highlight effect
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 5,
                  offset: Offset(-3, -5),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
              ),
            ),
            child: _buildDiceDots(diceValue),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceDots(int value) {
    return CustomPaint(
      size: Size(120, 120),
      painter: DiceDotsPainter(value),
    );
  }

  Widget _buildLoadingDot(int delay) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: Transform.translate(
            offset: Offset(0, -10 * sin((_bounceController.value * 2 * pi) + (delay / 100))),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.diceColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDiceMessage(int value) {
    switch (value) {
      case 1: return '🎯 Số thấp nhất!';
      case 2: return '🎲 Khá thấp';
      case 3: return '📊 Trung bình thấp';
      case 4: return '📈 Trung bình cao';
      case 5: return '🎪 Khá cao';
      case 6: return '🏆 Số cao nhất!';
      default: return '';
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}

// Custom painter để vẽ chấm trên xúc xắc
class DiceDotsPainter extends CustomPainter {
  final int value;

  DiceDotsPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final dotSize = 12.0;
    final center = Offset(size.width / 2, size.height / 2);

    // Positions for dots
    final positions = {
      1: [center],
      2: [
        Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.75, size.height * 0.75),
      ],
      3: [
        Offset(size.width * 0.25, size.height * 0.25),
        center,
        Offset(size.width * 0.75, size.height * 0.75),
      ],
      4: [
        Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.75, size.height * 0.25),
        Offset(size.width * 0.25, size.height * 0.75),
        Offset(size.width * 0.75, size.height * 0.75),
      ],
      5: [
        Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.75, size.height * 0.25),
        center,
        Offset(size.width * 0.25, size.height * 0.75),
        Offset(size.width * 0.75, size.height * 0.75),
      ],
      6: [
        Offset(size.width * 0.25, size.height * 0.25),
        Offset(size.width * 0.75, size.height * 0.25),
        Offset(size.width * 0.25, size.height * 0.5),
        Offset(size.width * 0.75, size.height * 0.5),
        Offset(size.width * 0.25, size.height * 0.75),
        Offset(size.width * 0.75, size.height * 0.75),
      ],
    };

    // Draw dots with shadow effect
    final dots = positions[value] ?? [center];
    for (final pos in dots) {
      // Shadow
      canvas.drawCircle(
        Offset(pos.dx + 2, pos.dy + 2),
        dotSize / 2,
        Paint()..color = Colors.black.withOpacity(0.3),
      );
      // Main dot
      canvas.drawCircle(pos, dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
