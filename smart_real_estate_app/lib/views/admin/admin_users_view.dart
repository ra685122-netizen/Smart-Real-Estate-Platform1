import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/constants.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  List<User> _users = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await ApiService.getAllUsers();
    if (mounted) setState(() { _users = users; _loading = false; });
  }



  List<User> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _selectedRoleFilter == null || user.role == _selectedRoleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFE74C3C);
      case 'agency':
        return Colors.purple;
      case 'owner':
        return const Color(0xFF1A3A5C);
      case 'seller':
        return const Color(0xFFE8963E);
      case 'buyer':
        return const Color(0xFF2E86AB);
      case 'tenant':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  List<Color> _getRoleGradient(String role) {
    switch (role) {
      case 'admin':
        return [const Color(0xFFE74C3C), const Color(0xFFC0392B)];
      case 'agency':
        return [Colors.purple, Colors.deepPurple];
      case 'owner':
        return [const Color(0xFF1A3A5C), const Color(0xFF2E86AB)];
      case 'seller':
        return [const Color(0xFFE8963E), const Color(0xFFD4A853)];
      case 'buyer':
        return [const Color(0xFF2E86AB), const Color(0xFF3498DB)];
      case 'tenant':
        return [const Color(0xFF2ECC71), const Color(0xFF27AE60)];
      default:
        return [const Color(0xFF7F8C8D), const Color(0xFF95A5A6)];
    }
  }

  void _showUserDialog({User? user}) {
    final loc = AppLocalizations.of(context);
    final isEditing = user != null;
    final nameController     = TextEditingController(text: user?.name ?? '');
    final emailController    = TextEditingController(text: user?.email ?? '');
    final phoneController    = TextEditingController(text: user?.phone ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? 'tenant';
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? loc.editUser : loc.addUser,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: loc.fullName,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: loc.email,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: loc.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    if (!isEditing) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: loc.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: InputDecoration(
                        labelText: loc.accountType,
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      items: [...AppConstants.roles, 'admin'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            loc.getRoleName(role),
                            style: GoogleFonts.cairo(),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx),
                  child: Text(loc.cancel),
                ),
                ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (nameController.text.isEmpty || emailController.text.isEmpty) return;
                    if (!isEditing && passwordController.text.isEmpty) return;

                    setDialogState(() => saving = true);

                    bool success = false;
                    String? errorMsg;

                    if (isEditing) {
                      final result = await ApiService.updateUser({
                        'id':    user.id,
                        'name':  nameController.text.trim(),
                        'email': emailController.text.trim(),
                        'phone': phoneController.text.trim(),
                        'role':  selectedRole,
                      });
                      success  = result['success'] == true;
                      errorMsg = result['message'];
                    } else {
                      final result = await ApiService.register(
                        nameController.text.trim(),
                        emailController.text.trim(),
                        passwordController.text,
                        selectedRole,
                      );
                      success  = result['success'] == true;
                      errorMsg = result['message'];
                    }

                    setDialogState(() => saving = false);

                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);

                    if (success) {
                      _loadUsers();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? loc.userUpdated : loc.userAdded),
                            backgroundColor: const Color(0xFF2ECC71),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg ?? (loc.isArabic ? 'فشل الحفظ' : 'Save failed')),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? loc.save : loc.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(User user, int index) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            loc.deleteUser,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          content: Text(
            loc.confirmDelete,
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await ApiService.deleteUser(user.id);
                if (!mounted) return;
                if (ok) {
                  setState(() => _users.removeWhere((u) => u.id == user.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.userDeleted),
                      backgroundColor: const Color(0xFFE74C3C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.isArabic ? 'فشل الحذف' : 'Delete failed'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(loc.delete),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetails(User user) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor:
                    _getRoleColor(user.role).withValues(alpha: 0.15),
                child: Text(
                  user.name[0],
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 8),
              if (user.phone != null)
                Text(
                  user.phone!,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getRoleGradient(user.role),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loc.getRoleName(user.role),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(loc.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredUsers;
    final allRoles = ['admin', ...AppConstants.roles];

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.manageUsers, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.person_add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: loc.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    label: Text(loc.viewAll, style: GoogleFonts.cairo()),
                    selected: _selectedRoleFilter == null,
                    onSelected: (_) =>
                        setState(() => _selectedRoleFilter = null),
                  ),
                ),
                ...allRoles.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: FilterChip(
                      label: Text(loc.getRoleName(role),
                          style: GoogleFonts.cairo()
                              .copyWith(color: _getRoleColor(role))),
                      selected: _selectedRoleFilter == role,
                      onSelected: (_) =>
                          setState(() => _selectedRoleFilter = role),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64,
                            color: isDark
                                ? const Color.fromARGB(213, 7, 20, 25)
                                : const Color.fromARGB(255, 16, 37, 38)),
                        const SizedBox(height: 16),
                        Text(
                          loc.noResults,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color.fromARGB(255, 3, 57, 68)
                                : const Color.fromARGB(255, 3, 50, 53),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return _buildUserCard(user, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user, int index) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor:
                  _getRoleColor(user.role).withValues(alpha: 0.12),
              child: Text(
                user.name[0],
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _getRoleColor(user.role),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                  if (user.phone != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 12, color: Color(0xFF7F8C8D)),
                        const SizedBox(width: 4),
                        Text(
                          user.phone!,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getRoleGradient(user.role),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      loc.getRoleName(user.role),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  _showUserDetails(user);
                } else if (value == 'edit') {
                  _showUserDialog(user: user);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(user, index);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.view, style: GoogleFonts.cairo()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(loc.edit, style: GoogleFonts.cairo()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline,
                          size: 20, color: Color(0xFFE74C3C)),
                      const SizedBox(width: 8),
                      Text(loc.delete,
                          style: GoogleFonts.cairo(
                              color: const Color(0xFFE74C3C))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
