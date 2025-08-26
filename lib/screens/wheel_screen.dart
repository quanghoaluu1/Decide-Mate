import 'package:flutter/material.dart';
import 'dart:math';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  _WheelScreenState createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen>
    with TickerProviderStateMixin {
  List<String> options = ['Tùy chọn 1', 'Tùy chọn 2', 'Tùy chọn 3'];
  String result = '';
  bool isSpinning = false;
  bool isEditMode = false;

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  final TextEditingController _textController = TextEditingController();

  // Màu sắc cho các phần của bánh xe
  final List<Color> wheelColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.lime,
    Colors.cyan,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.decelerate),
    );
  }

  void _spinWheel() async {
    if (isSpinning || options.isEmpty) return;

    setState(() {
      isSpinning = true;
      result = '';
    });

    // Random số vòng quay (3-6 vòng) + góc random
    final Random random = Random();
    final double extraRotations = (3 + random.nextDouble() * 3) * 2 * pi;
    final double finalAngle = random.nextDouble() * 2 * pi;
    final double totalRotation = extraRotations + finalAngle;

    _spinAnimation = Tween<double>(
        begin: 0,
        end: totalRotation
    ).animate(CurvedAnimation(
        parent: _spinController,
        curve: Curves.decelerate
    ));

    _spinController.forward(from: 0);

    await Future.delayed(Duration(seconds: 3));

    // Tính toán kết quả dựa trên góc cuối
    final int selectedIndex = _calculateSelectedIndex(finalAngle);

    setState(() {
      isSpinning = false;
      result = options[selectedIndex];
    });
  }

  int _calculateSelectedIndex(double angle) {
    final double sectionAngle = 2 * pi / options.length;
    // Điều chỉnh góc để match với vị trí pointer
    final double adjustedAngle = (2 * pi - angle) % (2 * pi);
    return ((adjustedAngle / sectionAngle).floor()) % options.length;
  }

  void _addOption() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Vui lòng nhập tùy chọn!');
      return;
    }

    if (options.contains(text)) {
      _showSnackBar('Tùy chọn này đã tồn tại!');
      return;
    }

    if (options.length >= 12) {
      _showSnackBar('Tối đa 12 tùy chọn!');
      return;
    }

    setState(() {
      options.add(text);
      _textController.clear();
    });
  }

  void _removeOption(String option) {
    if (options.length <= 2) {
      _showSnackBar('Cần ít nhất 2 tùy chọn!');
      return;
    }

    setState(() {
      options.remove(option);
      if (result == option) {
        result = '';
      }
    });
  }

  void _resetOptions() {
    setState(() {
      options = ['Tùy chọn 1', 'Tùy chọn 2', 'Tùy chọn 3'];
      result = '';
      isEditMode = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bánh xe may mắn'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.visibility : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetOptions,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center( // Thêm Center widget này
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Thêm dòng này
              crossAxisAlignment: CrossAxisAlignment.center, // Thêm dòng này
              children: [
                SizedBox(height: 20),

                if (isEditMode) ...[
                  _buildEditSection(),
                  SizedBox(height: 20),
                ],

                // Bánh xe
                _buildWheelSection(),

                SizedBox(height: 30),

                // Kết quả
                _buildResultSection(),

                SizedBox(height: 30),

                // Nút quay
                _buildSpinButton(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tùy chỉnh tùy chọn:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Input thêm option
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tùy chọn mới...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => _addOption(),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addOption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Icon(Icons.add),
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            'Tùy chọn hiện tại (${options.length}):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),

          // Danh sách options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.asMap().entries.map((entry) {
              int index = entry.key;
              String option = entry.value;
              Color color = wheelColors[index % wheelColors.length];

              return Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (options.length > 2)
                      GestureDetector(
                        onTap: () => _removeOption(option),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    SizedBox(width: 8),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelSection() {
    return Center( // Thêm Center
      child: Container(
        width: 300,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bánh xe
            AnimatedBuilder(
              animation: _spinAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinAnimation.value,
                  child: CustomPaint(
                    size: Size(280, 280),
                    painter: WheelPainter(options, wheelColors),
                  ),
                );
              },
            ),

            // Pointer (mũi tên chỉ) - Sửa vị trí
            Positioned(
              top: 0, // Thay đổi từ 10 thành 0
              child: Container(
                width: 0,
                height: 0,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 15, color: Colors.transparent),
                    right: BorderSide(width: 15, color: Colors.transparent),
                    bottom: BorderSide(width: 30, color: Colors.black),
                  ),
                ),
              ),
            ),

            // Center circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Center(
                child: Icon(Icons.center_focus_strong, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildResultSection() {
    return Center( // Thêm Center
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isSpinning)
            Column(
              children: [
                CircularProgressIndicator(color: Colors.deepPurple),
                SizedBox(height: 16),
                Text(
                  'Đang quay...',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else if (result.isNotEmpty)
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🎉 Kết quả:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '"$result"',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Bánh xe đã chọn cho bạn!',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          else
            Text(
              'Nhấn nút quay để bắt đầu!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildSpinButton() {
    return Center( // Thêm Center
      child: Container(
        width: 220,
        height: 60,
        child: ElevatedButton(
          onPressed: (isSpinning || options.isEmpty) ? null : _spinWheel,
          style: ElevatedButton.styleFrom(
            backgroundColor: isSpinning ? Colors.grey : Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: isSpinning ? 2 : 8,
            shadowColor: Colors.deepPurple.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Column( // Đổi từ Row sang Column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSpinning)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(Icons.refresh, size: 24),
              SizedBox(height: 4),
              Text(
                isSpinning ? 'ĐANG QUAY...' : 'QUAY BÁNH XE!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _spinController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

// Custom Painter để vẽ bánh xe
class WheelPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  WheelPainter(this.options, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = 2 * pi / options.length;

    for (int i = 0; i < options.length; i++) {
      final startAngle = i * sectionAngle - pi / 2; // -pi/2 để bắt đầu từ trên
      final color = colors[i % colors.length];

      // Vẽ section
      final paint = Paint()..color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Vẽ đường viền
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Vẽ text
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.7;
      final textCenter = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textCenter.dx - textPainter.width / 2,
          textCenter.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
