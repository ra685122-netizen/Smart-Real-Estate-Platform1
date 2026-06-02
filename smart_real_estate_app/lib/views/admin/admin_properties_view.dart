import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/property_model.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';

class AdminPropertiesView extends StatefulWidget {
  const AdminPropertiesView({Key? key}) : super(key: key);

  @override
  State<AdminPropertiesView> createState() => _AdminPropertiesViewState();
}

class _AdminPropertiesViewState extends State<AdminPropertiesView>
    with SingleTickerProviderStateMixin {
  List<Property> _properties = [];
  late TabController _tabController;
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _loading = true);
    final props = await ApiService.getAdminProperties();
    if (mounted) setState(() { _properties = props; _loading = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Property> get _filteredProperties {
    var list = _properties.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.location ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    if (_tabController.index == 1) {
      list = list.where((p) => p.status == 'available').toList();
    } else if (_tabController.index == 2) {
      list = list.where((p) => p.status != 'available').toList();
    }
    return list;
  }

  void _showPropertyForm({Property? property}) {
    final loc = AppLocalizations.of(context);
    final isEditing = property != null;
    final titleCtrl = TextEditingController(text: property?.title ?? '');
    final descCtrl = TextEditingController(text: property?.description ?? '');
    final priceCtrl = TextEditingController(
        text: property != null ? property.price.toStringAsFixed(0) : '');
    final locationCtrl =
        TextEditingController(text: property?.location ?? '');
    final bedroomsCtrl = TextEditingController(
        text: property?.bedrooms?.toString() ?? '');
    final bathroomsCtrl = TextEditingController(
        text: property?.bathrooms?.toString() ?? '');
    final areaCtrl = TextEditingController(
        text: property?.area?.toStringAsFixed(0) ?? '');
    String selectedType = property?.propertyType ?? 'villa';
    String selectedStatus = property?.status ?? 'available';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isEditing ? loc.editProperty : loc.addProperty,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: loc.title,
                          prefixIcon: const Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: loc.description,
                          prefixIcon: const Icon(Icons.description_outlined),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '${loc.price} (${loc.sar})',
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: locationCtrl,
                        decoration: InputDecoration(
                          labelText: loc.location,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: loc.propertyType,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: AppConstants.propertyTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(loc.getPropertyType(type),
                                style: GoogleFonts.cairo()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: bedroomsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: loc.bedrooms,
                                prefixIcon:
                                    const Icon(Icons.bed_outlined, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: bathroomsCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: loc.bathrooms,
                                prefixIcon: const Icon(Icons.bathtub_outlined,
                                    size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: areaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '${loc.area} (${loc.sqm})',
                          prefixIcon:
                              const Icon(Icons.square_foot_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: loc.status,
                          prefixIcon: const Icon(Icons.toggle_on_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'available',
                            child:
                                Text(loc.active, style: GoogleFonts.cairo()),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text(loc.inactive,
                                style: GoogleFonts.cairo()),
                          ),
                          DropdownMenuItem(
                            value: 'sold',
                            child:
                                Text(loc.sold, style: GoogleFonts.cairo()),
                          ),
                          DropdownMenuItem(
                            value: 'rented',
                            child:
                                Text(loc.rented, style: GoogleFonts.cairo()),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedStatus = val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleCtrl.text.isEmpty ||
                              priceCtrl.text.isEmpty) return;
                          Navigator.pop(ctx);
                          if (isEditing) {
                            await ApiService.updatePropertyAdmin(property!.id, {
                              'title': titleCtrl.text,
                              'description': descCtrl.text,
                              'price': double.tryParse(priceCtrl.text) ?? 0,
                              'property_type': selectedType,
                              'location': locationCtrl.text,
                              'bedrooms': int.tryParse(bedroomsCtrl.text),
                              'bathrooms': int.tryParse(bathroomsCtrl.text),
                              'area': double.tryParse(areaCtrl.text),
                              'status': selectedStatus,
                            });
                          } else {
                            await ApiService.addProperty({
                              'owner_id': 1,
                              'title': titleCtrl.text,
                              'description': descCtrl.text,
                              'price': double.tryParse(priceCtrl.text) ?? 0,
                              'property_type': selectedType,
                              'location': locationCtrl.text,
                              'bedrooms': int.tryParse(bedroomsCtrl.text),
                              'bathrooms': int.tryParse(bathroomsCtrl.text),
                              'area': double.tryParse(areaCtrl.text),
                              'status': selectedStatus,
                            });
                          }
                          if (mounted) _loadProperties();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing
                                  ? loc.propertyUpdated
                                  : loc.propertyAdded),
                              backgroundColor: const Color(0xFF2ECC71),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            isEditing ? loc.save : loc.add,
                            style: GoogleFonts.cairo(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(Property property) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            loc.delete,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          content: Text(loc.confirmDelete, style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await ApiService.deleteProperty(property.id);
                if (ok && mounted) {
                  setState(() => _properties.removeWhere((p) => p.id == property.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.propertyDeleted),
                      backgroundColor: const Color(0xFFE74C3C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
  }

  void _togglePublish(Property property) async {
    final loc = AppLocalizations.of(context);
    final newStatus = property.status == 'available' ? 'inactive' : 'available';
    final ok = await ApiService.updatePropertyAdmin(property.id, {'status': newStatus});
    if (ok && mounted) {
      _loadProperties();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(property.status == 'available' ? loc.unpublish : loc.publish),
          backgroundColor: const Color(0xFF2E86AB),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredProperties;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.manageProperties,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProperties)],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w400),
          tabs: [
            Tab(text: loc.viewAll),
            Tab(text: loc.active),
            Tab(text: loc.inactive),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPropertyForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: loc.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home_work_outlined,
                            size: 64,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF7F8C8D)),
                        const SizedBox(height: 16),
                        Text(
                          loc.noResults,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final property = filtered[index];
                      return _buildPropertyCard(property);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = property.status == 'available';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: property.images.isNotEmpty
                    ? Image.network(
                        property.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey[200],
                          child: Icon(Icons.image,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey),
                        ),
                      )
                    : Container(
                        color: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey[200],
                        child: Icon(Icons.image,
                            color:
                                isDark ? Colors.white38 : Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.priceFormatted,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF2E86AB),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (property.location != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Color(0xFF7F8C8D)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            property.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF2ECC71)
                                  .withValues(alpha: 0.12)
                              : const Color(0xFFE74C3C)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isActive ? loc.active : loc.inactive,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (property.propertyType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E86AB)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            loc.getPropertyType(
                                property.propertyType!),
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E86AB),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  context.push('/property', extra: property);
                } else if (value == 'edit') {
                  _showPropertyForm(property: property);
                } else if (value == 'toggle') {
                  _togglePublish(property);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(property);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.view, style: GoogleFonts.cairo()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.edit, style: GoogleFonts.cairo()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive
                            ? Icons.unpublished_outlined
                            : Icons.publish_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? loc.unpublish : loc.publish,
                        style: GoogleFonts.cairo(),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          size: 20, color: Color(0xFFE74C3C)),
                      const SizedBox(width: 8),
                      Text(loc.delete,
                          style: GoogleFonts.cairo(
                              color: const Color(0xFFE74C3C))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
