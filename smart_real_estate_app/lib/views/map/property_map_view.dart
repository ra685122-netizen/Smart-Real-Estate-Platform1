import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/riyal_icon.dart';
import '../../widgets/property_card.dart';

class PropertyMapView extends StatefulWidget {
  const PropertyMapView({Key? key}) : super(key: key);

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer();
  List<Property> _properties = [];
  bool _isLoading = true;
  bool _isListView = false;
  String _selectedFilter = 'All';
  Property? _selectedProperty;
  Set<Marker> _markers = {};
  String _searchQuery = '';
  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;
  bool _showMapTypePanel = false;
  bool _myLocationEnabled = false;
  bool _buildingsEnabled = true;
  late AnimationController _panelAnimController;
  late Animation<double> _panelAnimation;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(24.7136, 46.6753),
    zoom: 6.0,
    tilt: 0,
    bearing: 0,
  );

  final Map<int, LatLng> _propertyCoords = {
    1: const LatLng(24.8003, 46.6404),
    2: const LatLng(21.4858, 39.1925),
    3: const LatLng(26.4207, 50.0888),
    4: const LatLng(24.8521, 46.6380),
    5: const LatLng(21.5547, 39.1419),
    6: const LatLng(24.8321, 46.6102),
    7: const LatLng(24.6877, 46.7219),
    8: const LatLng(21.3891, 39.8579),
  };

  @override
  void initState() {
    super.initState();
    _panelAnimController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _panelAnimation = CurvedAnimation(
      parent: _panelAnimController,
      curve: Curves.easeInOut,
    );
    _loadProperties();
  }

  @override
  void dispose() {
    _panelAnimController.dispose();
    super.dispose();
  }

  void _loadProperties() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    _properties = propertyProvider.allProperties.isNotEmpty
        ? propertyProvider.allProperties
        : propertyProvider.properties;
    setState(() => _isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
  }

  void _buildMarkers() {
    final primary =
        Provider.of<ThemeProvider>(context, listen: false).currentScheme.primary;
    final markers = <Marker>{};
    for (final p in _filtered) {
      final coords = _propertyCoords[p.id] ??
          LatLng(24.0 + (p.id * 0.3 % 4), 45.0 + (p.id * 0.5 % 7));
      markers.add(
        Marker(
          markerId: MarkerId(p.id.toString()),
          position: coords,
          infoWindow: InfoWindow(
            title: p.title,
            snippet: p.priceFormatted,
            onTap: () => context.push('/property', extra: p),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _hueFromColor(primary),
          ),
          onTap: () {
            setState(() => _selectedProperty = p);
          },
        ),
      );
    }
    setState(() => _markers = markers);
  }

  double _hueFromColor(Color c) {
    final hsv = HSVColor.fromColor(c);
    return hsv.hue;
  }

  List<Property> get _filtered {
    var result = _selectedFilter == 'All'
        ? _properties
        : _properties
            .where((p) =>
                p.propertyType?.toLowerCase() ==
                _selectedFilter.toLowerCase())
            .toList();
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              (p.location ?? '').toLowerCase().contains(query) ||
              (p.propertyType ?? '').toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  Future<void> _openStreetView(LatLng coords) async {
    final url = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${coords.latitude},${coords.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    }
  }

  Future<void> _openInGoogleMaps(LatLng coords, String label) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coords.latitude},${coords.longitude}&query_place_name=${Uri.encodeComponent(label)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _animateToSaudi() async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(24.7136, 46.6753),
          zoom: 6.0,
          tilt: 0,
          bearing: 0,
        ),
      ),
    );
  }

  Future<void> _enable3DView() async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(24.7136, 46.6753),
          zoom: 14.0,
          tilt: 60,
          bearing: 45,
        ),
      ),
    );
  }

  void _toggleMapTypePanel() {
    setState(() => _showMapTypePanel = !_showMapTypePanel);
    if (_showMapTypePanel) {
      _panelAnimController.forward();
    } else {
      _panelAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primary = themeProvider.currentScheme.primary;

    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isListView
                  ? _buildListView()
                  : _buildGoogleMap(),
          SafeArea(
            child: Column(
              children: [
                _buildFloatingSearchBar(l10n),
                _buildFilterChips(l10n, primary),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.pop(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Colors.black87),
                ),
              ),
            ),
          ),
          if (!_isListView) _buildMapControls(primary),
          if (_selectedProperty != null && !_isListView)
            Positioned(
              bottom: 100,
              left: 16,
              right: 80,
              child: _buildPropertyCard(_selectedProperty!, l10n, primary),
            ),
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'toggleView',
              onPressed: () => setState(() {
                _isListView = !_isListView;
                _selectedProperty = null;
                _showMapTypePanel = false;
              }),
              backgroundColor: primary,
              icon: Icon(_isListView ? Icons.map : Icons.list,
                  color: Colors.white),
              label: Text(
                _isListView ? l10n.mapView : l10n.listView,
                style: GoogleFonts.cairo(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      markers: _markers,
      mapType: _currentMapType,
      trafficEnabled: _trafficEnabled,
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: false,
      buildingsEnabled: _buildingsEnabled,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      indoorViewEnabled: true,
      onMapCreated: (controller) {
        if (!_mapController.isCompleted) _mapController.complete(controller);
      },
      onTap: (_) => setState(() {
        _selectedProperty = null;
        if (_showMapTypePanel) _toggleMapTypePanel();
      }),
    );
  }

  Widget _buildMapControls(Color primary) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _mapControlBtn(
            icon: Icons.add,
            tooltip: 'تكبير',
            onTap: () async {
              final c = await _mapController.future;
              c.animateCamera(CameraUpdate.zoomIn());
            },
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.remove,
            tooltip: 'تصغير',
            onTap: () async {
              final c = await _mapController.future;
              c.animateCamera(CameraUpdate.zoomOut());
            },
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.my_location,
            tooltip: 'موقعي',
            onTap: () => setState(() => _myLocationEnabled = !_myLocationEnabled),
            isActive: _myLocationEnabled,
            activeColor: primary,
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.traffic,
            tooltip: 'حركة المرور',
            onTap: () => setState(() => _trafficEnabled = !_trafficEnabled),
            isActive: _trafficEnabled,
            activeColor: Colors.orange,
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.view_in_ar,
            tooltip: 'عرض ثلاثي الأبعاد',
            onTap: _enable3DView,
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.home_filled,
            tooltip: 'العودة للسعودية',
            onTap: _animateToSaudi,
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.layers,
            tooltip: 'نوع الخريطة',
            onTap: _toggleMapTypePanel,
            isActive: _showMapTypePanel,
            activeColor: primary,
          ),
          if (_showMapTypePanel) ...[
            const SizedBox(height: 8),
            SizeTransition(
              sizeFactor: _panelAnimation,
              axisAlignment: -1,
              child: _buildMapTypePanel(primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mapControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = Colors.blue,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? activeColor : Colors.white,
        borderRadius: BorderRadius.circular(10),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapTypePanel(Color primary) {
    final types = [
      _MapTypeOption(
        type: MapType.normal,
        icon: Icons.map_outlined,
        label: 'عادي',
      ),
      _MapTypeOption(
        type: MapType.satellite,
        icon: Icons.satellite_alt,
        label: 'قمر صناعي',
      ),
      _MapTypeOption(
        type: MapType.hybrid,
        icon: Icons.layers,
        label: 'هجين',
      ),
      _MapTypeOption(
        type: MapType.terrain,
        icon: Icons.terrain,
        label: 'تضاريس',
      ),
    ];

    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: types.map((opt) {
          final isSelected = _currentMapType == opt.type;
          return InkWell(
            onTap: () {
              setState(() => _currentMapType = opt.type);
              _toggleMapTypePanel();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(opt.icon,
                      size: 18,
                      color: isSelected ? primary : Colors.black54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      opt.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? primary : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 14, color: primary),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPropertyCard(
      Property p, AppLocalizations l10n, Color primary) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      p.images[0],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.home, color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RiyalIcon(size: 13, color: primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              p.priceFormatted,
                              style: GoogleFonts.cairo(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              p.location ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                  color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push('/property', extra: p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      l10n.viewDetails,
                      style: GoogleFonts.cairo(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                  onPressed: () {
                    final coords = _propertyCoords[p.id] ??
                        LatLng(24.0 + (p.id * 0.3 % 4),
                            45.0 + (p.id * 0.5 % 7));
                    _openStreetView(coords);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    side: BorderSide(color: Colors.blue.shade400),
                  ),
                  icon: Icon(Icons.streetview,
                      size: 13, color: Colors.blue.shade600),
                  label: Text(
                    'Street View',
                    style: GoogleFonts.cairo(
                        color: Colors.blue.shade600, fontSize: 11),
                  ),
                ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                  onPressed: () {
                    final coords = _propertyCoords[p.id] ??
                        LatLng(24.0 + (p.id * 0.3 % 4),
                            45.0 + (p.id * 0.5 % 7));
                    _openInGoogleMaps(coords, p.title);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    side: BorderSide(color: Colors.green.shade400),
                  ),
                  icon: Icon(Icons.map,
                      size: 13, color: Colors.green.shade600),
                  label: Text(
                    'Maps',
                    style: GoogleFonts.cairo(
                        color: Colors.green.shade600, fontSize: 11),
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

  Widget _buildFloatingSearchBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: TextField(
        style: GoogleFonts.cairo(),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _selectedProperty = null;
          });
          _buildMarkers();
        },
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedProperty = null;
                    });
                    _buildMarkers();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n, Color primary) {
    final filters = [
      'All',
      'Villa',
      'Apartment',
      'Land',
      'Commercial',
      'Office'
    ];
    final labels = {
      'All': l10n.allProperties,
      'Villa': l10n.villa,
      'Apartment': l10n.apartment,
      'Land': l10n.land,
      'Commercial': l10n.commercial,
      'Office': l10n.office,
    };

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                labels[filter] ?? filter,
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : primary,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                    _selectedProperty = null;
                  });
                  _buildMarkers();
                }
              },
              selectedColor: primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    final filtered = _filtered;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(
            top: 140, bottom: 100, left: 16, right: 16),
        itemCount: filtered.length,
        itemBuilder: (context, index) =>
            PropertyCard(property: filtered[index]),
      ),
    );
  }
}

class _MapTypeOption {
  final MapType type;
  final IconData icon;
  final String label;
  const _MapTypeOption({
    required this.type,
    required this.icon,
    required this.label,
  });
}

