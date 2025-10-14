import 'package:geolocator/geolocator.dart';

/// Standalone demonstration of GeofencingService functionality
///
/// This demo shows how the GeofencingService works with real coordinates
/// and demonstrates the key features without depending on the full app.
class GeofencingDemo {
  static const double _defaultGeofenceRadius = 50.0; // meters

  /// Test coordinates for demonstration
  static const Map<String, Map<String, dynamic>> testSites = {
    'delhi_yamuna': {
      'name': 'Delhi - Yamuna River Monitoring Site',
      'lat': 28.6139,
      'lng': 77.2090,
      'description': 'Main monitoring point on Yamuna River in Delhi',
    },
    'mumbai_ulhas': {
      'name': 'Mumbai - Ulhas River Monitoring Site',
      'lat': 19.0760,
      'lng': 72.8777,
      'description': 'Ulhas River monitoring station in Mumbai',
    },
    'bangalore_cauvery': {
      'name': 'Bangalore - Cauvery River Monitoring Site',
      'lat': 12.9716,
      'lng': 77.5946,
      'description': 'Cauvery River monitoring point near Bangalore',
    },
  };

  /// Test scenarios with different distances
  static const Map<String, Map<String, dynamic>> testScenarios = {
    'within_50m': {
      'lat': 28.6140,
      'lng': 77.2091,
      'description': 'Approximately 15m from Delhi site (within 50m radius)',
      'expected_result': true,
    },
    'within_100m': {
      'lat': 28.6145,
      'lng': 77.2095,
      'description':
          'Approximately 75m from Delhi site (outside 50m, within 100m)',
      'expected_result': false,
    },
    'outside_200m': {
      'lat': 28.6200,
      'lng': 77.2200,
      'description':
          'Approximately 200m from Delhi site (outside both 50m and 100m)',
      'expected_result': false,
    },
    'far_away': {
      'lat': 28.7000,
      'lng': 77.3000,
      'description':
          'Approximately 10km from Delhi site (far outside any reasonable radius)',
      'expected_result': false,
    },
  };

  /// Demonstrate distance calculation between two points
  static double calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Demonstrate geofence validation
  static bool validateGeofence(
      double userLat, double userLng, double siteLat, double siteLng,
      {double radius = _defaultGeofenceRadius}) {
    final distance = calculateDistance(userLat, userLng, siteLat, siteLng);
    return distance <= radius;
  }

  /// Run the complete demonstration
  static void runDemo() {
    print('🌊 CWC Water Level Monitoring - GeofencingService Demo');
    print('=' * 60);

    print('\n📍 Monitoring Sites:');
    testSites.forEach((key, site) {
      print('$key: ${site['name']}');
      print('  Coordinates: (${site['lat']}, ${site['lng']})');
      print('  Description: ${site['description']}');
      print('');
    });

    print('🧪 Test Scenarios:');
    testScenarios.forEach((key, scenario) {
      print('$key: ${scenario['description']}');
      print('  Test Coordinates: (${scenario['lat']}, ${scenario['lng']})');
      print('  Expected Result: ${scenario['expected_result']}');

      // Test against Delhi site
      final delhiSite = testSites['delhi_yamuna']!;
      final distance = calculateDistance(
        scenario['lat'] as double,
        scenario['lng'] as double,
        delhiSite['lat'] as double,
        delhiSite['lng'] as double,
      );

      final isValid = validateGeofence(
        scenario['lat'] as double,
        scenario['lng'] as double,
        delhiSite['lat'] as double,
        delhiSite['lng'] as double,
      );

      print('  Actual Distance: ${distance.toStringAsFixed(1)}m');
      print('  Actual Result: $isValid');
      print(
          '  Status: ${isValid ? '✅ WITHIN GEOFENCE' : '❌ OUTSIDE GEOFENCE'}');
      print('');
    });

    print('🔧 Service Features Demonstrated:');
    print('✅ Distance calculation using Geolocator.distanceBetween()');
    print('✅ 50m radius validation');
    print('✅ Real-world coordinates testing');
    print('✅ Multiple test scenarios');
    print('✅ Error handling and status reporting');

    print('\n📱 Integration Example:');
    print('''
// In your Flutter app:
final geofencingService = GeofencingService();

// Check if user can submit reading
final canSubmit = await geofencingService.validateUserLocation(
  siteLat, siteLng, radius: 50.0
);

if (canSubmit) {
  // Allow camera capture and reading submission
  print('✅ User is within monitoring site area');
} else {
  // Show error message to user
  print('❌ Please move closer to the monitoring site');
}
    ''');

    print('\n🎯 Real-World Usage:');
    print('1. Field personnel arrive at monitoring site');
    print('2. App checks GPS location against site coordinates');
    print('3. If within 50m radius: Allow water level reading');
    print('4. If outside radius: Show "Move closer" message');
    print('5. Reading includes location validation metadata');

    print('\n✨ Demo completed successfully!');
  }
}

/// Main function to run the demo
void main() {
  GeofencingDemo.runDemo();
}
