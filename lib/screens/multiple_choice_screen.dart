import 'package:flutter/material.dart';
import '../services/decision_services.dart';
import '../widgets/result_display.dart';
import '../utils/colors.dart';

class MultipleChoiceScreen extends StatefulWidget {
  const MultipleChoiceScreen({super.key});

  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  List<String> options = ['A', 'B', 'C', 'D'];
  String result = '';
  bool isLoading = false;


  final List<Color> optionColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
    Colors.blueGrey,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.yellow,
    Colors.redAccent,
    Colors.lightBlue,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.indigoAccent,
    Colors.cyanAccent,
    Colors.amberAccent,
  ];

  void _addNextOptions(){
    if (options.length >=26) {
      _showSnackBar('Maximum 26 options reached');
      return;
    }

    setState(() {
      int nextIndex =  options.length;
      String nextOption = String.fromCharCode(65 + nextIndex);
      options.add(nextOption);
      result = '';
    });
  }

  void _removeLastOption(){
    if (options.length <= 2) {
      _showSnackBar('Need at least 2 options');
      return;
    }

    setState(() {
      String removedOption = options.removeLast();
      if (result == removedOption){
        result = '';
      }
    });
  }

  void _resetToDefault() {
    setState(() {
      options = ['A', 'B', 'C', 'D'];
      result = '';
    });
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }


  Color _getColorForIndex(int index){
    return optionColors[index % optionColors.length];
  }

  void _makeChoice() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    await Future.delayed(Duration(milliseconds: 1500));

    final choice = DecisionService.makeMultipleChoice(options);

    setState(() {
      isLoading = false;
      result = choice;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiple choice'),
        backgroundColor: AppColors.multipleColor,
        foregroundColor: Colors.white,
        actions: [
          // Nút thêm đáp án
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNextOptions,
            tooltip: 'Add more options',
          ),
          // Nút xóa đáp án cuối
          if (options.length > 4)
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: _removeLastOption,
              tooltip: 'Remove last option',
            ),
          // Nút reset
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Reset to A-B-C-D',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.multipleColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16),

              // Hướng dẫn
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Pick random from ${options.length} option:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Press (+) to add ${options.length < 26 ? String.fromCharCode(65 + options.length) : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Hiển thị các đáp án dưới dạng grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    String option = options[index];
                    Color color = _getColorForIndex(index);
                    bool isSelected = result == option;

                    return _buildChoiceBox(option, color, isSelected);
                  },
                ),
              ),

              SizedBox(height: 32),

              // Hiển thị kết quả hoặc loading
              if (isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.multipleColor),
                    SizedBox(height: 16),
                    Text('Choosing...'),
                  ],
                )
              else if (result.isNotEmpty)
                Column(
                  children: [
                    ResultDisplay(
                      result: 'Answer: $result',
                      color: _getColorForIndex(options.indexOf(result)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You should choose $result',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.quiz,
                  size: 80,
                  color: AppColors.multipleColor.withOpacity(0.5),
                ),

              SizedBox(height: 32),

              // Nút chọn ngẫu nhiên
              ElevatedButton(
                onPressed: isLoading ? null : _makeChoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.multipleColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'CHOOSE!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Tự động điều chỉnh số cột dựa trên số lượng đáp án
  int _getCrossAxisCount() {
    if (options.length <= 4) return 2;
    if (options.length <= 9) return 3;
    if (options.length <= 16) return 4;
    return 5;
  }

  Widget _buildChoiceBox(String option, Color color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ] : [],
      ),
      child: Center(
        child: Text(
          option,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
