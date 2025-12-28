import 'package:flutter/material.dart';
import 'package:pharmacy_app/core/themes/app_theme.dart';

class FeaturedSection extends StatelessWidget {
  FeaturedSection({super.key});

  final List<FeaturedItem> featuredItems = [
    FeaturedItem(
      title: 'Get 20% OFF on First Order',
      subtitle: 'Use code: WELCOME20',
      imageUrl: 'assets/featured1.png',
      backgroundColor: const Color(0xFFE3F2FD),
      textColor: const Color(0xFF1565C0),
      buttonText: 'Shop Now',
    ),
    FeaturedItem(
      title: 'Free Delivery Today',
      subtitle: 'On orders above ₹499',
      imageUrl: 'assets/featured2.png',
      backgroundColor: const Color(0xFFE8F5E9),
      textColor: const Color(0xFF2E7D32),
      buttonText: 'Order Now',
    ),
    FeaturedItem(
      title: 'Doctor Consultation',
      subtitle: 'Online consultation with certified doctors',
      imageUrl: 'assets/featured3.png',
      backgroundColor: const Color(0xFFFFF3E0),
      textColor: const Color(0xFFEF6C00),
      buttonText: 'Book Now',
    ),
    FeaturedItem(
      title: 'Prescription Upload',
      subtitle: 'Upload and get medicines delivered',
      imageUrl: 'assets/featured4.png',
      backgroundColor: const Color(0xFFF3E5F5),
      textColor: const Color(0xFF7B1FA2),
      buttonText: 'Upload Now',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppTheme.secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Hot Deals',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: featuredItems.length,
            controller: PageController(viewportFraction: 0.8),
            padEnds: false,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FeaturedCard(item: featuredItems[index]),
              );
            },
          ),
        ),
        
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featuredItems.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == 0 
                    ? AppTheme.primaryColor 
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturedItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color backgroundColor;
  final Color textColor;
  final String buttonText;

  FeaturedItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.textColor,
    required this.buttonText,
  });
}

class FeaturedCard extends StatelessWidget {
  final FeaturedItem item;

  const FeaturedCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            right: 40,
            bottom: 40,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.textColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: item.textColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: item.textColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _handleFeaturedAction(item.title, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.textColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          item.buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForType(item.title),
                        size: 60,
                        color: item.textColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String title) {
    if (title.contains('OFF') || title.contains('Shop')) {
      return Icons.local_offer;
    } else if (title.contains('Delivery')) {
      return Icons.delivery_dining;
    } else if (title.contains('Consultation')) {
      return Icons.medical_services;
    } else if (title.contains('Prescription')) {
      return Icons.document_scanner;
    }
    return Icons.star;
  }

  void _handleFeaturedAction(String title, BuildContext context) {
    if (title.contains('OFF') || title.contains('Shop')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigating to products...')),
      );
    } else if (title.contains('Delivery')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Showing delivery information...')),
      );
    } else if (title.contains('Consultation')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening consultation booking...')),
      );
    } else if (title.contains('Prescription')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening prescription upload...')),
      );
    }
  }
}