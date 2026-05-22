import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../clients/providers/client_provider.dart';
import '../../quotations/providers/quotation_provider.dart';
import '../../projects/providers/project_provider.dart';
import '../../survey/providers/survey_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientListProvider);
    final quotations = ref.watch(quotationListProvider);
    final projects = ref.watch(projectListProvider);
    final surveys = ref.watch(surveyListProvider);

    // Calculate dynamic stats
    final totalClients = clients.length;
    final pendingQuotes = quotations.where((q) => q.status == QuotationStatus.submitted || q.status == QuotationStatus.draft).length;
    final approvedProjects = projects.where((p) => p.stage != ProjectStage.completed).length;
    
    // Revenue = sum of approved/locked quotation prices
    final totalRevenue = quotations
        .where((q) => q.status == QuotationStatus.approved || q.status == QuotationStatus.locked)
        .fold<double>(0.0, (sum, item) => sum + item.netPayableAmount);

    final totalSurveys = surveys.length;

    // Formatting revenue
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(clientListProvider.notifier).loadClients();
          ref.read(quotationListProvider.notifier).loadQuotations();
          ref.read(projectListProvider.notifier).loadProjects();
          ref.read(surveyListProvider.notifier).loadSurveys();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Consultancy Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitor leads, quotes, installations and consultancy revenues.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),

              // Responsive Stats Grid
              _buildStatsGrid(
                context,
                totalClients: totalClients,
                pendingQuotes: pendingQuotes,
                approvedProjects: approvedProjects,
                revenueText: formatter.format(totalRevenue),
                totalSurveys: totalSurveys,
              ),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Trends Chart
                  Expanded(
                    flex: context.isTablet ? 7 : 12,
                    child: _buildRevenueChartCard(context),
                  ),
                  if (context.isTablet) ...[
                    const SizedBox(width: 24),
                    // Recent Activity
                    Expanded(
                      flex: 5,
                      child: _buildRecentActivityCard(context, quotations, projects),
                    ),
                  ],
                ],
              ),
              if (!context.isTablet) ...[
                const SizedBox(height: 24),
                _buildRecentActivityCard(context, quotations, projects),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalClients,
    required int pendingQuotes,
    required int approvedProjects,
    required String revenueText,
    required int totalSurveys,
  }) {
    final columns = context.isTablet ? 5 : 2;

    final items = [
      _StatItem(
        title: 'Total Clients',
        value: totalClients.toString(),
        icon: Icons.people_rounded,
        color: AppColors.lead,
        onTap: () => context.go('/clients'),
      ),
      _StatItem(
        title: 'Pending Quotes',
        value: pendingQuotes.toString(),
        icon: Icons.pending_actions_rounded,
        color: AppColors.surveyPending,
        onTap: () => context.go('/quotations'),
      ),
      _StatItem(
        title: 'Active Projects',
        value: approvedProjects.toString(),
        icon: Icons.architecture_rounded,
        color: AppColors.solarOrange,
        onTap: () => context.go('/projects'),
      ),
      _StatItem(
        title: 'Revenue Collected',
        value: revenueText,
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.approved,
        onTap: () => context.go('/quotations'),
      ),
      _StatItem(
        title: 'Site Surveys',
        value: totalSurveys.toString(),
        icon: Icons.assignment_turned_in_rounded,
        color: AppColors.quotationSent,
        onTap: () => context.go('/clients'),
      ),
    ];

    if (context.isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildStatCard(context, items[index]),
      );
    } else {
      // Mobile Layout
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildStatCard(context, items[index]),
      );
    }
  }

  Widget _buildStatCard(BuildContext context, _StatItem item) {
    return Card(
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, size: 18, color: item.color),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales & Proposals Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Monthly performance based on quotations generated.',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
                          switch (value.toInt()) {
                            case 1:
                              return const Text('Jan', style: style);
                            case 2:
                              return const Text('Feb', style: style);
                            case 3:
                              return const Text('Mar', style: style);
                            case 4:
                              return const Text('Apr', style: style);
                            case 5:
                              return const Text('May', style: style);
                            case 6:
                              return const Text('Jun', style: style);
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3.5, color: AppColors.primary, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5.0, color: AppColors.solarOrange, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7.2, color: AppColors.lead, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 4.8, color: AppColors.quotationSent, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 8.5, color: AppColors.approved, width: 16, borderRadius: BorderRadius.circular(4))]),
                    BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 6.0, color: AppColors.solarOrangeLight, width: 16, borderRadius: BorderRadius.circular(4))]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(
    BuildContext context,
    List<QuotationModel> quotations,
    List<ProjectModel> projects,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (quotations.isEmpty && projects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No activities logged yet.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4, // limit to 4 recent activities
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  // Alternative index between Quotation and Project updates
                  if (index % 2 == 0 && quotations.isNotEmpty) {
                    final qIndex = (index ~/ 2) % quotations.length;
                    final q = quotations[qIndex];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: q.status.color.withOpacity(0.1),
                        child: Icon(Icons.description, color: q.status.color, size: 18),
                      ),
                      title: Text(
                        'Quotation ${q.proposalNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        'Saved as ${q.status.displayName} for ${q.clientName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  } else if (projects.isNotEmpty) {
                    final pIndex = (index ~/ 2) % projects.length;
                    final p = projects[pIndex];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: p.stage.color.withOpacity(0.1),
                        child: Icon(Icons.assignment, color: p.stage.color, size: 18),
                      ),
                      title: Text(
                        'Project Stage Updated',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        '${p.clientName}: Moved to ${p.stage.displayName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
