import 'package:decidemate/screens/wheel_screen.dart';
import 'package:decidemate/screens/yes_no_screen.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../widgets/menu_button.dart';
import 'dice_screen.dart';
import 'multiple_choice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decision Helper'),
        backgroundColor: AppColors.homeColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.homeColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline,
              size: 80,
              color: AppColors.homeColor,
            ),
            SizedBox(height: 16),
            Text(
              'Let me help you decide!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            MenuButton(
              title: 'Yes/No',
              iconData: Icons.thumbs_up_down,
              color: AppColors.yesColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YesNoScreen()),
                );
              },
            ),
            MenuButton(
              title: 'Multiple choice',
              iconData: Icons.quiz,
              color: AppColors.multipleColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MultipleChoiceScreen()),
                );
              },
            ),
            MenuButton(
              title: 'Roll dice',
              iconData: Icons.casino,
              color: AppColors.diceColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiceScreen()),
                );
              },
            ),
            MenuButton(
              title: 'Bánh xe may mắn',
              iconData: Icons.pie_chart,
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WheelScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}