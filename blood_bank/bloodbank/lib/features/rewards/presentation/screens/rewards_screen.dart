import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bloodbank/features/donations/presentation/providers/donation_provider.dart';
import 'package:bloodbank/features/auth/presentation/providers/auth_provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    // Load donations when screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final donationProvider = context.read<DonationProvider>();
      donationProvider.fetchUserDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final donationProvider = context.watch<DonationProvider>();

    // Calculate total points
    final totalPoints = donationProvider.donations
        .where((d) => d.isVerified)
        .fold(0, (sum, d) => sum + d.pointsAwarded);

    // Check if user can donate again
    final canDonate = donationProvider.donations.isEmpty || 
        donationProvider.donations.first.canDonateAgain;
    
    // Next donation date
    final nextDonationDate = donationProvider.donations.isNotEmpty
        ? DateFormat('yyyy/MM/dd').format(
            donationProvider.donations.first.donationDate.add(const Duration(days: 180)),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('النقاط والمكافآت'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => donationProvider.fetchUserDonations(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Points Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'رصيد النقاط',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalPoints نقطة',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!canDonate && nextDonationDate != null)
                        Text(
                          'يمكنك التبرع مرة أخرى بعد $nextDonationDate',
                          style: const TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center,
                        )
                      else
                        const Text(
                          'يمكنك التبرع الآن',
                          style: TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Donation History
              const Text(
                'سجل التبرعات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (donationProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (donationProvider.donations.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('لا توجد تبرعات مسجلة'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: donationProvider.donations.length,
                  itemBuilder: (context, index) {
                    final donation = donationProvider.donations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          donation.isVerified
                              ? Icons.verified
                              : Icons.pending,
                          color: donation.isVerified ? Colors.green : Colors.orange,
                        ),
                        title: Text(
                          'تبرع ${donation.bloodType} - ${donation.pointsAwarded} نقطة',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('yyyy/MM/dd - hh:mm a')
                              .format(donation.donationDate),
                        ),
                        trailing: donation.isVerified
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.hourglass_empty, color: Colors.orange),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
