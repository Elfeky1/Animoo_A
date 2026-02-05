import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/api_service.dart';
import 'admin_ad_details_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;
  bool usersLoading = true;

  List pendingAds = [];
  List approvedAds = [];
  List users = [];
  Map stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchDashboard();
    fetchUsers();
  }

  Future<void> fetchDashboard() async {
    setState(() => isLoading = true);

    final pending = await ApiService.getPendingAds();
    final approved = await ApiService.getApprovedAds();
    final s = await ApiService.getAdStats();

    if (!mounted) return;

    setState(() {
      pendingAds = pending;
      approvedAds = approved;
      stats = s;
      isLoading = false;
    });
  }

  Future<void> fetchUsers() async {
    usersLoading = true;
    final data = await ApiService.getUsers();

    if (!mounted) return;

    setState(() {
      users = data;
      usersLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: const Color(0xff24394a),
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Stats'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _pendingTab(),
                _approvedTab(),
                _statsTab(),
                _usersTab(),
              ],
            ),
    );
  }

  Widget _pendingTab() {
    return pendingAds.isEmpty
        ? const Center(child: Text('No pending ads 🎉'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingAds.length,
            itemBuilder: (context, index) {
              return _adCard(pendingAds[index]);
            },
          );
  }

  Widget _approvedTab() {
    return approvedAds.isEmpty
        ? const Center(child: Text('No approved ads'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvedAds.length,
            itemBuilder: (context, index) {
              return _adCard(approvedAds[index], clickable: false);
            },
          );
  }

  Widget _statsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _statCard(
                title: 'Pending',
                value: stats['pending']?.toString() ?? '0',
                color: Colors.orange,
                icon: Icons.pending_actions,
              ),
              const SizedBox(width: 12),
              _statCard(
                title: 'Approved',
                value: stats['approved']?.toString() ?? '0',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(
                title: 'Rejected',
                value: stats['rejected']?.toString() ?? '0',
                color: Colors.red,
                icon: Icons.cancel,
              ),
              const SizedBox(width: 12),
              _statCard(
                title: 'Total Ads',
                value: stats['total']?.toString() ?? '0',
                color: Colors.blue,
                icon: Icons.all_inbox,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Ads Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _adsPieChart(),
        ],
      ),
    );
  }

  Widget _usersTab() {
    if (usersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: fetchUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isBanned = user['isBanned'] == true;
          final role = user['role'];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isBanned ? Colors.red : const Color(0xff24394a),
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email']),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _chip(
                        role.toUpperCase(),
                        role == 'admin' ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      _chip(
                        isBanned ? 'BANNED' : 'ACTIVE',
                        isBanned ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'ban') {
                    await ApiService.toggleBan(user['_id']);
                  } else if (value == 'role') {
                    final newRole = role == 'admin' ? 'user' : 'admin';
                    await ApiService.changeRole(user['_id'], newRole);
                  }
                  fetchUsers();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'ban',
                    child: Text(isBanned ? 'Unban' : 'Ban'),
                  ),
                  const PopupMenuItem(
                    value: 'role',
                    child: Text('Change Role'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _adCard(Map ad, {bool clickable = true}) {
    final images = ad['images'] ?? [];

    return GestureDetector(
      onTap: clickable
          ? () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminAdDetailsScreen(),
                  settings: RouteSettings(arguments: ad),
                ),
              );
              if (updated == true) fetchDashboard();
            }
          : null,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  '${ApiService.baseUrl}/uploads/${images.first}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad['name'] ?? '',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ad['description'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _adsPieChart() {
    final pending = (stats['pending'] ?? 0).toDouble();
    final approved = (stats['approved'] ?? 0).toDouble();
    final rejected = (stats['rejected'] ?? 0).toDouble();

    if (pending + approved + rejected == 0) {
      return const Center(child: Text('No data available'));
    }

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 50,
          sectionsSpace: 4,
          sections: [
            PieChartSectionData(
              value: approved,
              title: 'Approved',
              color: Colors.green,
              radius: 60,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: pending,
              title: 'Pending',
              color: Colors.orange,
              radius: 60,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: rejected,
              title: 'Rejected',
              color: Colors.red,
              radius: 60,
              titleStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
