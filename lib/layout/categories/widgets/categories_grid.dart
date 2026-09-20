import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shimmer/shimmer.dart';
import 'package:vegesea/cubits/get_categories_cubit/get_categories_cubit.dart';

import 'package:vegesea/layout/home/widgets/sub_categories_grid.dart';

class CategoriesGrid extends StatefulWidget {
  const CategoriesGrid({super.key});

  @override
  State<CategoriesGrid> createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  @override
  void initState() {
    final cubit = BlocProvider.of<GetCategoriesCubit>(context);
    if (cubit.state is! GetCategoriesSuccess) {
      cubit.getCategories();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200
            ? 6
            : width > 800
                ? 4
                : width > 600
                    ? 3
                    : 2;
        final aspectRatio = width > 600 ? 1.2 : 0.9;

        return BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
          builder: (context, state) {
            if (state is GetCategoriesLoaging) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(constraints.maxWidth * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              );
            } else if (state is GetCategoriesSuccess) {
              final categories = state.categories.data;
              if (categories == null || categories.isEmpty) {
                return const Center(child: Text('No categories available'));
              }

              return GridView.builder(
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: aspectRatio,
                  crossAxisCount: crossAxisCount,
                ),
                itemBuilder: (context, index) {
                  int x = categories[index].id!;
                  String subName = categories[index].title!;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubCategoriesGrid(
                            subNumber: x,
                            subName: subName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(constraints.maxWidth * 0.02),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: CachedNetworkImage(
                              imageUrl: categories[index].photo ?? "",
                              errorWidget: (context, url, error) {
                                return Icon(Icons.error,
                                    size: constraints.maxWidth * 0.05);
                              },
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              categories[index].title!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: constraints.maxWidth * 0.03,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is GetCategoriesFaluire) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/no-signal.png",
                      height: constraints.maxHeight * 0.2,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      "There was an error please tryagain later or check your internet connection ❗",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xffF54D40),
                        fontSize: constraints.maxWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No categories found'));
            }
          },
        );
      },
    );
  }
}
