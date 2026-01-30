import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/geofencing_service.dart';

/// GeofenceValidatorWidget - Shows geofence validation status
///
/// Displays a red/green status indicator for geofence validation
/// with distance information and status message.
class GeofenceValidatorWidget extends StatefulWidget {
  const GeofenceValidatorWidget({
    super.key,
    required this.siteId,
    this.onStatusChanged,
  });

  final String siteId;
  final void Function(GeofenceResult)? onStatusChanged;

  @override
  State<GeofenceValidatorWidget> createState() =>
      _GeofenceValidatorWidgetState();
}

class _GeofenceValidatorWidgetState extends State<GeofenceValidatorWidget> {
  final GeofencingService _geofencingService = GeofencingService();
  GeofenceResult? _currentResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkGeofenceStatus();
  }

  Future<void> _checkGeofenceStatus() async {
    setState(() => _isLoading = true);

    try {
      final result =
          await _geofencingService.checkGeofenceStatus(widget.siteId);
      setState(() {
        _currentResult = result;
        _isLoading = false;
      });

      widget.onStatusChanged?.call(result);
    } catch (e) {
      setState(() {
        _currentResult = GeofenceResult(
          isValid: false,
          distance: 0.0,
          message: 'Error checking geofence: $e',
          status: GeofenceStatus.locationError,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getBorderColor(),
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: _getIconColor(),
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  _getStatusText(),
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'Inter Tight',
                        color: _getTextColor(),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
            ],
          ),
          if (_currentResult != null && !_isLoading) ...[
            const SizedBox(height: 8.0),
            Text(
              _currentResult!.message,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: _getTextColor(),
                    letterSpacing: 0.0,
                  ),
            ),
            if (_currentResult!.distance > 0) ...[
              const SizedBox(height: 4.0),
              Text(
                'Distance: ${_currentResult!.distance.toStringAsFixed(1)}m',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Inter',
                      color: _getTextColor().withOpacity(0.8),
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_isLoading) return FlutterFlowTheme.of(context).secondaryBackground;
    if (_currentResult?.isValid == true) return Colors.green.withOpacity(0.1);
    return Colors.red.withOpacity(0.1);
  }

  Color _getBorderColor() {
    if (_isLoading) return FlutterFlowTheme.of(context).alternate;
    if (_currentResult?.isValid == true) return Colors.green;
    return Colors.red;
  }

  Color _getIconColor() {
    if (_isLoading) return FlutterFlowTheme.of(context).secondaryText;
    if (_currentResult?.isValid == true) return Colors.green;
    return Colors.red;
  }

  Color _getTextColor() {
    if (_isLoading) return FlutterFlowTheme.of(context).secondaryText;
    if (_currentResult?.isValid == true) return Colors.green.shade700;
    return Colors.red.shade700;
  }

  IconData _getStatusIcon() {
    if (_isLoading) return Icons.location_searching;
    if (_currentResult?.isValid == true) return Icons.check_circle;
    return Icons.cancel;
  }

  String _getStatusText() {
    if (_isLoading) return 'Checking location...';
    if (_currentResult?.isValid == true) return 'Location Validated';
    return 'Location Not Validated';
  }
}

