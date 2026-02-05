import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'EditAdScreen.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  bool isLoading = true;
  List ads = [];

  @override
  void initState() {
    super.initState();
    fetchMyAds();
  }

  Future<void> fetchMyAds() async {
    setState(() => isLoading = true);

    final data = await ApiService.getMyAds();

    if (!mounted) return;

    setState(() {
      ads = data;
      isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('My Ads'),
        backgroundColor: const Color(0xff24394a),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ads.isEmpty
              ? const Center(
                  child: Text(
                    'You have no ads yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchMyAds,
                  child: ListView.builder(
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      final List images = ad['images'] ?? [];
                      final status = ad['status'] ?? 'pending';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: images.isNotEmpty
                                    ? Image.network(
                                        '${ApiService.baseUrl}/uploads/${images.first}',
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ad['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ad['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(status)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: _statusColor(status),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),

                                        if (status == 'pending') ...[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Color(0xff24394a),
                                            ),
                                            onPressed: () async {
                                              final updated =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const EditAdScreen(),
                                                  settings: RouteSettings(
                                                      arguments: ad),
                                                ),
                                              );

                                              if (updated == true) {
                                                fetchMyAds();
                                              }
                                            },
                                          ),


                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title:
                                                      const Text('Delete Ad'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this ad?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                final success =
                                                    await ApiService.deleteAd(
                                                        ad['_id']);
                                                if (success) {
                                                  fetchMyAds();
                                                }
                                              }
                                            },
                                          ),
                                        ] else ...[
                                          
                                          const Icon(Icons.lock,
                                              color: Colors.grey),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
