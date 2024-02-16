// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const TextBox({
    super.key,
    required this.text,
    required this.sectionName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.only(
          left: 15,
          bottom: 15,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Section Name
                Text(
                  sectionName,
                  style: TextStyle(
                      fontFamily: 'PT Sans',
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.grey[700]),
                ),
                // Edit Button
                IconButton(onPressed: onPressed, icon: Icon(Icons.settings))
              ],
            ),

            // Text
            Text(text),
          ],
        ),
      ),
    );
  }
}
