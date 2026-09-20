
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vegesea/cubits/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import 'package:vegesea/layout/all_products/products_screen.dart';
import 'package:vegesea/shared/shared/components/components.dart';
// Import Shimmer
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage

class SubCategoriesList extends StatefulWidget {
  const SubCategoriesList({super.key, required this.subNumber, this.subName});

  final int subNumber;
  final String? subName;

  @override
  State<SubCategoriesList> createState() => _SubCategoriesListState();
}

class _SubCategoriesListState extends State<SubCategoriesList> {
  @override
  void initState() {
    BlocProvider.of<GetSubCategoriesCubit>(context)
        .getSubCategoreis(widget.subNumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;
      final screenSize = MediaQuery.of(context).size;
      final screenHeight = screenSize.height;
      final screenWidth = screenSize.width;

      final crossAxisCountProducts = screenSize.width < 600
          ? 2
          : screenSize.width < 1200
              ? 3
              : 4;
      final childAspectRatio = screenSize.width < 600 ? 0.75 : 0.85;
      //final iconSizeProduct = screenSize.width * 0.04;
      final fontSize = screenSize.width * 0.035;
      final containerPadding = screenSize.width * 0.02;

      final double maxWidth = constraints.maxWidth;
      final double maxHeight = constraints.maxHeight;

      // Calculate responsive values
      final double gridPadding = maxWidth * 0.04;
      final double iconSize = maxWidth * 0.08;
      final double titleFontSize = maxWidth * 0.06;
      final double subtitleFontSize = maxWidth * 0.045;
      final int crossAxisCount = maxWidth < 600
          ? 2
          : maxWidth < 900
              ? 3
              : 4;
      final double imageHeight = maxHeight * 0.15;
      return BlocBuilder<GetSubCategoriesCubit, GetSubCategoriesState>(
        builder: (context, state) {
          if (state is GetSubCategoriesLoading) {
            // استخدام Shimmer بدلاً من مؤشر التحميل
            return const SizedBox();
          } else if (state is GetSubCategoriesSuccess) {
            final subCategories = state.subCategories.data!.subCategories;
            final catID = state.subCategories.data!.id;
            if (subCategories!.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text('No subcategories available at the moment'),
                ),
              );
            }

            return Scaffold(
              body: SizedBox(
                height: height * 0.25,
                // width: width * 0.5,
                child: ListView.builder(
                  itemCount: subCategories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        navigateTo(
                            context,
                            ProductsScreen(
                              subNumber: subCategories[index].id.toString(),
                              catID: catID!,
                            ));
                      },
                      child: Container(
                        width: maxWidth * 0.3,

                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          //color: caterogyItem[index].color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: maxWidth * 0.12,
                                backgroundColor: Colors.grey.shade300,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        subCategories[index].photo.toString() ??
                                            '',
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blueAccent,
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      size: maxWidth * 0.12,
                                      color: Colors.grey,
                                    ),
                                    width: maxWidth * 0.12 * 2,
                                    height: maxWidth * 0.12 * 2,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: maxHeight * 0.01),
                              Text(
                                subCategories[index].myTitle!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  //color: Colors.white,
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (state is GetSubCategoriesFaluire) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/no-signal.png", height: 100),
                  const SizedBox(
                    height: 16,
                  ),
                  const Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "There was an error please try again later or check your internet connection ❗",
                      style: TextStyle(
                          color: Color(0xffF54D40),
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
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
    });
  }
}
