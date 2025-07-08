import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/wardrobe_provider.dart';
import '../../widgets/cards/outfit_card.dart';
import '../../models/outfit.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.recommendations),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(
              Icons.person,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopPickSection(),
            const SizedBox(height: AppStyles.largePadding),
            _buildExploreNewLooksSection(),
            const SizedBox(height: AppStyles.largePadding),
            _buildRecentlyViewedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPickSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.yourTopPick,
          style: AppStyles.titleTextStyle,
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        OutfitCard(
          outfit: _getSampleOutfit(
            'Urban Explorer Look',
            'A perfect blend of comfort and street-style edge for your next adventure.',
            4.8,
          ),
          height: 300,
          onTryOn: () => _handleTryOn('urban-explorer'),
          onSave: () => _handleSave('urban-explorer'),
        ),
      ],
    );
  }

  Widget _buildExploreNewLooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.exploreNewLooks,
              style: AppStyles.titleTextStyle,
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                AppStrings.seeAll,
                style: TextStyle(color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              final outfits = [
                _getSampleOutfit(
                  'Relaxed Weekend Vibe',
                  'Effortless style for a casual day out or lounging in.',
                  4.5,
                ),
                _getSampleOutfit(
                  'Sophisticated Evening',
                  'Turn heads with this elegant and timeless ensemble.',
                  4.9,
                ),
                _getSampleOutfit(
                  'Active Lifestyle',
                  'Perfect for workouts and outdoor adventures.',
                  4.3,
                ),
              ];

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: AppStyles.defaultPadding),
                child: OutfitCard(
                  outfit: outfits[index],
                  onTryOn: () => _handleTryOn('outfit-${index + 1}'),
                  onSave: () => _handleSave('outfit-${index + 1}'),
                  onLike: () => _handleLike('outfit-${index + 1}'),
                  onDislike: () => _handleDislike('outfit-${index + 1}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.recentlyViewed,
              style: AppStyles.titleTextStyle,
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                AppStrings.viewHistory,
                style: TextStyle(color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppStyles.defaultPadding),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              final outfits = [
                _getSampleOutfit(
                  'Urban Chic Ensemble',
                  'Perfect for city explorations and casual meetups.',
                  4.6,
                ),
                _getSampleOutfit(
                  'Relaxed Weekend Look',
                  'Comfort meets style for your laid-back days.',
                  4.5,
                ),
              ];

              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: AppStyles.defaultPadding),
                child: OutfitCard(
                  outfit: outfits[index],
                  showActions: false,
                  onTap: () => _handleViewOutfit('recent-${index + 1}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Outfit _getSampleOutfit(String name, String description, double rating) {
    return Outfit(
      name: name,
      description: description,
      clothingItemIds: ['1', '2', '3'],
      rating: rating,
      style: 'Casual',
      occasion: 'Everyday',
      imagePath: 'assets/images/outfit_placeholder.jpg',
    );
  }

  void _handleTryOn(String outfitId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trying on outfit: $outfitId'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }

  void _handleSave(String outfitId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved outfit: $outfitId'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleLike(String outfitId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked outfit: $outfitId'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleDislike(String outfitId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disliked outfit: $outfitId'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _handleViewOutfit(String outfitId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing outfit: $outfitId'),
        backgroundColor: AppColors.primaryPurple,
      ),
    );
  }
}
