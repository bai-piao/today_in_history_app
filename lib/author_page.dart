import 'package:flutter/material.dart';

class AuthorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'By Luminosity.',
            style: TextStyle(fontSize: 30),
          ),
          Text(
            'Ver_1.0.1'
          ),
          Text(
            '更新计划：日期选择功能，收藏功能，分享功能'
            ),
        ],
      ),
    );
  }
}
