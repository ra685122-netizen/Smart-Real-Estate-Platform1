import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<PropertyProvider>().loadFavorites(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final auth = context.read<AuthProvider>();
    final favorites = propertyProvider.favoriteProperties;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.favorites),
        actions: [
          if (favorites.isNotEmpty)
            TextButton(
              onPressed: () {
                final userId = auth.currentUser?.id;
                for (var p in List.from(favorites)) {
                  propertyProvider.toggleFavorite(p, userId: userId);
                }
              },
              child: Text(l.reset),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 80,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    l.noFavorites,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.addFavorites,
                    style: GoogleFonts.cairo(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final property = favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(
                    property: property,
                    onTap: () => context.push('/property', extra: property),
                    onFavorite: () => propertyProvider.toggleFavorite(
                      property,
                      userId: auth.currentUser?.id,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
