import 'package:flutter/material.dart';
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

class OwnerProfileView extends StatefulWidget {
  final int ownerId;

  const OwnerProfileView({Key? key, required this.ownerId}) : super(key: key);

  @override
  State<OwnerProfileView> createState() => _OwnerProfileViewState();
}

class _OwnerProfileViewState extends State<OwnerProfileView> {
  User? _owner;
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
      ApiService.getUser(widget.ownerId),
      ApiService.getProperties(),
      ApiService.getReviews(propertyId: null),
    ]);

    final apiUser = results[0] as User?;
    final apiProps = results[1] as List<Property>;
    final apiReviews = results[2] as List<Review>;

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final allProps = apiProps.isNotEmpty ? apiProps
        : (propertyProvider.allProperties.isNotEmpty ? propertyProvider.allProperties : propertyProvider.properties);

    if (mounted) {
      setState(() {
        _owner = apiUser ?? MockDataService.getUserById(widget.ownerId);
        _properties = allProps.where((p) => p.ownerId == widget.ownerId).toList();
        _reviews = apiReviews.isNotEmpty ? apiReviews : MockDataService.getOwnerReviews(widget.ownerId);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ownerInfo)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final owner = _owner!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ownerInfo),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: themeProvider.currentScheme.gradient),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileHeader(owner),
            const SizedBox(height: 32),
            _buildMetricsGrid(context),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.myProperties, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPropertiesGrid(_properties),
                  const SizedBox(height: 32),
                  Text(l10n.reviews, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildReviewsList(_reviews),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildContactButton(context, owner),
    );
  }

  Widget _buildProfileHeader(User owner) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: const CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop'),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(owner.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('عضو منذ 2022', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 12),
        const RatingBarWidget(rating: 4.9, reviewCount: 15, size: 18),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _metricItem('الموثوقية', '98%', Icons.verified_user_outlined, Colors.green),
          _metricItem('الاستجابة', '100%', Icons.bolt_outlined, Colors.orange),
          _metricItem('وقت الرد', '< 1 ساعة', Icons.access_time, Colors.blue),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPropertiesGrid(List<Property> properties) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return PropertyCard(property: properties[index]);
      },
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.userName ?? 'مستخدم', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    RatingBarWidget(rating: review.rating.toDouble(), showCount: false, size: 14),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.comment ?? '', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactButton(BuildContext context, User owner) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: Text(l10n.contactOwner, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.currentScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: themeProvider.currentScheme.primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.phone_outlined, color: themeProvider.currentScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
