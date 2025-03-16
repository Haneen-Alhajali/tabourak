import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class introPage2  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 200.0), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          SizedBox(
            width: double.infinity, 
            child: Text(
              "Test Program",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 24, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20), 
          Expanded(
            child: Lottie.asset(
              'assets/lottie/animation2.json',
              width: 500, 
              height: 500, 
              fit: BoxFit.contain, 
            ),
          ),
        ],
      ),
    );
  }
}

