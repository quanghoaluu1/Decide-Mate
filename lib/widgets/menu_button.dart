

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget{
  final String title;
  final IconData iconData;
  final Color color;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.title,
    required this.iconData,
    required this.color,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 60,
      margin: EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            )
          ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 24),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
    ),
    );
  }

}