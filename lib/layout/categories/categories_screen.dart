// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vegesea/layout/categories/widgets/categories_grid.dart';
import 'package:vegesea/layout/root_view.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../shared/shared/app_localization.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: const MovableFloatingButton(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: height * 0.05),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      navigateAndFinish(context, const RootView());
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                    )),
                Text(
                  AppLocalizations.of(context).translate('categories'),
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Spacer(),
                const HomeButton(),
              ],
            ),
            const SizedBox(height: 5),
            SizedBox(height: height * 0.80, child: const CategoriesGrid())
          ],
        ),
      ),
    );
  }
}
