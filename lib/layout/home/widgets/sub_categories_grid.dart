import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import 'package:vegesea/layout/all_products/products_screen.dart';
import 'package:vegesea/layout/home/widgets/popular_deals_grid.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vegesea/shared/shared/constants.dart';

import '../../../shared/shared/app_localization.dart';
import '../../../shared/shared/helper/quantity_provider.dart';
import '../../product_screen/product_screen.dart';

class SubCategoriesGrid extends StatefulWidget {
  const SubCategoriesGrid({this.subNumber, this.subName, super.key});

  final int? subNumber;
  final String? subName;

  @override
  State<SubCategoriesGrid> createState() => _SubCategoriesGridState();
}

class _SubCategoriesGridState extends State<SubCategoriesGrid> {
  int? theCategoryNumber;

  Future<void> determineCategoryNumber() async {
    final prefs = await SharedPreferences.getInstance();

    // Check arguments from ModalRoute (passed from notifications)
    final args = ModalRoute.of(context)?.settings.arguments;
    log("Checking category details arguments: $args");

    setState(() {
      if (widget.subNumber != null) {
        theCategoryNumber = widget.subNumber;
      } else if (args is int) {
        theCategoryNumber = args;
      } else if (prefs.containsKey('category_id_from_notis_screen')) {
        theCategoryNumber = prefs.getInt('category_id_from_notis_screen');
      } else if (prefs.containsKey('category_id')) {
        theCategoryNumber = prefs.getInt('category_id');
      } else {
        theCategoryNumber = null;
      }
    });

    if (theCategoryNumber != null) {
      log("Category ID determined: $theCategoryNumber");
      triggerCategoriesCubit();
    } else {
      log('Error: Unable to determine category number.');
    }
  }

  void triggerCategoriesCubit() {
    BlocProvider.of<GetSubCategoriesCubit>(context)
        .getSubCategoreis(theCategoryNumber!);
  }

  @override
  void initState() {
    determineCategoryNumber();
    removeCategoryNotificationID();
    log("token===>>$token");
    super.initState();
  }

  Future<void> removeCategoryNotificationID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('category_id');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.of(context).size;
        final screenHeight = screenSize.height;
        final screenWidth = screenSize.width;

        final crossAxisCountProducts = screenSize.width < 600
            ? 2
            : screenSize.width < 1200
                ? 3
                : 4;
        final childAspectRatio = screenSize.width < 600 ? 0.65 : 0.85;
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
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gridPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: iconSize,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: maxWidth * 0.4,
                            height: titleFontSize,
                            color: Colors.grey,
                          ),
                          const Spacer(),
                          const HomeButton(),
                        ],
                      ),
                      SizedBox(height: maxHeight * 0.02),
                      // Shimmer for Sub Categories Section
                      SizedBox(
                        height: maxHeight * 0.2,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return CircleAvatar(
                              radius: maxWidth * 0.12,
                              backgroundColor: Colors.grey.shade300,
                              child: Container(),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.02),
                      // Shimmer for Products Section
                      Expanded(
                        child: GridView.builder(
                          itemCount: 6,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCountProducts,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: screenSize.width * 0.02,
                            mainAxisSpacing: screenSize.width * 0.02,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is GetSubCategoriesSuccess) {
              final subCategories = state.subCategories.data!.subCategories;
              final products = state.subCategories.data!.products;
              final catID = state.subCategories.data!.id;

              if (subCategories!.isEmpty) {
                return Scaffold(
                  floatingActionButton: const MovableFloatingButton(),
                  appBar: AppBar(),
                  body: const Center(
                    child: Text('No subcategories available at the moment'),
                  ),
                );
              }

              return Scaffold(
                floatingActionButton: const MovableFloatingButton(),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: gridPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: maxHeight * 0.05),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: iconSize,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.subName ?? "",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: titleFontSize,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const HomeButton(),
                        ],
                      ),
                      SizedBox(height: maxHeight * 0.02),

                      /// Sub Categories Section
                      SizedBox(
                        height: maxHeight * 0.2,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: subCategories.length,
                          // gridDelegate:
                          //     SliverGridDelegateWithFixedCrossAxisCount(
                          //   crossAxisCount: crossAxisCount,
                          //   childAspectRatio: 1,
                          //   crossAxisSpacing: gridPadding,
                          //   mainAxisSpacing: gridPadding,
                          // ),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  navigateTo(
                                    context,
                                    ProductsScreen(
                                      subNumber:
                                          subCategories[index].id.toString(),
                                      catID: catID!,
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    //color: caterogyItem[index].color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: maxWidth * 0.12,
                                          backgroundColor: Colors.grey.shade300,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: subCategories[index]
                                                      .photo
                                                      .toString() ??
                                                  '',
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.blueAccent,
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
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
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: maxHeight * 0.02),

                      /// Products Section
                      if (products != null && products.isNotEmpty)
                        Expanded(
                          flex: 3,
                          child: Consumer<QuantityProvider>(
                            builder: (context, quantityProvider, child) {
                              return GridView.builder(
                                itemCount: products.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCountProducts,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: screenSize.width * 0.02,
                                  mainAxisSpacing: screenSize.width * 0.02,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  String productId = product.id.toString();

                                  return InkWell(
                                    onTap: () {
                                      navigateTo(
                                        context,
                                        ProductScreen(
                                            productID: product.id!.toString()),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(containerPadding),
                                      padding: EdgeInsets.all(containerPadding),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.myTitle ?? "No Title",
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: fontSize * 1.2,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Expanded(child: SizedBox()),
                                          Expanded(
                                            flex: 5,
                                            child: CachedNetworkImage(
                                              imageUrl: product.photo ?? '',
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "L.E ${product.price?.toString() ?? 'No Price'}",
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: fontSize * 1.1,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    product.rate?.toString() ??
                                                        "5",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: fontSize),
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                    size: iconSize,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenSize.height * 0.01),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  quantityProvider
                                                      .decreaseQuantity(
                                                          productId);
                                                },
                                                child: Container(
                                                  width:
                                                      screenSize.width * 0.08,
                                                  height:
                                                      screenSize.width * 0.08,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: kMainColor,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: iconSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              AppLocalizations.of(context)
                                                          .locale
                                                          .languageCode ==
                                                      "ar"
                                                  ? Text(
                                                      "${quantityProvider.getQuantity(productId).toInt()} ${product.unit?.titleAr ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      "${quantityProvider.getQuantity(productId).toInt()} ${product.unit?.titleEn ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              GestureDetector(
                                                onTap: () {
                                                  double currentQty =
                                                      quantityProvider
                                                          .getQuantity(
                                                              productId);
                                                  int availableStock = product
                                                          .amount ??
                                                      0; // Use appropriate product reference

                                                  if (currentQty <
                                                      availableStock) {
                                                    quantityProvider
                                                        .increaseQuantity(
                                                            productId);
                                                  } else {
                                                    showSnackBarMessage(
                                                        context,
                                                        '${AppLocalizations.of(context).translate("Maximum available")}: $availableStock',
                                                        Colors.red,
                                                        Icons.cancel);
                                                  }
                                                },
                                                child: Container(
                                                  width:
                                                      screenSize.width * 0.08,
                                                  height:
                                                      screenSize.width * 0.08,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: kMainColor,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: iconSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                (product.amount ?? 0) > 0
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size: fontSize * 0.9,
                                                color: (product.amount ?? 0) > 0
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              SizedBox(
                                                  width:
                                                      screenSize.width * 0.01),
                                              Text(
                                                (product.amount ?? 0) > 0
                                                    ? AppLocalizations.of(
                                                            context)
                                                        .translate("In Stock")
                                                    : AppLocalizations.of(
                                                            context)
                                                        .translate(
                                                            "Out of Stock"),
                                                style: TextStyle(
                                                  fontSize: fontSize * 0.9,
                                                  color:
                                                      (product.amount ?? 0) > 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: screenSize.height * 0.01),
                                          buildAddToCartButton(
                                              context, product),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            } else if (state is GetSubCategoriesFaluire) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/no-signal.png",
                      height: maxHeight * 0.15,
                    ),
                    SizedBox(height: maxHeight * 0.02),
                    Text(
                      "There was an error please try again later or check your internet connection ❗",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xffF54D40),
                        fontSize: subtitleFontSize,
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
