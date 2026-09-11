import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';
import 'package:bmf_customer/features/auth/domain/models/member_profile.dart';

/// Digital Membership ID Card widget displaying member details and QR identifier.
class MemberCard extends StatelessWidget {
  final MemberProfile member;
  final VoidCallback? onQrTap;

  const MemberCard({
    super.key,
    required this.member,
    this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CustomerTheme.primaryNavy,
            Color(0xFF2563EB), // Vibrant Navy Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomerTheme.primaryNavy.withAlpha(70),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo / Bank Brand & QR Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BMF MICROFINANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onQrTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Member ID',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Member Full Name & NRC
          Text(
            member.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'NRC: ${member.nrcFormatted}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 18),

          // Footer: Village Center & Group
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VILLAGE CENTER',
                    style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.centerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'SOLIDARITY GROUP',
                    style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.groupName,
                    style: const TextStyle(
                      color: CustomerTheme.secondaryAmber,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
}
