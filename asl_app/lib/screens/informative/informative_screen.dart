import 'package:asl_app/data/asl_letters_data.dart';
import 'package:asl_app/data/asl_special_gestures_data.dart';  // nuevo
import 'package:asl_app/screens/informative/widgets/letter_card.dart';
import 'package:asl_app/screens/informative/widgets/special_gesture_card.dart';
import 'package:asl_app/themes/app_colors.dart';
import 'package:asl_app/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class InformativeScreen extends StatefulWidget {
  const InformativeScreen({super.key});

  @override
  State<InformativeScreen> createState() => _InformativeScreenState();
}

class _InformativeScreenState extends State<InformativeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildLettersTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: aslAlphabetData.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final letter = aslAlphabetData[index];
          return LetterCard(info: letter);
        },
      ),
    );
  }

  Widget _buildGesturesTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: aslSpecialGesturesData.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final gesture = aslSpecialGesturesData[index];
          return SpecialGestureCard(
            title: gesture.name,
            description: gesture.description,
            imagePath: gesture.imagePath,
            videoPath: gesture.videoPath, // nuevo
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Lengua de Señas Americana'),
        titleTextStyle: AppTextStyles.heading.copyWith(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: AppTextStyles.subheading.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Abecedario ASL'),
            Tab(text: 'Gestos Especiales'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLettersTab(),
          _buildGesturesTab(),
        ],
      ),
    );
  }
}
