import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';

class ProblemStatusWidget extends StatefulWidget {
  const ProblemStatusWidget({Key? key}) : super(key: key);

  @override
  State<ProblemStatusWidget> createState() => _ProblemStatusWidgetState();
}

class _ProblemStatusWidgetState extends State<ProblemStatusWidget> {
  String _selectedFilter = 'All';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF6B46C1),
        automaticallyImplyLeading: true,
        title: Text(
          'Problem Status',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Statistics Card
            _buildStatisticsCard(),
            
            // Filter Tabs
            _buildFilterTabs(),
            
            // Problems List
            Expanded(
              child: _buildProblemsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddProblemDialog();
        },
        backgroundColor: Color(0xFF6B46C1),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Report Issue', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  
  Widget _buildStatisticsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('water_level_readings')
          .where('userId', isEqualTo: currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        int openCount = 0;
        int inProgressCount = 0;
        int resolvedCount = 0;
        
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['problemStatus'] ?? '';
            
            if (status == 'open') openCount++;
            else if (status == 'in_progress') inProgressCount++;
            else if (status == 'resolved') resolvedCount++;
          }
        }
        
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Problem Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(openCount.toString(), 'Open', Color(0xFFEF4444)),
                  _buildStatItem(inProgressCount.toString(), 'In Progress', Color(0xFFF59E0B)),
                  _buildStatItem(resolvedCount.toString(), 'Resolved', Color(0xFF10B981)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All'),
          SizedBox(width: 8),
          _buildFilterChip('Open'),
          SizedBox(width: 8),
          _buildFilterChip('In Progress'),
          SizedBox(width: 8),
          _buildFilterChip('Resolved'),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Color(0xFF6B46C1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildProblemsList() {
    if (!loggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text('Please log in to view problems'),
          ],
        ),
      );
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('water_level_readings')
          .where('userId', isEqualTo: currentUserUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.report_problem_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No problems reported',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                FFButtonWidget(
                  onPressed: () {
                    _showAddProblemDialog();
                  },
                  text: 'Report First Issue',
                  options: FFButtonOptions(
                    color: Color(0xFF6B46C1),
                    textStyle: TextStyle(color: Colors.white),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Sort by timestamp - newest first
        var filteredDocs = snapshot.data!.docs.where((doc) {
          if (_selectedFilter == 'All') return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final status = data['problemStatus'] ?? '';
          
          if (_selectedFilter == 'Open') return status == 'open';
          if (_selectedFilter == 'In Progress') return status == 'in_progress';
          if (_selectedFilter == 'Resolved') return status == 'resolved';
          
          return true;
        }).toList();
        
        filteredDocs.sort((a, b) {
          final aTime = ((a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)?.toDate();
          final bTime = ((b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)?.toDate();
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        
        if (filteredDocs.isEmpty) {
          return Center(
            child: Text(
              'No ${_selectedFilter.toLowerCase()} problems',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            return _buildProblemCard(data, filteredDocs[index].id);
          },
        );
      },
    );
  }
  
  Widget _buildProblemCard(Map<String, dynamic> data, String docId) {
    String problemTitle = data['problemTitle'] ?? 'Water Level Reading';
    String problemDesc = data['problemDescription'] ?? 'Water level recorded';
    String status = data['problemStatus'] ?? 'open';
    String siteId = data['siteId'] ?? 'Unknown Site';
    
    // Format site name
    if (siteId.toLowerCase().contains('yamuna')) {
      siteId = 'Yamuna-Delhi';
    } else if (siteId.toLowerCase().contains('ganga')) {
      siteId = 'Ganga-Varanasi';
    } else if (siteId.toLowerCase().contains('godavari')) {
      siteId = 'Godavari-Nashik';
    }
    
    double waterLevel = 0.0;
    if (data['waterLevel'] is num) {
      waterLevel = (data['waterLevel'] as num).toDouble();
    } else if (data['waterLevel'] is String) {
      waterLevel = double.tryParse(data['waterLevel']) ?? 0.0;
    }
    
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    
    switch (status) {
      case 'open':
        statusColor = Color(0xFFEF4444);
        statusLabel = 'Open';
        statusIcon = Icons.error_outline;
        break;
      case 'in_progress':
        statusColor = Color(0xFFF59E0B);
        statusLabel = 'In Progress';
        statusIcon = Icons.autorenew;
        break;
      case 'resolved':
        statusColor = Color(0xFF10B981);
        statusLabel = 'Resolved';
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = 'Unknown';
        statusIcon = Icons.help_outline;
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showProblemDetails(data, docId);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      problemTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                problemDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    siteId,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.water_drop, size: 16, color: Colors.blue[400]),
                  SizedBox(width: 4),
                  Text(
                    '${waterLevel.toStringAsFixed(2)}m',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  Text(
                    timestamp != null ? DateFormat('MMM dd, hh:mm a').format(timestamp) : 'Unknown',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showProblemDetails(Map<String, dynamic> data, String docId) {
    String problemTitle = data['problemTitle'] ?? 'Water Level Reading';
    String problemDesc = data['problemDescription'] ?? 'Water level recorded';
    String status = data['problemStatus'] ?? 'open';
    String siteId = data['siteId'] ?? 'Unknown Site';
    
    double waterLevel = 0.0;
    if (data['waterLevel'] is num) {
      waterLevel = (data['waterLevel'] as num).toDouble();
    } else if (data['waterLevel'] is String) {
      waterLevel = double.tryParse(data['waterLevel']) ?? 0.0;
    }
    
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    problemTitle,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(height: 24),
            _buildDetailRow('Description', problemDesc),
            _buildDetailRow('Site', siteId),
            _buildDetailRow('Water Level', '${waterLevel.toStringAsFixed(2)} meters'),
            _buildDetailRow('Timestamp', timestamp != null ? DateFormat('MMM dd, yyyy hh:mm a').format(timestamp) : 'Unknown'),
            _buildDetailRow('Status', status.replaceAll('_', ' ').toUpperCase()),
            SizedBox(height: 24),
            Row(
              children: [
                if (status != 'resolved')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _updateStatus(docId, 'resolved');
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Mark Resolved', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                if (status != 'resolved') SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddProblemDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF6B46C1)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Add Feedback', style: TextStyle(color: Color(0xFF6B46C1))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
  
  void _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('water_level_readings')
          .doc(docId)
          .update({'problemStatus': newStatus});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showAddProblemDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report New Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Problem Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('water_level_readings').add({
                  'userId': currentUserUid,
                  'problemTitle': titleController.text,
                  'problemDescription': descController.text,
                  'problemStatus': 'open',
                  'siteId': 'General',
                  'waterLevel': 0.0,
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Problem reported successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6B46C1)),
            child: Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Problems'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Problems'),
              onTap: () {
                setState(() => _selectedFilter = 'All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Open'),
              onTap: () {
                setState(() => _selectedFilter = 'Open');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('In Progress'),
              onTap: () {
                setState(() => _selectedFilter = 'In Progress');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Resolved'),
              onTap: () {
                setState(() => _selectedFilter = 'Resolved');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
