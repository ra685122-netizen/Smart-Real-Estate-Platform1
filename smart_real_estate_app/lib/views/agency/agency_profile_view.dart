import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/property_model.dart';
import '../../models/review_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/property_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/rating_bar_widget.dart';
import '../../widgets/property_card.dart';

class AgencyProfileView extends StatefulWidget {
  final int agencyId;

  const AgencyProfileView({Key? key, required this.agencyId}) : super(key: key);

  @override
  State<AgencyProfileView> createState() => _AgencyProfileViewState();
}

class _AgencyProfileViewState extends State<AgencyProfileView> {
  User? _agency;
  List<Property> _properties = [];
  List<Review> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ApiService.getUser(widget.agencyId),
      ApiService.getProperties(),
      ApiService.getReviews(agencyId: widget.agencyId),
    ]);

    final apiUser = results[0] as User?;
    final apiProps = results[1] as List<Property>;
    final apiReviews = results[2] as List<Review>;

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final allProps = apiProps.isNotEmpty ? apiProps
        : (propertyProvider.allProperties.isNotEmpty ? propertyProvider.allProperties : propertyProvider.properties);

    if (mounted) {
      setState(() {
        _agency = apiUser ?? MockDataService.getUserById(widget.agencyId);
        _properties = allProps;
        _reviews = apiReviews.isNotEmpty ? apiReviews : MockDataService.getAgencyReviews(widget.agencyId);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final agency = _agency!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroHeader(context, agency),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context),
                  const SizedBox(height: 24),
                  const Text('عن الوكالة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    agency.bio ?? 'وكالة رائدة في مجال العقارات بخبرة تزيد عن 10 سنوات في السوق السعودي. نقدم خدمات متكاملة تشمل البيع، الشراء، والتأجير بأعلى معايير الجودة والاحترافية.',
                    style: TextStyle(color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('العقارات المدرجة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: Text(l10n.viewAll)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPropertiesList(_properties),
                  const SizedBox(height: 32),
                  const Text('التقييمات والآراء', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildReviewsList(_reviews),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildContactButton(context, agency),
    );
  }

  Widget _buildHeroHeader(BuildContext context, User agency) {
    final gradient = Provider.of<ThemeProvider>(context).currentScheme.gradient;
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=800&auto=format&fit=crop',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradient.first.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1560179707-f14e90ef3623?q=80&w=100&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              agency.name,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: Colors.blue, size: 20),
                          ],
                        ),
                        const RatingBarWidget(rating: 4.8, reviewCount: 124, size: 16),
                      ],
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

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem('عقار', '45'),
        _statItem('صفقة', '120+'),
        _statItem('تقييم', '4.8'),
        _statItem('سنة خبرة', '10'),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.55), fontSize: 12)),
      ],
    );
  }

  Widget _buildPropertiesList(List<Property> properties) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 240,
            child: PropertyCard(property: properties[index]),
          );
        },
      ),
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    return Column(
      children: reviews.map((review) => _reviewCard(review)).toList(),
    );
  }

  Widget _reviewCard(Review review) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A50) : const Color(0xFFE8EAF6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(review.userName![0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    RatingBarWidget(rating: review.rating.toDouble(), showCount: false, size: 14),
                  ],
                ),
              ),
              Text(
                '${review.createdAt?.day}/${review.createdAt?.month}/${review.createdAt?.year}',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment ?? '',
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context, User agency) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          label: Text(
            'تواصل مع الوكالة',
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.currentScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
