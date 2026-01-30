import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class AdminWidget extends StatefulWidget {
  const AdminWidget({Key? key}) : super(key: key);

  @override
  State<AdminWidget> createState() => _AdminWidgetState();
}

class _AdminWidgetState extends State<AdminWidget> {
  String _selectedTimeRange = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A90E2), // Blue gradient base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'JalRakshak Admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              _showNotifications();
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              _showAdminProfile();
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2), // Bright blue
              Color(0xFF357ABD), // Medium blue
              Color(0xFF2E5F8E), // Darker blue
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, Administrator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Central Water Commission Dashboard',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                _buildSummaryCards(),
                SizedBox(height: 24),
                _buildAlertsSection(),
                SizedBox(height: 24),
                
                Text(
                  'Site Monitoring Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildSitesOverview(),
                
                SizedBox(height: 24),
                
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildRecentActivity(),
                
                SizedBox(height: 24),
                
                Text(
                  'Field Workers Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildFieldWorkersStatus(),
                
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildAdminDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActions();
        },
        backgroundColor: Colors.white,
        icon: Icon(Icons.add, color: Color(0xFF4A90E2)),
        label: Text('Quick Actions', style: TextStyle(color: Color(0xFF4A90E2))),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('water_level_readings')
          .snapshots(),
      builder: (context, snapshot) {
        int totalReadings = 0;
        int todayReadings = 0;
        int criticalAlerts = 0;
        int activeWorkers = 0;
        Set<String> uniqueUsers = {};

        if (snapshot.hasData) {
          totalReadings = snapshot.data!.docs.length;
          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final userId = data['userId'] ?? '';

            if (timestamp != null && timestamp.isAfter(todayStart)) {
              todayReadings++;
            }

            if (userId.isNotEmpty) {
              uniqueUsers.add(userId);
            }

            double waterLevel = 0.0;
            if (data['waterLevel'] is num) {
              waterLevel = (data['waterLevel'] as num).toDouble();
            } else if (data['waterLevel'] is String) {
              waterLevel = double.tryParse(data['waterLevel']) ?? 0.0;
            }

            if (waterLevel > 200) {
              criticalAlerts++;
            }
          }

          activeWorkers = uniqueUsers.length;
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Readings',
                    totalReadings.toString(),
                    Icons.water_drop,
                    Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Today',
                    todayReadings.toString(),
                    Icons.today,
                    Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Critical Alerts',
                    criticalAlerts.toString(),
                    Icons.warning_amber,
                    Colors.redAccent,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Active Workers',
                    activeWorkers.toString(),
                    Icons.people,
                    Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('water_level_readings')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        List<Map<String, dynamic>> alerts = [];

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          double waterLevel = 0.0;

          if (data['waterLevel'] is num) {
            waterLevel = (data['waterLevel'] as num).toDouble();
          } else if (data['waterLevel'] is String) {
            waterLevel = double.tryParse(data['waterLevel']) ?? 0.0;
          }

          if (waterLevel > 200) {
            alerts.add({
              'site': data['siteId'] ?? 'Unknown',
              'level': waterLevel,
              'timestamp': data['timestamp'],
              'severity': 'critical',
            });
          }
        }

        if (alerts.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Systems Normal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'No critical alerts at this time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${alerts.length} Active Alert${alerts.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showAllAlerts(alerts);
                    },
                    child: Text('View All', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSitesOverview() {
    final sites = [
      {'name': 'Yamuna-Delhi', 'location': 'ITO Bridge', 'status': 'normal', 'lastReading': '23.45m', 'workers': 8},
      {'name': 'Ganga-Varanasi', 'location': 'Malviya Bridge', 'status': 'warning', 'lastReading': '68.12m', 'workers': 6},
      {'name': 'Godavari-Nashik', 'location': 'Gangapur Dam', 'status': 'normal', 'lastReading': '18.75m', 'workers': 5},
    ];

    return Column(
      children: sites.map((site) => _buildSiteCard(site)).toList(),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    Color statusColor = site['status'] == 'normal' ? Colors.greenAccent : Colors.orangeAccent;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site['name'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      site['location'],
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  site['status'].toString().toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: Colors.white.withOpacity(0.3)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Last Reading', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                    Text(site['lastReading'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workers', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
                    Text('${site['workers']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('water_level_readings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        var sortedDocs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTime = ((a.data() as Map)['timestamp'] as Timestamp?)?.toDate();
            final bTime = ((b.data() as Map)['timestamp'] as Timestamp?)?.toDate();
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

        var recentDocs = sortedDocs.take(5).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: recentDocs.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.2)),
            itemBuilder: (context, index) {
              final data = recentDocs[index].data() as Map<String, dynamic>;
              return _buildActivityItem(data);
            },
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> data) {
    String siteId = data['siteId'] ?? 'Unknown';
    double waterLevel = 0.0;

    if (data['waterLevel'] is num) {
      waterLevel = (data['waterLevel'] as num).toDouble();
    } else if (data['waterLevel'] is String) {
      waterLevel = double.tryParse(data['waterLevel']) ?? 0.0;
    }

    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.3),
        child: Icon(Icons.water_drop, color: Colors.white, size: 20),
      ),
      title: Text('Reading at $siteId', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text('${waterLevel.toStringAsFixed(2)}m recorded', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
      trailing: Text(
        timestamp != null ? DateFormat('hh:mm a').format(timestamp) : '',
        style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildFieldWorkersStatus() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('water_level_readings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        Map<String, int> workerReadings = {};

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final userId = data['userId'] ?? 'Unknown';
          workerReadings[userId] = (workerReadings[userId] ?? 0) + 1;
        }

        var sortedWorkers = workerReadings.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Column(
            children: sortedWorkers.take(5).map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(entry.key.substring(0, 1).toUpperCase(), style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worker ${entry.key.length > 8 ? entry.key.substring(0, 8) + '...' : entry.key}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          Text(
                            '${entry.value} readings submitted',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF2E5F8E)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 35, color: Color(0xFF4A90E2)),
                  ),
                  SizedBox(height: 12),
                  Text('CWC Administrator', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('admin@cwc.gov.in', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(leading: Icon(Icons.dashboard, color: Colors.white), title: Text('Dashboard', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.water_drop, color: Colors.white), title: Text('All Readings', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.people, color: Colors.white), title: Text('Field Workers', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.location_on, color: Colors.white), title: Text('Sites Management', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.bar_chart, color: Colors.white), title: Text('Analytics', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.settings, color: Colors.white), title: Text('Settings', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pop(context)),
            Divider(color: Colors.white.withOpacity(0.3)),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                context.pushNamed('auth_2_Login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notifications'),
        content: Text('No new notifications'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
      ),
    );
  }

  void _showAdminProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Admin Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 16),
            Text('Administrator', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('admin@cwc.gov.in'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
      ),
    );
  }

  void _showAllAlerts(List<Map<String, dynamic>> alerts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Active Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Divider(height: 24),
            Expanded(child: ListView.builder(itemCount: alerts.length, itemBuilder: (context, index) => Text(alerts[index]['site']))),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(height: 24),
            ListTile(leading: Icon(Icons.person_add), title: Text('Add Field Worker'), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.location_on), title: Text('Add New Site'), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.download), title: Text('Export Report'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
