import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:bloodbank/features/auth/presentation/providers/auth_provider.dart';
import 'package:bloodbank/features/requests/domain/request_model.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  _AdminReportsScreenState createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  // Statistics data
  int _totalDonations = 0;
  int _pendingRequests = 0;
  int _urgentRequests = 0;

  // Chart data
  List<FlSpot> _donationTrends = [];
  Map<String, int> _bloodTypeDistribution = {};
  List<BloodRequest> _allDonations = [];
  List<BloodRequest> _filteredDonations = [];

  // Colors for charts
  final List<Color> _bloodTypeColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  late Timer _autoRefreshTimer;
  final Duration _animationDuration = const Duration(milliseconds: 600);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
    _searchController.addListener(_filterDonations);
  }

  @override
  void dispose() {
    _autoRefreshTimer.cancel();
    _searchController.removeListener(_filterDonations);
    _searchController.dispose();
    super.dispose();
  }

  void _filterDonations() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredDonations = List.from(_allDonations);
      });
    } else {
      setState(() {
        _filteredDonations = _allDonations.where((d) {
          final lowerQuery = query.toLowerCase();
          return d.patientName.toLowerCase().contains(lowerQuery) || d.bloodType.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  Future<void> _loadData() async {
    if (_isRefreshing) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API calls
      final newDonations = [
        BloodRequest(
          id: '1',
          patientName: 'محمد أحمد',
          bloodType: 'A+',
          hospitalName: 'مستشفى الملك فهد',
          city: 'الرياض',
          contactNumber: '0501234567',
          caseDescription: 'عملية قلب مفتوح',
          hospitalLocation: 'الرياض - حي الملقا',
          unitsNeeded: 3,
          unitsDonated: 1,
          isUrgent: true,
          requiredDate: DateTime.now().add(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          createdBy: 'user1',
        ),
        BloodRequest(
          id: '2',
          patientName: 'سارة محمد',
          bloodType: 'O-',
          hospitalName: 'مستشفى الملك خالد',
          city: 'جدة',
          contactNumber: '0557654321',
          caseDescription: 'ولادة قيصرية',
          hospitalLocation: 'جدة - حي الصفا',
          unitsNeeded: 2,
          unitsDonated: 0,
          isUrgent: false,
          requiredDate: DateTime.now().add(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          createdBy: 'user2',
        ),
      ];

      setState(() {
        _totalDonations = 42;
        _pendingRequests = 7;
        _urgentRequests = 3;

        // Generate mock donation trends (last 7 days)
        _donationTrends = List.generate(7, (i) => FlSpot(i.toDouble(), (i * 2 + 5).toDouble()));

        // Mock blood type distribution
        _bloodTypeDistribution = {
          'A+': 15,
          'A-': 5,
          'B+': 12,
          'B-': 4,
          'O+': 20,
          'O-': 8,
          'AB+': 3,
          'AB-': 1,
        };

        _allDonations = newDonations;
        _filteredDonations = List.from(_allDonations);

        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات: ${e.toString()}';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;

    setState(() {
      _isRefreshing = true;
    });

    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _handleRefresh,
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isLoading && !_isRefreshing
            ? Center(
                key: const ValueKey('loading'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('جارٍ تحميل البيانات...'),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    key: const ValueKey('error'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: Colors.redAccent,
                    backgroundColor: Colors.white,
                    displacement: 40,
                    edgeOffset: 20,
                    child: SingleChildScrollView(
                      key: const ValueKey('content'),
                      padding: const EdgeInsets.all(16.0),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummaryCards(),
                          const SizedBox(height: 24),
                          _buildDonationTrendsChart(),
                          const SizedBox(height: 24),
                          _buildBloodTypeDistribution(),
                          const SizedBox(height: 24),
                          _buildRecentDonations(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final cards = [
      _buildStatCard(
        'إجمالي التبرعات',
        _totalDonations.toString(),
        Icons.bloodtype,
        Colors.red,
      ),
      _buildStatCard(
        'طلبات قيد الانتظار',
        _pendingRequests.toString(),
        Icons.pending_actions,
        Colors.orange,
      ),
      _buildStatCard(
        'طلبات عاجلة',
        _urgentRequests.toString(),
        Icons.warning,
        Colors.red,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: cards
          .map(
            (card) => AnimatedOpacity(
              opacity: _isLoading ? 0.5 : 1.0,
              duration: _animationDuration,
              child: card,
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationTrendsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'اتجاهات التبرع الأسبوعية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Hero(
              tag: 'donationTrendsChart',
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _donationTrends,
                        isCurved: true,
                        barWidth: 2,
                        color: Colors.red,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeDistribution() {
    final data = _bloodTypeDistribution.entries.map((e) {
      final index = _bloodTypeDistribution.keys.toList().indexOf(e.key);
      return PieChartSectionData(
        color: _bloodTypeColors[index % _bloodTypeColors.length],
        value: e.value.toDouble(),
        title: '${e.key}\n${e.value}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع فصائل الدم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Hero(
              tag: 'bloodTypeDistributionChart',
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: data,
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDonations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'آخر التبرعات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ابحث عن متبرع أو نوع دم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_filteredDonations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('لا توجد تبرعات حديثة'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredDonations.length,
                itemBuilder: (context, index) {
                  final donation = _filteredDonations[index];
                  return AnimatedContainer(
                    duration: _animationDuration,
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.bloodtype, color: Colors.red),
                      title: Text('تبرع ${donation.bloodType}'),
                      subtitle: Text(
                        DateFormat('yyyy/MM/dd - hh:mm a').format(donation.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {
                        // TODO: Show donation details with animation or page transition
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
