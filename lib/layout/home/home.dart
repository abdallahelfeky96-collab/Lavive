import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/all_products_cubit/all_products_cubit.dart';
import 'package:vegesea/cubits/search_cubit/search_cubit.dart';
import 'package:vegesea/layout/categories/categories_screen.dart';
import 'package:vegesea/layout/home/widgets/categories_list.dart';
import 'package:vegesea/layout/home/widgets/noti_icon.dart';
import 'package:vegesea/layout/home/widgets/popular_deals_grid.dart';
import 'package:vegesea/layout/home/widgets/sliding_item.dart';
import 'package:vegesea/layout/notifications_screen/notifications_screen.dart';
import 'package:vegesea/layout/search/search_screen.dart';
import 'package:vegesea/shared/shared/app_localization.dart';

import '../../shared/shared/components/components.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    context.read<AllProductsCubit>().getAllProducts();
    super.initState();
  }

  String? name;

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((value) {
      if (mounted) {
        setState(() {
          name = value.getString("name");
        });
      }
    });

    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Light green background from screenshot
      floatingActionButton: const MovableFloatingButton(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello 👋',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        name ?? 'Guest',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: screenWidth * 0.07,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      navigateTo(context, const NotificationsScreen());
                    },
                    child: const NotiIcon(),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              // Search Bar
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final allProductsState =
                            context.read<AllProductsCubit>().state;
                        if (allProductsState is AllProductsSuccess) {
                          return BlocProvider(
                            create: (context) => SearchCubit(
                              products:
                                  allProductsState.allProductsModel.data,
                            ),
                            child: const SearchScreen(),
                          );
                        }
                        return const Center(
                            child: Text('No products available.'));
                      },
                    ),
                  );
                },
                child: Container(
                  height: screenHeight * 0.07,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFF3), // Light gray background
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: const Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Search beverages or foods',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Banner/Slider
              SizedBox(
                height: screenHeight * 0.22,
                child: const SlidingItem(),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('categories'),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: screenWidth * 0.055,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      navigateAndFinish(context, const CategoriesPage());
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                      size: 35,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              const CategoriesList(
                scrollDirection: Axis.vertical,
              ),
              SizedBox(height: screenHeight * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).translate('popular deals'),
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              const PopularDealsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
