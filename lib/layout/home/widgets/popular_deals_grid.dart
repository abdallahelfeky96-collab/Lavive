import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:vegesea/cubits/get_popular_deals_cubit/get_popular_deals_cubit.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/layout/product_screen/product_screen.dart';
import 'package:vegesea/models/one_product_model.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../../shared/shared/helper/quantity_provider.dart';

class PopularDealsGrid extends StatefulWidget {
  const PopularDealsGrid({super.key});

  @override
  State<PopularDealsGrid> createState() => _PopularDealsGridState();
}

class _PopularDealsGridState extends State<PopularDealsGrid> {
  List<bool> addedToFavorites = [];
  Map<String, int> itemQuantities = {};

  @override
  void initState() {
    super.initState();
    final cubit = BlocProvider.of<GetPopularDealsCubit>(context);
    if (cubit.state is! GetPopularDealsSuccess) {
      cubit.getPopularDeals();
    }
  }

  Future<void> _loadFavoriteStatus(List<dynamic> popularDeals) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      addedToFavorites = List<bool>.generate(
        popularDeals.length,
        (index) => prefs.getBool('favorite_${popularDeals[index].id}') ?? false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final crossAxisCount = screenSize.width < 600
        ? 2
        : screenSize.width < 1200
            ? 3
            : 4;
    final childAspectRatio = screenSize.width < 600 ? 0.65 : 0.85;
    final iconSize = screenSize.width * 0.04;
    final fontSize = screenSize.width * 0.035;
    final containerPadding = screenSize.width * 0.02;

    return BlocBuilder<GetPopularDealsCubit, GetPopularDealsState>(
      builder: (context, state) {
        if (state is GetPopularDealsLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: crossAxisCount,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: childAspectRatio,
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: screenSize.width * 0.02,
                mainAxisSpacing: screenSize.width * 0.02,
              ),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(containerPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                );
              },
            ),
          );
        } else if (state is GetPopularDealsFaluire) {
          // return Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Image.asset("assets/images/no-signal.png",
          //           height: screenSize.height * 0.15),
          //       SizedBox(height: screenSize.height * 0.02),
          //       Text(
          //         "There was an error please tryagain later or check your internet connection ❗",
          //         textAlign: TextAlign.center,
          //         style: TextStyle(
          //             color: const Color(0xffF54D40),
          //             fontSize: fontSize,
          //             fontWeight: FontWeight.w500),
          //       ),
          //     ],
          //   ),
          // );
          return const SizedBox();
        } else if (state is GetPopularDealsSuccess) {
          final popularDeals = state.popularDeals.data;

          if (popularDeals == null || popularDeals.isEmpty) {
            return Center(
              child: Text(
                'No popular deals available',
                style: TextStyle(fontSize: fontSize),
              ),
            );
          }

          if (addedToFavorites.isEmpty) {
            _loadFavoriteStatus(popularDeals);
          }

          return Consumer<QuantityProvider>(
            builder: (context, quantityProvider, child) {
              return GridView.builder(
                itemCount: popularDeals.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: childAspectRatio,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: screenSize.width * 0.02,
                  mainAxisSpacing: screenSize.width * 0.02,
                ),
                itemBuilder: (context, index) {
                  final deals = popularDeals[index];
                  String productId = deals.id.toString();

                  return InkWell(
                    onTap: () {
                      navigateTo(context,
                          ProductScreen(productID: deals.id!.toString()));
                    },
                    child: Container(
                      margin: EdgeInsets.all(containerPadding),
                      padding: EdgeInsets.all(containerPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(width: 1, color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  deals.myTitle ?? "No Title",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: fontSize * 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          //const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 50,
                            child: CachedNetworkImage(
                              imageUrl: deals.photo ?? '',
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${deals.price?.toString() ?? 'No Price'} L.E",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: fontSize * 1.1,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    deals.rate?.toString() ?? "No Rate",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: fontSize),
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
                          SizedBox(height: screenSize.height * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  quantityProvider.decreaseQuantity(productId);
                                },
                                child: Container(
                                  width: screenSize.width * 0.08,
                                  height: screenSize.width * 0.08,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
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
                                      "${quantityProvider.getQuantity(productId).toInt()} ${deals.unit?.titleAr ?? 'كج'}",
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      "${quantityProvider.getQuantity(productId).toInt()} ${deals.unit?.titleEn ?? 'Kg'}",
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              GestureDetector(
                                onTap: () {
                                  double currentQty =
                                      quantityProvider.getQuantity(productId);
                                  int availableStock = deals.amount ?? 0;

                                  if (currentQty < availableStock) {
                                    quantityProvider
                                        .increaseQuantity(productId);
                                  } else {
                                    showSnackBarMessage(
                                        context,
                                        '${AppLocalizations.of(context).translate("Maximum available")}: $availableStock',
                                        Colors.red,
                                        Icons.cancel);
                                  }
                                },
                                child: Container(
                                  width: screenSize.width * 0.08,
                                  height: screenSize.width * 0.08,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                (deals.amount ?? 0) > 0
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: fontSize * 0.9,
                                color: (deals.amount ?? 0) > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              SizedBox(width: screenSize.width * 0.01),
                              Text(
                                (deals.amount ?? 0) > 0
                                    ? AppLocalizations.of(context)
                                        .translate("In Stock")
                                    : AppLocalizations.of(context)
                                        .translate("Out of Stock"),
                                style: TextStyle(
                                  fontSize: fontSize * 0.9,
                                  color: (deals.amount ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          buildAddToCartButton(context, deals),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }

        return Center(
          child: Text(
            "Something went wrong!",
            style: TextStyle(fontSize: fontSize),
          ),
        );
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({super.key});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(screenSize.width * 0.015),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xffC8EDD9),
      ),
      child: Text(
        "Add to cart",
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
          fontSize: screenSize.width * 0.035,
        ),
      ),
    );
  }
}

Widget buildAddToCartButton(BuildContext context, dynamic deals) {
  final screenSize = MediaQuery.of(context).size;
  final quantityProvider = Provider.of<QuantityProvider>(context);
  String productId = deals.id.toString();
  double quantity = quantityProvider.getQuantity(productId);
  int availableStock = deals.amount ?? 0;
  bool isOutOfStock = availableStock <= 0;

  ProductModel product = ProductModel(
    status: true,
    data: Data(
      id: deals.id,
      title: deals.titleEn,
      myTitle: deals.myTitle,
      photo: deals.photo,
      price: deals.price,
      quantity: quantity,
      amount: availableStock,
      isPackaging: deals.isPackaging ?? 0,
      packaging: deals.packaging,
    ),
  );

  return GestureDetector(
    onTap: isOutOfStock
        ? () {
            showSnackBarMessage(
                context,
                AppLocalizations.of(context)
                    .translate("This product is out of stock"),
                Colors.red,
                Icons.error_outline);
          }
        : () async {
            bool isSignInDone = await SharedPreferences.getInstance()
                .then((prefs) => prefs.getBool("IsSignInDone") ?? false);

            if (!isSignInDone) {
              navigateTo(context, const ShopLoginScreen());
              return;
            }

            if (quantity > availableStock) {
              showSnackBarMessage(
                  context,
                  '${AppLocalizations.of(context).translate("Only")} $availableStock ${AppLocalizations.of(context).translate("available")}',
                  Colors.orange,
                  Icons.warning_amber_rounded);
              return;
            }

            context.read<CartCubit>().addProduct(product);
            showSnackBarMessage(
                context,
                AppLocalizations.of(context).translate("added to cart"),
                Colors.green,
                Icons.check);
          },
    child: Container(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.008),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isOutOfStock ? Colors.grey : kMainColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.shopping_cart,
            color: Colors.white,
            size: screenSize.width * 0.06,
          ),
          Text(
            isOutOfStock
                ? AppLocalizations.of(context).translate("Out of Stock")
                : AppLocalizations.of(context).translate("add to cart"),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: screenSize.width * 0.035,
            ),
          ),
        ],
      ),
    ),
  );
}
