import '/account_profile_creation/mail/mail_widget.dart';
import '/components/profile_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '/auth/firebase_auth/auth_util.dart';
import '../my_sites/my_sites_widget.dart';
import 'home1_copy_model.dart';
export 'home1_copy_model.dart';

class Home1CopyWidget extends StatefulWidget {
  const Home1CopyWidget({super.key});

  @override
  State<Home1CopyWidget> createState() => _Home1CopyWidgetState();
}

class _Home1CopyWidgetState extends State<Home1CopyWidget>
    with TickerProviderStateMixin {
  late Home1CopyModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _assignedSitesCount = 3;
  int _todayReadingsCompleted = 0;
  int _todayReadingsTotal = 12;
  int _pendingSyncCount = 0;
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Home1CopyModel());
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      print('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        drawer: _buildDrawer(),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B84D0),
          automaticallyImplyLeading: true,
          title: Text(
            'Water Level Sentinel',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter Tight',
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications coming soon!')),
                );
              },
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: RefreshIndicator(
            onRefresh: () async {
              await _getCurrentLocation();
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: _buildLocationStatusCard(),
                  ),
                  
                  // FIXED: Stats StreamBuilder - NO orderBy needed!
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('water_level_readings')
                        .where('userId', isEqualTo: currentUserUid)
                        .snapshots(),
                    builder: (context, statsSnapshot) {
                      int todayCount = 0;
                      int pendingCount = 0;
                      
                      if (statsSnapshot.hasData) {
                        final today = DateTime.now();
                        final todayStart = DateTime(today.year, today.month, today.day);
                        
                        for (var doc in statsSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                          final syncStatus = data['syncStatus'] ?? 'synced';
                          
                          if (timestamp != null && timestamp.isAfter(todayStart)) {
                            todayCount++;
                          }
                          
                          if (syncStatus == 'pending') {
                            pendingCount++;
                          }
                        }
                      }
                      
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.location_city,
                                    label: 'Sites Assigned',
                                    value: '$_assignedSitesCount',
                                    color: Color(0xFF0B84D0),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.check_circle,
                                    label: 'Today\'s Readings',
                                    value: '$todayCount/$_todayReadingsTotal',
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 12),
                          
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.sync, size: 36, color: Color(0xFFFF9800)),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pending Sync',
                                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                          ),
                                          Text(
                                            '$pendingCount readings',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF9800),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  SizedBox(height: 24),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Quick Actions',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily: 'Inter Tight',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.camera_alt,
                            label: 'New Reading',
                            color: Color(0xFF0B84D0),
                            onTap: () {
                              context.pushNamed('notification_Create');
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.list_alt,
                            label: 'My Sites',
                            color: Color(0xFF4CAF50),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MySitesWidget(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.bar_chart,
                            label: 'History',
                            color: Color(0xFFFF9800),
                            onTap: () {
                              context.pushNamed('ProblemStatus');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Submissions',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                            fontFamily: 'Inter Tight',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pushNamed('ProblemStatus');
                          },
                          child: Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildRecentReadingsList(),
                  ),
                  
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.pushNamed('notification_Create');
          },
          backgroundColor: Color(0xFF0B84D0),
          icon: Icon(Icons.add_photo_alternate, color: Colors.white),
          label: Text('New Reading', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
  
  Widget _buildDrawer() {
    return Drawer(
      elevation: 16.0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0B84D0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    'assets/images/Untitled_design-removebg-preview.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.water_drop, size: 50, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'CWC Monitoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('My Sites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MySitesWidget(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Reading History'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('ProblemStatus');
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed('Admin_Authcreate');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.pushNamed('auth_2_Login');
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _isLoadingLocation
          ? Colors.blue.shade50
          : (_currentPosition != null ? Colors.green.shade50 : Colors.orange.shade50),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isLoadingLocation
                  ? Icons.location_searching
                  : (_currentPosition != null ? Icons.check_circle : Icons.location_off),
              color: _isLoadingLocation
                  ? Colors.blue
                  : (_currentPosition != null ? Colors.green : Colors.orange),
              size: 40,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoadingLocation
                        ? 'Checking Location...'
                        : (_currentPosition != null ? '✓ GPS Active' : '⚠️ GPS Disabled'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _currentPosition != null
                        ? 'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m'
                        : 'Enable location for site validation',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            if (!_isLoadingLocation && _currentPosition == null)
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _getCurrentLocation,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // FIXED: Recent readings - NO orderBy, sort in memory!
  Widget _buildRecentReadingsList() {
    if (!loggedIn) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            child: Text('Please log in to see readings'),
          ),
        ),
      );
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('water_level_readings')
          .where('userId', isEqualTo: currentUserUid)
          .snapshots(), // ← NO orderBy, NO limit!
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.water_drop_outlined, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No readings yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  FFButtonWidget(
                    onPressed: () {
                      context.pushNamed('notification_Create');
                    },
                    text: 'Submit First Reading',
                    options: FFButtonOptions(
                      color: Color(0xFF0B84D0),
                      textStyle: TextStyle(color: Colors.white),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Sort in memory AFTER fetching (no index needed!)
        final sortedDocs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aTime = ((a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)?.toDate();
            final bTime = ((b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)?.toDate();
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // Descending (newest first)
          });
        
        // Take only first 5
        final displayDocs = sortedDocs.take(5).toList();
        
        return Column(
          children: displayDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final siteId = data['siteId'] ?? 'Unknown Site';
            
            double waterLevel = 0.0;
            if (data['waterLevel'] is num) {
              waterLevel = (data['waterLevel'] as num).toDouble();
            } else if (data['waterLevel'] is String) {
              waterLevel = double.tryParse(data['waterLevel']) ?? 0.0;
            }
            
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            final syncStatus = data['syncStatus'] ?? 'synced';
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: syncStatus == 'synced' ? Colors.green : Colors.orange,
                  child: Icon(
                    syncStatus == 'synced' ? Icons.check : Icons.sync,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  siteId,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  '${waterLevel.toStringAsFixed(2)}m | ${timestamp != null ? DateFormat('MMM dd, hh:mm a').format(timestamp) : 'Unknown'}',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Reading Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Site: $siteId'),
                          Text('Level: ${waterLevel.toStringAsFixed(2)}m'),
                          Text('Time: ${timestamp != null ? DateFormat('MMM dd, yyyy hh:mm a').format(timestamp) : 'Unknown'}'),
                          Text('Status: ${syncStatus.toUpperCase()}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
