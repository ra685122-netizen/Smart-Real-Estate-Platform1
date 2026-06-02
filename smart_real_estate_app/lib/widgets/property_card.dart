import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showOwnerActions;

  const PropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.showOwnerActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 138,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox.expand(
                      child: property.images.isNotEmpty
                          ? Image.network(
                              property.images.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(theme),
                            )
                          : _buildPlaceholder(theme),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          property.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: property.isFavorite
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (property.propertyType != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          property.propertyTypeDisplay,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (property.virtualTourUrl != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.threesixty, color: Colors.white, size: 14),
                            const SizedBox(width: 3),
                            Text('360°',
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (property.location != null)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              property.location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property.priceFormatted,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        if (property.area != null && property.area! > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (property.bedrooms != null) ...[
                                Icon(Icons.bed_outlined,
                                    size: 12,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5)),
                                const SizedBox(width: 2),
                                Text(
                                  '${property.bedrooms}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Icon(Icons.square_foot,
                                  size: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5)),
                              const SizedBox(width: 2),
                              Text(
                                '${property.area!.toStringAsFixed(0)}م²',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(Icons.home_work_outlined,
            size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      ),
    );
  }
}
