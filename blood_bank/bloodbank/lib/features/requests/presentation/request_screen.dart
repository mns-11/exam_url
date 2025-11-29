import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/request_model.dart';
import 'providers/request_provider.dart';
import 'create_request_screen.dart';

class RequestScreen extends StatefulWidget {
  final String userId;
  
  const RequestScreen({
    super.key,
    required this.userId,
  });

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool _isLoading = false;
  String? _error;
  late RequestProvider _requestProvider;

  @override
  void initState() {
    super.initState();
    _requestProvider = RequestProvider();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _requestProvider.loadRequests();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'فشل تحميل الطلبات. يرجى المحاولة مرة أخرى';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _requestProvider,
      child: Consumer<RequestProvider>(
        builder: (context, requestProvider, _) {
          final userRequests = requestProvider.getUserRequests(widget.userId);
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('طلبات التبرع بالدم'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRequestScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadRequests,
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRequests,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : userRequests.isEmpty
                        ? const Center(
                            child: Text('لا توجد طلبات حتى الآن'),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRequests,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: userRequests.length,
                              itemBuilder: (context, index) {
                                final request = userRequests[index];
                                return _buildRequestCard(context, request);
                              },
                            ),
                          ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, BloodRequest request) {
    final progress = request.unitsDonated / request.unitsNeeded;
    final progressPercent = (progress * 100).clamp(0.0, 100.0);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to request details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.patientName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (request.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'عاجل',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow('فصيلة الدم', request.bloodType),
              _buildInfoRow('المستشفى', request.hospitalName),
              _buildInfoRow('المدينة', request.city),
              if (request.requiredDate != null)
                _buildInfoRow(
                  'مطلوب قبل',
                  DateFormat('yyyy/MM/dd').format(request.requiredDate!),
                ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1 ? Colors.green : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${request.unitsDonated} / ${request.unitsNeeded} وحدات',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${progressPercent.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تاريخ الطلب: ${DateFormat('yyyy/MM/dd').format(request.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.location_on, size: 16),
                    label: const Text('الموقع'),
                    onPressed: () async {
                      // Open map with hospital location
                      final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(request.hospitalLocation)}';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تعذر فتح الخريطة')),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
