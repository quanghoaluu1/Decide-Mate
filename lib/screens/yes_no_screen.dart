import 'package:flutter/material.dart';

import '../services/decision_services.dart';
import '../utils/colors.dart';
import '../widgets/result_display.dart';

class YesNoScreen extends StatefulWidget {
  const YesNoScreen({super.key});

  @override
  _YesNoScreenState createState() => _YesNoScreenState();
}

class _YesNoScreenState extends State<YesNoScreen> {
  String result = '';
  bool isLoading = false;

  void _makeDecision() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    // Giả lập thời gian suy nghĩ
    await Future.delayed(Duration(seconds: 1));

    final decision = DecisionService.makeYesNoDecision();

    setState(() {
      isLoading = false;
      result = decision;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yes or No?'),
        backgroundColor: AppColors.yesColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.yesColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Think about it... and press the button',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // Hiển thị kết quả hoặc loading
            if (isLoading)
              Column(
                children: [
                  CircularProgressIndicator(color: AppColors.yesColor),
                  SizedBox(height: 16),
                  Text('Thinking...'),
                ],
              )
            else if (result.isNotEmpty)
              ResultDisplay(
                result: result,
                color: result == 'Yes' ? AppColors.yesColor : AppColors.noColor,
              )
            else
              Icon(
                Icons.help_outline,
                size: 80,
                color: AppColors.yesColor.withOpacity(0.5),
              ),

            SizedBox(height: 40),
            ElevatedButton(
              onPressed: isLoading ? null : _makeDecision,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yesColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'DECIDE',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
