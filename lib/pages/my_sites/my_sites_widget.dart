import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';

class MySitesWidget extends StatefulWidget {
  const MySitesWidget({Key? key}) : super(key: key);

  @override
  State<MySitesWidget> createState() => _MySitesWidgetState();
}

class _MySitesWidgetState extends State<MySitesWidget> {
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  // Dynamic sites that will be loaded from Firestore or hardcoded for demo
  final List<Map<String, dynamic>> _monitoringSites = [
    {
      'id': 'yamuna-delhi-12',
      'name': 'Yamuna-Delhi',
      'location': 'ITO Bridge, Delhi',
      'lat': 28.6139,
      'lng': 77.2090,
      'status': 'active',
      'dangerLevel': 205.5,
      'warningLevel': 204.5,
    },
    {
      'id': 'ganga-varanasi-8',
      'name': 'Ganga-Varanasi',
      'location': 'Malviya Bridge, Varanasi',
      'lat': 25.3176,
      'lng': 82.9739,
      'status': 'active',
      'dangerLevel': 71.26,
      'warningLevel': 70.26,
    },
    {
      'id': 'godavari-nashik-4',
      'name': 'Godavari-Nashik',
      'location': 'Gangapur Dam, Nashik',
      'lat': 19.9975,
      'lng': 73.7898,
      'status': 'active',
      'dangerLevel': 24.0,
      'warningLevel': 23.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          lat,
          lng,
        ) /
        1000; // Convert to kilometers
  }

  // FIXED: No orderBy, sort in memory!
  Future<String> _getLastReadingTime(String siteId) async {
    try {
      // Fetch WITHOUT orderBy (no index needed!)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('water_level_readings')
          .where('siteId', isEqualTo: siteId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 'No readings yet';
      }

      // Sort in memory
      final sortedDocs = querySnapshot.docs.toList()
        ..sort((a, b) {
          final aTime = ((a.data() as Map<String, dynamic>)['timestamp']
                  as Timestamp?)
              ?.toDate();
          final bTime = ((b.data() as Map<String, dynamic>)['timestamp']
                  as Timestamp?)
              ?.toDate();
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); // Newest first
        });

      final timestamp =
          (sortedDocs.first.data()['timestamp'] as Timestamp?)?.toDate();
      if (timestamp == null) return 'Unknown';

      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      print('Error fetching last reading: $e');
      return 'Unable to fetch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF0B84D0),
        automaticallyImplyLeading: true,
        title: Text(
          'My Assigned Sites',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Inter Tight',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoadingLocation = true;
              });
              _getCurrentLocation();
            },
            tooltip: 'Refresh Location',
          ),
        ],
        centerTitle: false,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _getCurrentLocation();
          setState(() {});
        },
        child: _isLoadingLocation
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF0B84D0)),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You are assigned to ${_monitoringSites.length} monitoring sites. Submit readings at least 4 times daily.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Sites List
                  ..._monitoringSites
                      .map((site) => _buildSiteCard(site))
                      .toList(),
                ],
              ),
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    final distance = _calculateDistance(site['lat'], site['lng']);
    String distanceText;

    if (distance == 0.0 && _currentPosition == null) {
      distanceText = 'Calculating...';
    } else if (distance < 1) {
      distanceText = '${(distance * 1000).toStringAsFixed(0)} m away';
    } else {
      distanceText = '${distance.toStringAsFixed(1)} km away';
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showSiteDetails(site);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF0B84D0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water,
                      color: Color(0xFF0B84D0),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          site['location'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Divider(height: 24),

              // Site Info with FutureBuilder for last reading
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on,
                      'Distance',
                      distanceText,
                      Color(0xFFFF9800),
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getLastReadingTime(site['id']),
                      builder: (context, snapshot) {
                        return _buildInfoItem(
                          Icons.access_time,
                          'Last Reading',
                          snapshot.data ?? 'Loading...',
                          Color(0xFF4CAF50),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to submission page with site data
                        context.pushNamed(
                          'notification_Create',
                          queryParameters: {
                            'siteId': site['id'],
                            'siteName': site['name'],
                          },
                        );
                      },
                      icon: Icon(Icons.camera_alt, size: 18),
                      label: Text('Submit Reading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B84D0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _openInMaps(site['lat'], site['lng'], site['name']);
                    },
                    icon: Icon(Icons.directions, size: 18),
                    label: Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF0B84D0),
                      side: BorderSide(color: Color(0xFF0B84D0)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSiteDetails(Map<String, dynamic> site) {
    showModalBottomSheet(
      context: context,
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
                Icon(Icons.water_drop, color: Color(0xFF0B84D0), size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        site['location'],
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 32),
            _buildDetailRow('Site ID', site['id']),
            _buildDetailRow('Danger Level', '${site['dangerLevel']} m'),
            _buildDetailRow('Warning Level', '${site['warningLevel']} m'),
            _buildDetailRow('Coordinates', '${site['lat']}, ${site['lng']}'),
            _buildDetailRow('Status', 'Active'),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pushNamed(
                        'notification_Create',
                        queryParameters: {
                          'siteId': site['id'],
                          'siteName': site['name'],
                        },
                      );
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('Submit Reading'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0B84D0),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps(double lat, double lng, String name) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $name in Maps...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
