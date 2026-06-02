import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/property_provider.dart';
import '../providers/theme_provider.dart';

class MapPreviewCard extends StatefulWidget {
  const MapPreviewCard({Key? key}) : super(key: key);

  @override
  State<MapPreviewCard> createState() => _MapPreviewCardState();
}

class _MapPreviewCardState extends State<MapPreviewCard> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    final markers = propertyProvider.allProperties.map((p) {
      // Create mock coordinates based on id for demo purposes since we don't have lat/lng in property
      double lat = 24.7136 + (p.id * 0.01);
      double lng = 46.6753 + (p.id * 0.01);
      
      double hue;
      switch (p.propertyType) {
        case 'villa':
          hue = BitmapDescriptor.hueRed;
          break;
        case 'apartment':
          hue = BitmapDescriptor.hueBlue;
          break;
        case 'commercial':
          hue = BitmapDescriptor.hueGreen;
          break;
        case 'land':
          hue = BitmapDescriptor.hueOrange;
          break;
        default:
          hue = BitmapDescriptor.hueAzure;
      }

      return Marker(
        markerId: MarkerId(p.id.toString()),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(title: p.title, snippet: '${p.price} ${loc.sarUnit}'),
        onTap: () {
          context.push('/property', extra: p);
        },
      );
    }).toSet();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 220,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(24.7136, 46.6753), // Riyadh
              zoom: 11.0,
            ),
            markers: markers,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (_) => context.push('/map'),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map_outlined, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    loc.isArabic ? 'تصفح الخريطة' : 'Explore Map',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/map'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
