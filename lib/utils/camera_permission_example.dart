// ignore_for_file: unused_element, library_private_types_in_public_api

/// 📸 CAMERA PERMISSION HANDLER - EXAMPLE
/// 
/// File này chứa các example để test CameraPermissionHandler
/// Không sử dụng trong production code
/// 
/// Usage:
/// 1. Import file này trong main.dart hoặc test screen
/// 2. Navigate đến CameraPermissionExampleScreen để xem demo
/// 3. Test các scenarios khác nhau

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../themes/colors.dart';
import 'camera_permission_handler.dart';

/// 🎯 Example Screen - Demo tất cả features
class CameraPermissionExampleScreen extends StatefulWidget {
  const CameraPermissionExampleScreen({Key? key}) : super(key: key);

  @override
  _CameraPermissionExampleScreenState createState() => _CameraPermissionExampleScreenState();
}

class _CameraPermissionExampleScreenState extends State<CameraPermissionExampleScreen> {
  PermissionStatus? _currentStatus;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await Permission.camera.status;
    setState(() {
      _currentStatus = status;
      _showBanner = !status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        title: Text('Camera Permission Demo', style: TextStyle(color: white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: white),
            onPressed: _checkStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner (nếu chưa có quyền)
          if (_showBanner)
            CameraPermissionHandler.buildPermissionBanner(context),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Current Status Card
                _buildStatusCard(),
                
                SizedBox(height: 24),
                
                // Actions
                Text(
                  '🎬 Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                
                _buildActionButton(
                  icon: Icons.play_arrow,
                  title: 'Full Permission Flow',
                  subtitle: 'Test toàn bộ flow tự động',
                  color: orange,
                  onTap: _testFullFlow,
                ),
                
                _buildActionButton(
                  icon: Icons.question_answer,
                  title: 'Show Rationale Dialog',
                  subtitle: 'Test educational dialog',
                  color: Colors.blue,
                  onTap: _testRationaleDialog,
                ),
                
                _buildActionButton(
                  icon: Icons.menu_book,
                  title: 'Show Settings Guide',
                  subtitle: 'Test bottom sheet hướng dẫn',
                  color: Colors.purple,
                  onTap: _testSettingsGuide,
                ),
                
                _buildActionButton(
                  icon: Icons.notifications,
                  title: 'Show Snackbar',
                  subtitle: 'Test permission snackbar',
                  color: Colors.teal,
                  onTap: _testSnackbar,
                ),
                
                _buildActionButton(
                  icon: Icons.block,
                  title: 'Show Empty State',
                  subtitle: 'Test empty state screen',
                  color: Colors.red,
                  onTap: _testEmptyState,
                ),
                
                SizedBox(height: 24),
                
                // Utilities
                Text(
                  '🔧 Utilities',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                
                _buildActionButton(
                  icon: Icons.settings,
                  title: 'Open App Settings',
                  subtitle: 'Mở Settings để test manually',
                  color: Colors.grey,
                  onTap: () => openAppSettings(),
                ),
                
                _buildActionButton(
                  icon: Icons.info,
                  title: 'Check Status',
                  subtitle: 'Kiểm tra status hiện tại',
                  color: Colors.indigo,
                  onTap: _testCheckStatus,
                ),
                
                SizedBox(height: 24),
                
                // Tips
                _buildTipsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _currentStatus;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;
    
    if (status == null) {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusText = 'Loading...';
      statusDescription = 'Đang kiểm tra trạng thái';
    } else if (status.isGranted) {
      statusColor = greenColor;
      statusIcon = Icons.check_circle;
      statusText = 'Granted';
      statusDescription = 'Đã có quyền camera';
    } else if (status.isDenied) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber;
      statusText = 'Denied';
      statusDescription = 'Chưa cấp quyền hoặc vừa từ chối';
    } else if (status.isPermanentlyDenied) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = 'Permanently Denied';
      statusDescription = 'Đã từ chối vĩnh viễn (cần mở Settings)';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusText = status.toString();
      statusDescription = 'Trạng thái khác';
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: orange, size: 24),
                SizedBox(width: 8),
                Text(
                  'Camera Permission Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        statusDescription,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Testing Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildTipItem('Test flow "Denied" → "Granted" bằng cách từ chối rồi chấp nhận'),
            _buildTipItem('Test "Permanently Denied" bằng cách từ chối và tích "Don\'t ask again"'),
            _buildTipItem('Reset permission: Settings → Apps → DMS → Permissions → Camera → Clear'),
            _buildTipItem('Refresh status bằng icon refresh ở góc trên'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.blue, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  // Test Methods
  
  Future<void> _testFullFlow() async {
    final granted = await CameraPermissionHandler.handleCameraPermission(context);
    _showResultDialog('Full Flow Result', granted ? 'Permission Granted! ✅' : 'Permission Denied ❌');
    _checkStatus();
  }

  Future<void> _testRationaleDialog() async {
    // Access private method by calling handleCameraPermission
    // Hoặc có thể copy code rationale dialog để test riêng
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note'),
        content: Text('Để test Rationale Dialog, hãy:\n\n1. Clear permission trong Settings\n2. Bấm "Full Permission Flow"\n3. Dialog sẽ tự động xuất hiện'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _testSettingsGuide() {
    // Show bottom sheet manually
    CameraPermissionHandler.handleCameraPermission(context).then((granted) {
      if (!granted) {
        _checkStatus();
      }
    });
  }

  void _testSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.camera_alt, color: white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Cần quyền Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Để quét mã QR và chụp ảnh', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        action: SnackBarAction(
          label: 'Cấp quyền',
          textColor: Colors.yellow,
          onPressed: () async {
            await CameraPermissionHandler.handleCameraPermission(context);
            _checkStatus();
          },
        ),
        duration: Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _testEmptyState() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CameraPermissionHandler.buildCameraPermissionEmptyState(
            context,
            onRetry: () {
              Navigator.pop(context);
              _checkStatus();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _testCheckStatus() async {
    final status = await CameraPermissionHandler.checkCameraPermissionStatus();
    final shouldShow = await CameraPermissionHandler.shouldShowRationale();
    
    _showResultDialog(
      'Status Check Result',
      'Current Status: $status\n'
      'Is Granted: ${status.isGranted}\n'
      'Is Denied: ${status.isDenied}\n'
      'Is Permanently Denied: ${status.isPermanentlyDenied}\n'
      'Should Show Rationale: $shouldShow',
    );
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: orange)),
          ),
        ],
      ),
    );
  }
}

/// 🎯 Quick Test Button - Để thêm vào màn hình nào đó
class QuickCameraPermissionTestButton extends StatelessWidget {
  const QuickCameraPermissionTestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: orange,
      child: Icon(Icons.camera_alt, color: white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPermissionExampleScreen(),
          ),
        );
      },
    );
  }
}

