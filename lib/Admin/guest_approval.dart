import 'package:flutter/material.dart';
import 'package:unidorms/models/approval_service.dart';
import '../colors.dart';
import 'admin_bottom_navigation.dart';

class GuestApprovalScreen extends StatefulWidget {
  @override
  _GuestApprovalScreenState createState() => _GuestApprovalScreenState();
}

class _GuestApprovalScreenState extends State<GuestApprovalScreen> {
  final ApprovalService _approvalService = ApprovalService();
  List<Map<String, dynamic>> _guestRequests = [];
  int _currentIndex = 0;
  String _adminComment = '';
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadGuestRequests();
  }

  Future<void> _loadGuestRequests() async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> guestRequests = await _approvalService.fetchGuestRequests();
    setState(() {
      _guestRequests = guestRequests;
      _isLoading = false;
    });
  }

  Future<void> _updateGuestRequestStatus(String status) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic> guestRequest = _guestRequests[_currentIndex];
      String guestRequestId = guestRequest['id'];
      String userId = guestRequest['userId'];
      String guestName = guestRequest['guestName'] ?? '';

      await _approvalService.updateGuestRequestStatus(guestRequestId, status, _adminComment, userId, guestName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${status == 'approved' ? 'approved' : 'rejected'} for $guestName.'),
        ),
      );

      // Update the local state to reflect the status change
      setState(() {
        _guestRequests[_currentIndex]['status'] = status;
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
      _currentIndex = (_currentIndex + 1) % _guestRequests.length;
    });
  }

  void _previousRequest() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _guestRequests.length) % _guestRequests.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Guest Approval')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_guestRequests.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Guest Approval')),
        body: Center(child: Text('No pending requests')),
      );
    }

    Map<String, dynamic> guestRequest = _guestRequests[_currentIndex];
    String guestName = guestRequest['guestName'] ?? '';
    String guestPhone = guestRequest['guestPhone'] ?? '';
    String purpose = guestRequest['purpose'] ?? '';
    String visitDate = guestRequest['visitDate']?.toDate()?.toString() ?? '';
    String status = guestRequest['status'] ?? '';
    String username = guestRequest['username'] ?? '';
    String roomNumber = guestRequest['roomNumber'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text('Guest Approval'),
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
                children: [
                  _buildTableRow('Host', Text(username)),
                  _buildTableRow('Room Number', Text(roomNumber)),
                  _buildTableRow('Guest Name', Text(guestName)),
                  _buildTableRow('Guest Phone', Text(guestPhone)),
                  _buildTableRow('Purpose', Text(purpose)),
                  _buildTableRow('Visit Date', Text(visitDate)),
                  _buildTableRow('Status', Text(status)),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _updateGuestRequestStatus('approved'),
                      child: Text('Approve', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _updateGuestRequestStatus('rejected'),
                      child: Text('Reject', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2,
        onItemTapped: (index) {},
      ),
    );
  }

  TableRow _buildTableRow(String label, Widget content) {
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
            child: content,
          ),
        ),
      ],
    );
  }
}
