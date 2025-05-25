import 'package:flutter/material.dart';
import 'package:tabourak/colors/app_colors.dart';

class PaymentTabContent extends StatelessWidget {
  const PaymentTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Payment options section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Accept Payments",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Require users to pay before they are able to schedule.",
                style: TextStyle(color: AppColors.textColorSecond),
              ),
              const SizedBox(height: 16),

              // Payment method options
              Column(
                children: [
                  // Don't collect payment option
                  _buildPaymentOption(
                    icon: Icons.block,
                    label: "Don't collect payment",
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  // Stripe option
                  _buildPaymentOption(
                    icon: Icons.credit_card,
                    label: "Collect with Stripe",
                    isSelected: false,
                    onTap: () {},
                    customIcon: Image.asset(
                      'images/stripe_logo.png',
                      height: 20,
                      width: 20,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // PayPal option
                  _buildPaymentOption(
                    icon: Icons.payment,
                    label: "Collect with PayPal",
                    isSelected: false,
                    onTap: () {},
                    customIcon: Image.asset(
                      'images/paypal_logo.png',
                      height: 20,
                      width: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? customIcon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.lightcolor : Colors.white,
        ),
        child: Row(
          children: [
            if (customIcon != null) customIcon,
            if (customIcon == null) Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected)
              const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}