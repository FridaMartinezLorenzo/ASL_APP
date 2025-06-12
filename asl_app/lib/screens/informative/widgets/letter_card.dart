import 'package:flutter/material.dart';
import 'package:asl_app/models/letter_info.dart';
import 'package:asl_app/screens/informative/letters_details_screen.dart'; // Asegúrate de tener esta pantalla creada
import 'package:asl_app/themes/app_colors.dart';
import 'package:asl_app/themes/app_text_styles.dart';

class LetterCard extends StatelessWidget {
  final LetterInfo info;

  const LetterCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(info: info),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                info.letter,
                style: AppTextStyles.heading.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Image.asset(
                info.imagePath,
                height: 100,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
