import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class LocationPickerCard extends StatefulWidget {
  final String propertyType;
  final Function(String, LatLng) onLocationSelected;

  const LocationPickerCard({
    Key? key,
    required this.propertyType,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationPickerCard> createState() => _LocationPickerCardState();
}

class _LocationPickerCardState extends State<LocationPickerCard> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();

  double get _pinHue {
    switch (widget.propertyType) {
      case 'villa':
        return BitmapDescriptor.hueRed;
      case 'apartment':
        return BitmapDescriptor.hueBlue;
      case 'commercial':
        return BitmapDescriptor.hueGreen;
      case 'land':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  void _handleTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    // In a real app, use geocoding here to get address from LatLng
    final address = '📍 ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    _searchController.text = address;
    widget.onLocationSelected(address, location);
  }

  void _searchLocation() {
    final query = _searchController.text;
    if (query.isNotEmpty && _mapController != null) {
      // Mock search logic: Center map to a default or slightly offset
      FocusScope.of(context).unfocus();
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(
        const LatLng(24.7136, 46.6753), // Riyadh center mock
        12.0,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search mock: $query (Use tap to pick precise location)')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: loc.isArabic ? 'ابحث عن موقع...' : 'Search location...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    // Mock current location
                    _handleTap(const LatLng(24.7136, 46.6753));
                    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
                      const LatLng(24.7136, 46.6753),
                      14.0,
                    ));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(24.7136, 46.6753),
                  zoom: 10.0,
                ),
                onMapCreated: (controller) => _mapController = controller,
                onTap: _handleTap,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                markers: _selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _selectedLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(_pinHue),
                        ),
                      }
                    : {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
