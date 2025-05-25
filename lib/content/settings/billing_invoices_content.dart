// lib\content\settings\billing_invoices_content.dart
import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class BillingInvoicesContent extends StatelessWidget {
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
              Text(
                "Billing & Invoices",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Manage your payment preferences.",
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

          SizedBox(height: 16),

          // Invoices Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lightcolor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt,
                  size: 30,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invoices",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "View & download your latest invoices.",
                      style: TextStyle(
                        color: AppColors.textColorSecond,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  // Handle view invoices
                },
                child: Text(
                  "View Invoices",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: AppColors.mediumColor, height: 1),
        ],
      ),
    );
  }
}