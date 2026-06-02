import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/review_model.dart';
import '../../services/api_service.dart';

class AdminReviewsView extends StatefulWidget {
  const AdminReviewsView({Key? key}) : super(key: key);

  @override
  State<AdminReviewsView> createState() => _AdminReviewsViewState();
}

class _AdminReviewsViewState extends State<AdminReviewsView> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final allReviews = await ApiService.getReviews();
    if (mounted) setState(() { _reviews = allReviews; _isLoading = false; });
  }

  List<Review> get _filteredReviews {
    return _reviews.where((review) {
      final matchesSearch = (review.userName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (review.comment ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesFilter = true;
      if (_selectedFilter == 'High Rating') {
        matchesFilter = review.rating >= 4;
      } else if (_selectedFilter == 'Low Rating') {
        matchesFilter = review.rating <= 2;
      } else if (_selectedFilter == 'Flagged') {
        // Simulating flagged status based on ID for demo
        matchesFilter = review.id % 5 == 0;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final colorScheme = themeProvider.currentScheme;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, l10n, colorScheme),
          _buildStatsRow(l10n, colorScheme),
          _buildFilters(l10n, colorScheme),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReviewsList(l10n, colorScheme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ThemeColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colorScheme.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(
                  l10n.isArabic ? 'إدارة التقييمات' : 'Manage Reviews',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance back button
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: l10n.isArabic ? 'البحث في التقييمات...' : 'Search reviews...',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n, ThemeColorScheme colorScheme) {
    final total = _reviews.length;
    final avg = total > 0 ? _reviews.map((e) => e.rating).reduce((a, b) => a + b) / total : 0.0;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(l10n.isArabic ? 'الإجمالي' : 'Total', total.toString(), Icons.rate_review, Colors.blue),
          _buildStatItem(l10n.isArabic ? 'المتوسط' : 'Avg Rating', avg.toStringAsFixed(1), Icons.star, Colors.orange),
          _buildStatItem(l10n.isArabic ? 'معلق' : 'Pending', '3', Icons.pending_actions, Colors.amber),
          _buildStatItem(l10n.isArabic ? 'مبلغ عنه' : 'Flagged', '2', Icons.flag, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _buildFilters(AppLocalizations l10n, ThemeColorScheme colorScheme) {
    final filters = [
      {'key': 'All', 'en': 'All', 'ar': 'الكل'},
      {'key': 'High Rating', 'en': 'High Rating', 'ar': 'تقييم عالي'},
      {'key': 'Low Rating', 'en': 'Low Rating', 'ar': 'تقييم منخفض'},
      {'key': 'Flagged', 'en': 'Flagged', 'ar': 'مبلغ عنه'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(l10n.isArabic ? filter['ar']! : filter['en']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter['key']!);
              },
              selectedColor: colorScheme.primary,
              backgroundColor: Colors.transparent,
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              side: BorderSide(color: isSelected ? colorScheme.primary : Colors.grey.shade400),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewsList(AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final filtered = _filteredReviews;
    if (filtered.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                l10n.isArabic ? 'لا توجد تقييمات مطابقة' : 'No matching reviews',
                style: TextStyle(color: Colors.grey[600], fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final review = filtered[index];
        return _buildReviewCard(review, l10n, colorScheme, isDark);
      },
    );
  }

  Future<void> _deleteReview(Review review) async {
    final ok = await ApiService.deleteReview(review.id);
    if (ok && mounted) {
      setState(() => _reviews.removeWhere((r) => r.id == review.id));
    }
  }

  Widget _buildReviewCard(Review review, AppLocalizations l10n, ThemeColorScheme colorScheme, bool isDark) {
    final status = review.id % 5 == 0 ? 'Flagged' : (review.id % 3 == 0 ? 'Pending' : 'Approved');
    final statusColor = status == 'Approved' ? Colors.green : (status == 'Flagged' ? Colors.red : Colors.orange);
    final statusLabel = status == 'Approved' 
        ? (l10n.isArabic ? 'معتمد' : 'Approved') 
        : (status == 'Flagged' ? (l10n.isArabic ? 'مبلغ عنه' : 'Flagged') : (l10n.isArabic ? 'قيد الانتظار' : 'Pending'));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.secondary.withOpacity(0.2),
                  child: Text(
                    (review.userName ?? 'U')[0].toUpperCase(),
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName ?? 'Anonymous',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        review.createdAt != null ? DateFormat('yyyy-MM-dd').format(review.createdAt!) : '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.home, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${l10n.isArabic ? 'عقار رقم' : 'Property ID'}: ${review.propertyId}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              review.comment ?? '',
              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  onPressed: () => _showConfirmation(l10n.isArabic ? 'تم اعتماد التقييم' : 'Review approved'),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.flag_outlined,
                  color: Colors.orange,
                  onPressed: () => _showConfirmation(l10n.isArabic ? 'تم وضع علامة على التقييم' : 'Review flagged'),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  onPressed: () => _deleteReview(review),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _showConfirmation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
