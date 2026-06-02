import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/location_picker_card.dart';

class AddPropertyView extends StatefulWidget {
  final Property? property;

  const AddPropertyView({Key? key, this.property}) : super(key: key);

  @override
  State<AddPropertyView> createState() => _AddPropertyViewState();
}

class _AddPropertyViewState extends State<AddPropertyView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _propertyType = 'apartment';
  int _currentStep = 0;
  final List<String> _imageUrls = [];

  bool get isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final p = widget.property!;
      _titleController.text = p.title;
      _descriptionController.text = p.description;
      _priceController.text = p.price.toString();
      _locationController.text = p.location ?? '';
      _areaController.text = p.area?.toString() ?? '';
      _bedroomsController.text = p.bedrooms?.toString() ?? '';
      _bathroomsController.text = p.bathrooms?.toString() ?? '';
      _propertyType = p.propertyType ?? 'apartment';
      _imageUrls.addAll(p.images);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final required = l.isArabic ? 'مطلوب' : 'Required';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l.editProperty : l.addProperty),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submitProperty();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep == 2
                          ? (isEditing
                              ? l.save
                              : l.publish)
                          : l.next),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: Text(l.isArabic ? 'السابق' : 'Previous'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(l.isArabic ? 'المعلومات الأساسية' : 'Basic Info'),
              subtitle: Text(l.isArabic ? 'العنوان والوصف والنوع' : 'Title, description & type'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l.title,
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (v) => v == null || v.isEmpty ? required : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l.description,
                      prefixIcon: const Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v == null || v.isEmpty ? required : null,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: l.isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(l.propertyType,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.propertyTypeLabels.entries.map((e) {
                      final isSelected = _propertyType == e.key;
                      return ChoiceChip(
                        label: Text(l.getPropertyType(e.key)),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _propertyType = e.key),
                        avatar: Icon(
                          AppConstants.propertyTypeIcons[e.key],
                          size: 18,
                          color: isSelected ? Colors.white : primary,
                        ),
                        selectedColor: primary,
                        labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Step(
              title: Text(l.isArabic ? 'التفاصيل' : 'Details'),
              subtitle: Text(l.isArabic ? 'السعر والمساحة والموقع' : 'Price, area & location'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${l.price} (${l.sar})',
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    validator: (v) => v == null || v.isEmpty ? required : null,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  Align(
                    alignment: l.isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(l.location,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  LocationPickerCard(
                    propertyType: _propertyType,
                    onLocationSelected: (address, latLng) {
                      _locationController.text = address;
                    },
                  ),
                  // Hidden location text field to keep the form logic intact
                  Offstage(
                    child: TextFormField(
                      controller: _locationController,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _areaController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '${l.area} (${l.sqm})',
                            prefixIcon: const Icon(Icons.square_foot),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _bedroomsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l.bedrooms,
                            prefixIcon: const Icon(Icons.bed),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bathroomsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l.bathrooms,
                      prefixIcon: const Icon(Icons.bathtub_outlined),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: Text(l.isArabic ? 'الصور' : 'Images'),
              subtitle: Text(l.isArabic ? 'أضف صور العقار' : 'Add property images'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            labelText: l.isArabic ? 'رابط الصورة' : 'Image URL',
                            hintText: 'https://...',
                            prefixIcon: const Icon(Icons.link),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          if (_imageUrlController.text.isNotEmpty) {
                            setState(() {
                              _imageUrls.add(_imageUrlController.text);
                              _imageUrlController.clear();
                            });
                          }
                        },
                        icon: Icon(Icons.add_circle,
                            color: primary, size: 36),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_imageUrls.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(_imageUrls[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _imageUrls.removeAt(index));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE74C3C),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: theme.dividerColor),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text(
                              l.isArabic ? 'أضف صور العقار' : 'Add property images',
                              style: GoogleFonts.cairo(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _submitting = false;

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_submitting) return;
    setState(() => _submitting = true);

    final l = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final provider = context.read<PropertyProvider>();
    final ownerId = auth.currentUser?.id ?? 1;

    final data = {
      'owner_id':     ownerId,
      'title':        _titleController.text.trim(),
      'description':  _descriptionController.text.trim(),
      'price':        double.tryParse(_priceController.text) ?? 0,
      'property_type': _propertyType,
      'listing_type': 'sale',
      'location':     _locationController.text.trim(),
      'bedrooms':     int.tryParse(_bedroomsController.text) ?? 0,
      'bathrooms':    int.tryParse(_bathroomsController.text) ?? 0,
      'area':         double.tryParse(_areaController.text),
      if (_imageUrls.isNotEmpty) 'virtual_tour_url': _imageUrls.first,
    };

    bool success;
    if (isEditing) {
      success = await provider.updatePropertyApi(widget.property!.id, data, ownerId: ownerId);
    } else {
      success = await provider.addPropertyApi(data);
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? l.propertyUpdated : l.propertyAdded),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.isArabic ? 'فشل حفظ العقار، تحقق من الاتصال' : 'Failed to save property'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
