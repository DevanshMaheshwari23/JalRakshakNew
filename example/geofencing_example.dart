import 'package:flutter/material.dart';
import 'package:jal_rakshak/services/geofencing_service.dart';
import 'package:jal_rakshak/flutter_flow/flutter_flow_util.dart';

/// Working example of GeofencingService usage
///
/// This example demonstrates how to use the GeofencingService with real coordinates
/// and shows different scenarios for testing.
class GeofencingExample extends StatefulWidget {
  const GeofencingExample({super.key});

  @override
  State<GeofencingExample> createState() => _GeofencingExampleState();
}

class _GeofencingExampleState extends State<GeofencingExample> {
  final GeofencingService _geofencingService = GeofencingService();

  String _statusMessage = 'Ready to test geofencing...';
  bool _isLoading = false;
  GeofencingService.GeofenceResult? _lastResult;

  // Test coordinates for real-world testing
  static const Map<String, Map<String, dynamic>> _testSites = {
    'delhi_site': {
      'name': 'Delhi Monitoring Site',
      'lat': 28.6139,
      'lng': 77.2090,
      'radius': 50.0,
    },
    'mumbai_site': {
      'name': 'Mumbai Monitoring Site',
      'lat': 19.0760,
      'lng': 72.8777,
      'radius': 50.0,
    },
    'bangalore_site': {
      'name': 'Bangalore Monitoring Site',
      'lat': 12.9716,
      'lng': 77.5946,
      'radius': 50.0,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofencing Service Example'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    if (_lastResult != null) ...[
                      const SizedBox(height: 8),
                      Text(
                          'Distance: ${_lastResult!.distance.toStringAsFixed(1)}m'),
                      Text('Valid: ${_lastResult!.isValid}'),
                      Text('Status: ${_lastResult!.status.displayName}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Test buttons
            Text(
              'Test Geofencing:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            // Test with Delhi coordinates
            _buildTestButton(
              'Test Delhi Site (28.6139, 77.2090)',
              () => _testSite('delhi_site'),
            ),

            // Test with Mumbai coordinates
            _buildTestButton(
              'Test Mumbai Site (19.0760, 72.8777)',
              () => _testSite('mumbai_site'),
            ),

            // Test with Bangalore coordinates
            _buildTestButton(
              'Test Bangalore Site (12.9716, 77.5946)',
              () => _testSite('bangalore_site'),
            ),

            const SizedBox(height: 20),

            // Direct coordinate testing
            Text(
              'Direct Coordinate Testing:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            _buildTestButton(
              'Test Custom Coordinates (28.6140, 77.2091)',
              () => _testCustomCoordinates(28.6140, 77.2091),
            ),

            _buildTestButton(
              'Test Far Coordinates (28.6200, 77.2200)',
              () => _testCustomCoordinates(28.6200, 77.2200),
            ),

            const SizedBox(height: 20),

            // Cache management
            Text(
              'Cache Management:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _clearCache,
                  child: const Text('Clear Cache'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _showCacheInfo,
                  child: const Text('Cache Info'),
                ),
              ],
            ),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          child: Text(text),
        ),
      ),
    );
  }

  Future<void> _testSite(String siteKey) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing ${_testSites[siteKey]!['name']}...';
    });

    try {
      final site = _testSites[siteKey]!;
      final lat = site['lat'] as double;
      final lng = site['lng'] as double;
      final radius = site['radius'] as double;

      // Test with validateUserLocation
      final isValid = await _geofencingService.validateUserLocation(
        lat,
        lng,
        radius: radius,
      );

      // Test with checkGeofenceStatus (simulated)
      final result = await _geofencingService.checkGeofenceStatus(
        siteKey,
        radius: radius,
      );

      setState(() {
        _lastResult = result;
        _statusMessage = isValid
            ? '✅ You are WITHIN the geofence area!'
            : '❌ You are OUTSIDE the geofence area!';
        _isLoading = false;
      });

      // Show detailed result
      _showResultDialog(result);
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testCustomCoordinates(double lat, double lng) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing coordinates ($lat, $lng)...';
    });

    try {
      final isValid = await _geofencingService.validateUserLocation(lat, lng);

      setState(() {
        _statusMessage = isValid
            ? '✅ Coordinates are within 50m radius!'
            : '❌ Coordinates are outside 50m radius!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _clearCache() {
    _geofencingService.clearCache();
    setState(() {
      _statusMessage = 'Cache cleared successfully!';
    });
  }

  void _showCacheInfo() {
    final cacheCount = _geofencingService.cachedSiteCount;
    setState(() {
      _statusMessage = 'Cached sites: $cacheCount';
    });
  }

  void _showResultDialog(GeofencingService.GeofenceResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geofence Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valid: ${result.isValid}'),
            Text('Distance: ${result.distance.toStringAsFixed(2)}m'),
            Text('Status: ${result.status.displayName}'),
            const SizedBox(height: 8),
            Text('Message: ${result.message}'),
            if (result.userLocation != null)
              Text('User Location: ${result.userLocation}'),
            if (result.siteLocation != null)
              Text('Site Location: ${result.siteLocation}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Example usage in a real app
class GeofencingUsageExample {
  final GeofencingService _geofencingService = GeofencingService();

  /// Example: Check if user can submit a reading
  Future<bool> canSubmitReading(String siteId) async {
    try {
      final result = await _geofencingService.checkGeofenceStatus(siteId);

      if (result.isValid) {
        print('✅ User is within geofence - reading submission allowed');
        return true;
      } else {
        print('❌ User is outside geofence - reading submission blocked');
        print('Distance: ${result.distance.toStringAsFixed(1)}m');
        print('Message: ${result.message}');
        return false;
      }
    } catch (e) {
      print('Error checking geofence: $e');
      return false;
    }
  }

  /// Example: Validate location before camera capture
  Future<bool> validateLocationForCamera(double siteLat, double siteLng) async {
    try {
      final isValid =
          await _geofencingService.validateUserLocation(siteLat, siteLng);

      if (isValid) {
        print('✅ Location validated - camera capture allowed');
        return true;
      } else {
        print('❌ Location not validated - camera capture blocked');
        return false;
      }
    } catch (e) {
      print('Error validating location: $e');
      return false;
    }
  }

  /// Example: Get detailed geofence status for UI
  Future<GeofencingService.GeofenceResult> getGeofenceStatus(
      String siteId) async {
    return await _geofencingService.checkGeofenceStatus(siteId);
  }
}

/// Test coordinates for manual testing
class TestCoordinates {
  // Real monitoring sites in India
  static const Map<String, LatLng> realSites = {
    'delhi_yamuna': LatLng(28.6139, 77.2090), // Delhi - Yamuna River
    'mumbai_ulhas': LatLng(19.0760, 72.8777), // Mumbai - Ulhas River
    'bangalore_cauvery': LatLng(12.9716, 77.5946), // Bangalore - Cauvery River
    'chennai_adyar': LatLng(13.0827, 80.2707), // Chennai - Adyar River
    'kolkata_hooghly': LatLng(22.5726, 88.3639), // Kolkata - Hooghly River
  };

  // Test coordinates for different scenarios
  static const Map<String, LatLng> testScenarios = {
    'within_50m': LatLng(28.6140, 77.2091), // ~15m from Delhi site
    'within_100m': LatLng(28.6145, 77.2095), // ~75m from Delhi site
    'outside_200m': LatLng(28.6200, 77.2200), // ~200m from Delhi site
    'far_away': LatLng(28.7000, 77.3000), // ~10km from Delhi site
  };
}

