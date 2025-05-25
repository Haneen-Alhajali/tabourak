// lib\content\settings\payments_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class PaymentsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Payments Integrations",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                "Start charging your customers when they schedule with you.",
                style: TextStyle(
                  color: AppColors.textColorSecond,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
          SizedBox(height: 24),

          // Integrations Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Integrations",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 16),
              
              // Stripe Integration
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mediumColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Stripe Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF), // White background for logo
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage('images/stripe_logo.png'), // Add your Stripe logo asset
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Stripe",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Allow your users to pay with their Stripe balance or a credit/debit card.",
                            style: TextStyle(
                              color: AppColors.textColorSecond,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Handle Stripe connection
                        print('Connecting to Stripe...');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        "Connect",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PayPal Integration
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mediumColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // PayPal Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFFFF), // White background for logo
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage('images/paypal_logo.png'), // Add your PayPal logo asset
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PayPal",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Allow your users to pay with their PayPal balance or a credit/debit card.",
                            style: TextStyle(
                              color: AppColors.textColorSecond,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Handle PayPal connection
                        print('Connecting to PayPal...');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        "Connect",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}