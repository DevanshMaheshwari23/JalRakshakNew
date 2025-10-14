import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeofenceStatusWidget extends StatefulWidget {
  final double siteLatitude;
  final double siteLongitude;
  final Function(bool isValid, double distance) onStatusChanged;

  const GeofenceStatusWidget({
    super.key,
    required this.siteLatitude,
    required this.siteLongitude,
    required this.onStatusChanged,
  });

  @override
  State<GeofenceStatusWidget> createState() => _GeofenceStatusWidgetState();
}

class _GeofenceStatusWidgetState extends State<GeofenceStatusWidget> {
  bool _isValid = false;
  double _distance = 0.0;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled';
          _isLoading = false;
        });
        widget.onStatusChanged(false, -1);
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          widget.onStatusChanged(false, -1);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions permanently denied';
          _isLoading = false;
        });
        widget.onStatusChanged(false, -1);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate distance
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.siteLatitude,
        widget.siteLongitude,
      );

      bool isValid = distance <= 50.0;

      setState(() {
        _distance = distance;
        _isValid = isValid;
        _isLoading = false;
      });

      widget.onStatusChanged(isValid, distance);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
      widget.onStatusChanged(false, -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;

    if (_isLoading) {
      backgroundColor = Colors.orange.shade50;
      iconColor = Colors.orange;
      icon = Icons.location_searching;
      title = 'Checking Location...';
      subtitle = 'Please wait';
    } else if (_errorMessage.isNotEmpty) {
      backgroundColor = Colors.red.shade50;
      iconColor = Colors.red;
      icon = Icons.error;
      title = 'Location Error';
      subtitle = _errorMessage;
    } else if (_isValid) {
      backgroundColor = Colors.green.shade50;
      iconColor = Colors.green;
      icon = Icons.check_circle;
      title = 'Within Geofence';
      subtitle = '${_distance.toStringAsFixed(1)}m from site';
    } else {
      backgroundColor = Colors.red.shade50;
      iconColor = Colors.red;
      icon = Icons.warning;
      title = 'Outside Geofence';
      subtitle = '${_distance.toStringAsFixed(1)}m from site';
    }

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 32.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _checkLocation,
            icon: Icon(
              Icons.refresh,
              color: _isLoading ? Colors.grey : iconColor,
            ),
            tooltip: 'Refresh Location',
          ),
        ],
      ),
    );
  }
}
