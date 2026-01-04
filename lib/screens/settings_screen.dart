import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _dataUsage = 'minimal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _dataUsage = prefs.getString('data_usage') ?? 'minimal';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('biometric_enabled', _biometricEnabled);
    await prefs.setString('data_usage', _dataUsage);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: AppColors.pureBlack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications
            _buildSectionTitle('Notifications'),
            _buildSwitchTile(
              title: 'Enable Notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
            const SizedBox(height: 24),
            
            // Security
            _buildSectionTitle('Security'),
            _buildSwitchTile(
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
                _saveSettings();
              },
            ),
            const SizedBox(height: 24),
            
            // Data Usage
            _buildSectionTitle('Data Usage'),
            _buildDataUsageSelector(),
            const SizedBox(height: 24),
            
            // App Info
            _buildSectionTitle('App Information'),
            _buildInfoTile('Version', '1.0.0'),
            _buildInfoTile('Build', '1'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.pureBlack,
          ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.pureBlack,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.blackSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.pureBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Usage Mode',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: const Text('Minimal'),
            subtitle: const Text('Use less data, works on slow connections'),
            value: 'minimal',
            groupValue: _dataUsage,
            onChanged: (value) {
              setState(() {
                _dataUsage = value!;
              });
              _saveSettings();
            },
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('Normal'),
            subtitle: const Text('Standard data usage'),
            value: 'normal',
            groupValue: _dataUsage,
            onChanged: (value) {
              setState(() {
                _dataUsage = value!;
              });
              _saveSettings();
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        border: Border.all(color: AppColors.dividerColor),
        borderRadius: BorderRadius.circular(AppTheme.minimalRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.pureBlack,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.blackSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

