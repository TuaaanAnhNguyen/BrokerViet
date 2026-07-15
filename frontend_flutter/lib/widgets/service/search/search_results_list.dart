import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../widgets/service/service_card.dart';
import '../../../features/main/service_detail_screen.dart';

class SearchResultsList extends StatelessWidget {
  final List<ServiceModel> searchResults;

  const SearchResultsList({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final service = searchResults[index];
        return ServiceCard(
          service: service,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ServiceDetailScreen(serviceId: service.id),
              ),
            );
          },
        );
      },
    );
  }
}
