import 'package:flutter/material.dart';
import 'package:pharmacy_app/themes/app_theme.dart';

class FeaturedSection extends StatefulWidget {
  const FeaturedSection({super.key});

  @override
  State<FeaturedSection> createState() => _FeaturedSectionState();
}

class _FeaturedSectionState extends State<FeaturedSection> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<FeaturedItem> featuredItems = [
    FeaturedItem(
      title: '20% OFF First Order',
      subtitle: 'Use code: WELCOME20',
      backgroundColor: const Color(0xFFE3F2FD),
      textColor: const Color(0xFF1565C0),
    ),
    FeaturedItem(
      title: 'Free Delivery',
      subtitle: 'On orders above 15000FCFA',
      backgroundColor: const Color(0xFFE8F5E9),
      textColor: const Color(0xFF2E7D32),
    ),
    FeaturedItem(
      title: 'Doctor Consultation',
      subtitle: 'Online with doctors',
      backgroundColor: const Color(0xFFFFF3E0),
      textColor: const Color(0xFFEF6C00),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppTheme.secondaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hot Deals',
                      style: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featuredItems.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == featuredItems.length - 1 ? 16 : 8,
                ),
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
            (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: _currentPage == index 
                  ? BorderRadius.circular(4) 
                  : BorderRadius.circular(8), // Always use borderRadius
              color: _currentPage == index 
                  ? AppTheme.primaryColor 
                  : Colors.grey.withOpacity(0.3),
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
  final Color backgroundColor;
  final Color textColor;

  FeaturedItem({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
  });
}

class FeaturedCard extends StatelessWidget {
  final FeaturedItem item;

  const FeaturedCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: item.textColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: item.textColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Shop Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(item.title),
                size: 40,
                color: item.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String title) {
    if (title.contains('OFF')) return Icons.local_offer;
    if (title.contains('Delivery')) return Icons.delivery_dining;
    if (title.contains('Consultation')) return Icons.medical_services;
    return Icons.star;
  }
}