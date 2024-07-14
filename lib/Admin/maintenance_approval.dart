import 'package:flutter/material.dart';
import 'package:unidorms/models/maintenance_service.dart'; // Adjust the import path as necessary
import '../colors.dart';
import 'admin_bottom_navigation.dart';

class MaintenanceApprovalScreen extends StatefulWidget {
  @override
  _MaintenanceApprovalScreenState createState() => _MaintenanceApprovalScreenState();
}

class _MaintenanceApprovalScreenState extends State<MaintenanceApprovalScreen> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  List<Map<String, dynamic>> _maintenanceRequests = [];
  String _adminComment = '';
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRequests();
  }

  Future<void> _loadMaintenanceRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> requests = await _maintenanceService.fetchMaintenanceRequests();
      setState(() {
        _maintenanceRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Log error if necessary
    }
  }

  Future<void> _updateMaintenanceStatus(String status) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic> maintenanceRequest = _maintenanceRequests[_currentIndex];
      String requestId = maintenanceRequest['id'];
      String userId = maintenanceRequest['userId'];
      String username = maintenanceRequest['username'] ?? 'User';
      String issue = maintenanceRequest['issues']?.first ?? 'Issue';

      await _maintenanceService.updateMaintenanceStatus(requestId, status, _adminComment, userId, username, issue);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request $status for $username.'),
        ),
      );

      // Update the local state to reflect the status change
      setState(() {
        _maintenanceRequests[_currentIndex]['status'] = status;
        _adminComment = '';
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating request: $e'),
        ),
      );
    }
  }

  void _nextRequest() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _maintenanceRequests.length;
    });
  }

  void _previousRequest() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _maintenanceRequests.length) % _maintenanceRequests.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Maintenance Requests')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_maintenanceRequests.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Maintenance Requests')),
        body: Center(child: Text('No pending requests')),
      );
    }

    Map<String, dynamic> maintenanceRequest = _maintenanceRequests[_currentIndex];
    String username = maintenanceRequest['username'] ?? '';
    String roomNumber = maintenanceRequest['roomNumber'] ?? 'Unknown';
    String dateRaised = maintenanceRequest['timestamp']?.toDate()?.toString() ?? 'Unknown';
    List<String> issues = (maintenanceRequest['issues'] as List<dynamic>).map((issue) => issue.toString()).toList();
    String issue = issues.isNotEmpty ? issues[0] : 'Issue';
    String status = maintenanceRequest['status'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Maintenance Requests'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.arrow_back, color: AppColors.textBlack),
                    label: Text('Previous', style: TextStyle(color: AppColors.textBlack)),
                    onPressed: _previousRequest,
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.arrow_forward, color: AppColors.textBlack),
                    label: Text('Next', style: TextStyle(color: AppColors.textBlack)),
                    onPressed: _nextRequest,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Table(
                columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
                children: [
                  _buildTableRow('Host', username),
                  _buildTableRow('Room Number', roomNumber),
                  _buildTableRow('Date Raised', dateRaised),
                  _buildTableRow('Issue 1', issues.isNotEmpty ? issues[0] : 'None'),
                  _buildTableRow('Issue 2', issues.length > 1 ? issues[1] : 'None'),
                  _buildTableRow('Issue 3', issues.length > 2 ? issues[2] : 'None'),
                  _buildTableRow('Status', status),
                ],
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: 'Admin Comment'),
                onChanged: (value) {
                  setState(() {
                    _adminComment = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _updateMaintenanceStatus('resolved'),
                    child: Text('Update', style: TextStyle(color: Colors.black)), // Black text color
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundColor, // Background color
                      minimumSize: Size(100, 40), // Reduced size to fit content
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {},
      ),
    );
  }

  TableRow _buildTableRow(String label, String content) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.backlight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              content,
              style: TextStyle(color: AppColors.textBlack),
            ),
          ),
        ),
      ],
    );
  }
}
