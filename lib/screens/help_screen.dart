import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'What is the minimum investment amount?',
      'answer': 'You can start investing with as low as ₹10. There is no maximum limit.',
    },
    {
      'question': 'Is my money safe?',
      'answer':
          'Yes, your investments are safe. We use secure, regulated investment options with low risk.',
    },
    {
      'question': 'How do I earn XP?',
      'answer':
          'You earn XP by completing lessons (50 XP), taking quizzes (20-50 XP), and completing daily challenges (20 XP).',
    },
    {
      'question': 'What are the investment options?',
      'answer':
          'We offer three types of funds: Safe Fund (4-6% returns, very low risk), Growth Fund (6-8% returns, low risk), and Balanced Fund (8-10% returns, medium risk).',
    },
    {
      'question': 'Can I withdraw my money?',
      'answer':
          'Yes, you can withdraw your investments. The process is simple and transparent. Contact support for assistance.',
    },
    {
      'question': 'How do streaks work?',
      'answer':
          'Complete daily challenges to maintain your streak. Each day you complete a challenge, your streak increases. Missing a day resets your streak.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warmWhite,
                border: Border.all(color: AppColors.dividerColor),
                borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.pureBlack,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Contact our support team for assistance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.warmWhite,
                            title: const Text('Contact Support'),
                            content: const Text(
                              'Email: support@microinvest.com\nPhone: +91 1800-XXX-XXXX',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Contact Support'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _faqs.length,
              (index) => _buildFAQItem(index),
            ),
            const SizedBox(height: 24),
            
            // Legal Links
            Text(
              'Legal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.pureBlack,
                  ),
            ),
            const SizedBox(height: 12),
            _buildLegalLink('Terms & Conditions', () {
              _showLegalDialog('Terms & Conditions', 'Terms content here...');
            }),
            _buildLegalLink('Privacy Policy', () {
              _showLegalDialog('Privacy Policy', 'Privacy policy content here...');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    final faq = _faqs[index];
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: ExpansionTile(
        title: Text(
          faq['question']!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.pureBlack,
              ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              faq['answer']!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.blackSecondary,
                    height: 1.5,
                  ),
            ),
          ),
        ],
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedIndex = expanded ? index : null;
          });
        },
      ),
    );
  }

  Widget _buildLegalLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          border: Border.all(color: AppColors.dividerColor),
          borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.pureBlack,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.blackSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.warmWhite,
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blackSecondary,
                  height: 1.5,
                ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

