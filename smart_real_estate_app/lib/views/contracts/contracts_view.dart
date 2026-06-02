import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/contract_model.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/riyal_icon.dart';

class ContractsView extends StatefulWidget {
  const ContractsView({Key? key}) : super(key: key);

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Contract> _allContracts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      final contracts = await ApiService.getContracts(userId);
      if (mounted) {
        setState(() {
          _allContracts = contracts.isNotEmpty ? contracts : MockDataService.getContracts();
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() { _allContracts = MockDataService.getContracts(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Contract> _getFilteredContracts(int index) {
    switch (index) {
      case 0: // Active (Signed)
        return _allContracts.where((c) => c.status == ContractStatus.signed).toList();
      case 1: // Pending
        return _allContracts.where((c) => c.status == ContractStatus.pending || c.status == ContractStatus.underReview).toList();
      case 2: // Completed/Expired
        return _allContracts.where((c) => c.status == ContractStatus.expired || c.status == ContractStatus.cancelled).toList();
      default: // All
        return _allContracts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primaryColor = themeProvider.currentScheme.primary;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeProvider.currentScheme.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          l10n.myContracts_,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.active),
            Tab(text: l10n.pendingSignature.split(' ').first), // Pending
            Tab(text: l10n.expired),
            Tab(text: l10n.allProperties.split(' ').first), // All
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) => _buildContractList(_getFilteredContracts(index))),
            ),
    );
  }

  Widget _buildContractList(List<Contract> contracts) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).noContracts,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return _buildContractCard(contract);
      },
    );
  }

  Widget _buildContractCard(Contract contract) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: contract.propertyImage.isNotEmpty
                      ? Image.network(
                          contract.propertyImage,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Icon(Icons.home, size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.home, size: 40, color: Colors.grey),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(
                            contract.typeLabelAr,
                            _getTypeColor(contract.type),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            contract.statusLabelAr,
                            _getStatusColor(contract.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${l10n.buyer_}: ${contract.buyerName}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${l10n.seller_}: ${contract.sellerName}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    RiyalIcon(size: 16, color: themeProvider.currentScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      contract.amount.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${contract.createdAt.day}/${contract.createdAt.month}/${contract.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.visibility_outlined,
                  label: l10n.view,
                  onPressed: () => context.push('/contract-details/${contract.id}'),
                ),
                if (contract.status == ContractStatus.pending)
                  _buildActionButton(
                    icon: Icons.edit_note,
                    label: l10n.signContract,
                    onPressed: () => context.push('/contract-details/${contract.id}'),
                    color: Colors.green,
                  ),
                _buildActionButton(
                  icon: Icons.download_outlined,
                  label: l10n.downloadContract.split(' ').first,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Color _getTypeColor(ContractType type) {
    switch (type) {
      case ContractType.sale:
        return Colors.blue;
      case ContractType.rent:
        return Colors.orange;
      case ContractType.agency:
        return Colors.purple;
    }
  }

  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return Colors.orange;
      case ContractStatus.signed:
        return Colors.green;
      case ContractStatus.expired:
        return Colors.red;
      case ContractStatus.cancelled:
        return Colors.grey;
      case ContractStatus.underReview:
        return Colors.blue;
    }
  }
}
