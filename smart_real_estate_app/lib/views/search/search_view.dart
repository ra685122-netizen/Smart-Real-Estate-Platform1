import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/property_card.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  String? _selectedType;
  String? _selectedCity;
  RangeValues _priceRange = const RangeValues(0, 15000000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = context.read<PropertyProvider>();
      if (propertyProvider.allProperties.isEmpty) {
        propertyProvider.loadProperties();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.searchProperty),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                propertyProvider.searchProperties(value);
              },
              decoration: InputDecoration(
                hintText: l.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          propertyProvider.clearFilters();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_selectedType != null || _selectedCity != null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_selectedType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(l.getPropertyType(_selectedType!)),
                        onDeleted: () {
                          setState(() => _selectedType = null);
                          propertyProvider.filterByType(null);
                        },
                        deleteIconColor: primary,
                        backgroundColor: primary.withValues(alpha: 0.1),
                        side: BorderSide.none,
                      ),
                    ),
                  if (_selectedCity != null)
                    Chip(
                      label: Text(_selectedCity!),
                      onDeleted: () {
                        setState(() => _selectedCity = null);
                        propertyProvider.filterByLocation(null);
                      },
                      deleteIconColor: primary,
                      backgroundColor: primary.withValues(alpha: 0.1),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ),
          Expanded(
            child: propertyProvider.properties.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 80,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          l.noResults,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.tryDifferent,
                          style: GoogleFonts.cairo(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: propertyProvider.properties.length,
                    itemBuilder: (context, index) {
                      final property = propertyProvider.properties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PropertyCard(
                          property: property,
                          onTap: () =>
                              context.push('/property', extra: property),
                          onFavorite: () =>
                              propertyProvider.toggleFavorite(property,
                                userId: context.read<AuthProvider>().currentUser?.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l.filterResults,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedType = null;
                                _selectedCity = null;
                                _priceRange = const RangeValues(0, 15000000);
                              });
                            },
                            child: Text(l.reset),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(l.propertyType,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppConstants.propertyTypeLabels.entries
                            .map((entry) {
                          final isSelected = _selectedType == entry.key;
                          return ChoiceChip(
                            label: Text(l.getPropertyType(entry.key)),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                _selectedType = isSelected ? null : entry.key;
                              });
                            },
                            avatar: Icon(
                              AppConstants.propertyTypeIcons[entry.key],
                              size: 18,
                              color: isSelected ? Colors.white : primary,
                            ),
                            selectedColor: primary,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            ),
                            showCheckmark: false,
                            side: BorderSide(color: isSelected ? primary : Colors.grey.shade400),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(l.city,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: AppConstants.saudiCities.map((city) {
                          final isSelected = _selectedCity == city;
                          return ChoiceChip(
                            label: Text(city),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                _selectedCity = isSelected ? null : city;
                              });
                            },
                            selectedColor: primary,
                            backgroundColor: Colors.transparent,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            ),
                            showCheckmark: false,
                            side: BorderSide(color: isSelected ? primary : Colors.grey.shade400),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(l.priceRange,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 15000000,
                        divisions: 30,
                        activeColor: primary,
                        labels: RangeLabels(
                          '${(_priceRange.start / 1000).toStringAsFixed(0)}K',
                          '${(_priceRange.end / 1000000).toStringAsFixed(1)}M',
                        ),
                        onChanged: (values) {
                          setModalState(() => _priceRange = values);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(_priceRange.start / 1000).toStringAsFixed(0)}K SAR',
                            style: GoogleFonts.cairo(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            '${(_priceRange.end / 1000000).toStringAsFixed(1)}M SAR',
                            style: GoogleFonts.cairo(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            final provider = context.read<PropertyProvider>();
                            provider.filterByType(_selectedType);
                            provider.filterByLocation(_selectedCity);
                            provider.filterByPriceRange(
                                _priceRange.start, _priceRange.end);
                            Navigator.pop(context);
                          },
                          child: Text(l.applyFilter,
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
