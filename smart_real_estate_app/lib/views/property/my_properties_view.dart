import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';

class MyPropertiesView extends StatefulWidget {
  const MyPropertiesView({Key? key}) : super(key: key);

  @override
  State<MyPropertiesView> createState() => _MyPropertiesViewState();
}

class _MyPropertiesViewState extends State<MyPropertiesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context
          .read<PropertyProvider>()
          .loadMyProperties(auth.currentUser?.id ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final myProps = propertyProvider.myProperties;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.myProperties)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-property'),
        icon: const Icon(Icons.add),
        label: Text(l.addProperty),
      ),
      body: myProps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    l.isArabic ? 'لا توجد عقارات مضافة' : 'No properties added',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.isArabic ? 'أضف عقارك الأول الآن' : 'Add your first property now',
                    style: GoogleFonts.cairo(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-property'),
                    icon: const Icon(Icons.add),
                    label: Text(l.addProperty),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myProps.length,
              itemBuilder: (context, index) {
                final property = myProps[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Dismissible(
                    key: Key('prop_${property.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete,
                          color: Colors.white, size: 32),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l.isArabic ? 'حذف العقار' : 'Delete Property'),
                          content: Text(l.confirmDelete),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE74C3C)),
                              child: Text(l.delete),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      final auth = context.read<AuthProvider>();
                      propertyProvider.deletePropertyApi(
                        property.id,
                        ownerId: auth.currentUser?.id,
                      );
                    },
                    child: PropertyCard(
                      property: property,
                      onTap: () =>
                          context.push('/property', extra: property),
                      showOwnerActions: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
