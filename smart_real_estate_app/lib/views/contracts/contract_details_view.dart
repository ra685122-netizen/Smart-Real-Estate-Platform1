import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/contract_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/riyal_icon.dart';
import '../../widgets/signature_pad.dart';

class ContractDetailsView extends StatefulWidget {
  final int contractId;
  const ContractDetailsView({Key? key, required this.contractId}) : super(key: key);

  @override
  State<ContractDetailsView> createState() => _ContractDetailsViewState();
}

class _ContractDetailsViewState extends State<ContractDetailsView> {
  Contract? _contract;
  bool _loading = true;
  bool _isSignedLocally = false;
  bool _hasSigDrawn = false;
  String? _signatureB64;
  final GlobalKey<SignaturePadState> _sigKey = GlobalKey<SignaturePadState>();

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    final contract = await ApiService.getContractById(widget.contractId);
    if (mounted) {
      setState(() {
        _contract = contract ?? MockDataService.getContractById(widget.contractId);
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
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final contract = _contract!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: themeProvider.currentScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${l10n.contractNumber} ${contract.contractNumber}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeProvider.currentScheme.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(),
                  const SizedBox(height: 20),
                  _buildPropertyCard(),
                  const SizedBox(height: 20),
                  _buildPartiesSection(),
                  const SizedBox(height: 20),
                  _buildTermsSection(),
                  const SizedBox(height: 20),
                  _buildSignatureSection(),
                  const SizedBox(height: 20),
                  _buildTimeline(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildActionButtons(contract),
    );
  }

  Widget _buildStatusHeader() {
    final contract = _contract!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(contract.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _getStatusColor(contract.status).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(contract.status), color: _getStatusColor(contract.status)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contract.statusLabelAr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _getStatusColor(contract.status),
                ),
              ),
              Text(
                'تم التحديث في ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard() {
    final contract = _contract!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: contract.propertyImage.isNotEmpty
                  ? Image.network(
                      contract.propertyImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80, height: 80, color: Colors.grey[200],
                        child: const Icon(Icons.home, size: 32, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 80, height: 80, color: Colors.grey[200],
                      child: const Icon(Icons.home, size: 32, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.propertyTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RiyalIcon(size: 16, color: themeProvider.currentScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        contract.amount.toStringAsFixed(0),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.currentScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartiesSection() {
    final contract = _contract!;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ownerInfo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildPartyCard(l10n.buyer_, contract.buyerName, contract.buyerSigned || _isSignedLocally)),
            const SizedBox(width: 12),
            Expanded(child: _buildPartyCard(l10n.seller_, contract.sellerName, contract.sellerSigned)),
          ],
        ),
      ],
    );
  }

  Widget _buildPartyCard(String role, String name, bool signed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (signed)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text('تم التوقيع', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pending, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text('في انتظار التوقيع', style: TextStyle(color: Colors.orange, fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return ExpansionTile(
      title: const Text('بنود العقد والشروط', style: TextStyle(fontWeight: FontWeight.bold)),
      leading: const Icon(Icons.gavel),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '1. يلتزم الطرف الأول بتسليم العقار في التاريخ المحدد.\n'
            '2. يلتزم الطرف الثاني بدفع المبلغ المتفق عليه.\n'
            '3. يخضع هذا العقد للأنظمة واللوائح المعمول بها في المملكة العربية السعودية.\n'
            '4. أي نزاع ينشأ عن هذا العقد يتم حله ودياً أو عن طريق الجهات المختصة.',
            style: TextStyle(height: 1.6, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    final contract = _contract!;
    if (contract.status != ContractStatus.pending) return const SizedBox.shrink();

    return SignaturePad(
      key: _sigKey,
      onChanged: (hasSig) => setState(() => _hasSigDrawn = hasSig),
      onConfirmed: () => setState(() => _isSignedLocally = true),
    );
  }

  Widget _buildTimeline() {
    final contract = _contract!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('سجل العقد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildTimelineItem('تم إنشاء العقد', '${contract.createdAt.day}/${contract.createdAt.month}/${contract.createdAt.year}', true),
        _buildTimelineItem('تم إرسال العقد للمراجعة', '${contract.createdAt.day}/${contract.createdAt.month}/${contract.createdAt.year}', true),
        _buildTimelineItem('توقيع الطرف الأول', contract.buyerSigned ? 'مكتمل' : 'قيد الانتظار', contract.buyerSigned),
        _buildTimelineItem('توقيع الطرف الثاني', contract.sellerSigned ? 'مكتمل' : 'قيد الانتظار', contract.sellerSigned),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String date, bool completed) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? Colors.green : Colors.grey[300],
              ),
              child: completed ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            Container(width: 2, height: 30, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: completed ? FontWeight.bold : FontWeight.normal)),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(Contract contract) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (contract.status == ContractStatus.pending) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: _isSignedLocally
                    ? () async {
                        HapticFeedback.heavyImpact();
                        final user = context.read<AuthProvider>().currentUser;
                        if (user != null) {
                          final role = (user.id == contract.buyerId) ? 'buyer' : 'seller';
                          await ApiService.signContract(
                            contract.id,
                            user.id,
                            role,
                            _signatureB64 ?? '',
                          );
                          await _loadContract();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.isArabic
                                    ? 'تم إرسال العقد بتوقيعك الإلكتروني ✓'
                                    : 'Contract sent with your e-signature ✓',
                                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.currentScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  l10n.signContract,
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              tooltip: l10n.rejectContract,
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, color: themeProvider.currentScheme.primary),
                label: Text(
                  l10n.downloadContract.split(' ').first,
                  style: GoogleFonts.cairo(color: themeProvider.currentScheme.primary, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: themeProvider.currentScheme.primary,
                  side: BorderSide(color: themeProvider.currentScheme.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  l10n.shareContract.split(' ').first,
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.currentScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }

  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending: return Colors.orange;
      case ContractStatus.signed: return Colors.green;
      case ContractStatus.expired: return Colors.red;
      case ContractStatus.cancelled: return Colors.grey;
      case ContractStatus.underReview: return Colors.blue;
    }
  }

  IconData _getStatusIcon(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending: return Icons.pending_actions;
      case ContractStatus.signed: return Icons.verified_user;
      case ContractStatus.expired: return Icons.history;
      case ContractStatus.cancelled: return Icons.cancel;
      case ContractStatus.underReview: return Icons.rate_review;
    }
  }
}
