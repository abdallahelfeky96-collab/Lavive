import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:vegesea/cubits/get_one_product_cubit/get_one_product_cubit.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/models/favorite_models.dart' as favorites;
import 'package:vegesea/models/one_product_model.dart';
import 'package:vegesea/services/favorite_services.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../shared/shared/helper/quantity_provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, this.productID});

  final String? productID;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int? productNotificationIdFromNotisScreen;
  int? productNotificationID;
  String? theProductID;
  bool isVacuumPackaging = false;
  int isPackaging = 0; // Default packaging value (0 for no, 1 for yes)

  Future<void> determineProductID() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (widget.productID != null) {
        theProductID = widget.productID;
      } else if (prefs.containsKey('product_id_from_notis_screen')) {
        theProductID = prefs.getInt('product_id_from_notis_screen')?.toString();
      } else if (prefs.containsKey('product_id')) {
        theProductID = prefs.getInt('product_id')?.toString();
      } else {
        theProductID = null;
      }
    });

    if (theProductID != null) {
      triggerProductCubit();
    } else {
      print('Error: Unable to determine product ID.');
    }
  }

  void triggerProductCubit() {
    final cubit = BlocProvider.of<GetOneProductCubit>(context, listen: false);
    cubit.getOneProduct(theProductID!);
  }

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    determineProductID();
    removeProductNotificationID();
  }

  Future<void> updateFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
      prefs.setBool('favorite_$theProductID}', isFavorite);
    });
  }

  Future<void> removeProductNotificationID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('product_id');
  }

  void addToCart(Data product, double quantity,
      {String isPackaging = "0"}) async {
    bool isSignInDone = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getBool("IsSignInDone") ?? false);

    if (!isSignInDone) {
      navigateTo(context, const ShopLoginScreen());
      return;
    }

    // Calculate the total price including packaging if applicable
    double basePrice = double.parse(product.price!);
    double totalPrice = basePrice;
    if (isPackaging == "1") {
      totalPrice += double.parse(product.packaging!);
    }

    // Create a NEW Data object to avoid mutation
    final cartProduct = ProductModel(
      status: true,
      data: Data(
        id: product.id,
        title: product.title,
        myTitle: product.myTitle,
        photo: product.photo,
        price: totalPrice.toString(),
        quantity: quantity,
        amount: product.amount,
        isPackaging: int.parse(isPackaging),
        packaging: product.packaging,
        description: product.description,
        rate: product.rate,
        code: product.code,
        realPrice: product.realPrice,
      ),
    );

    context.read<CartCubit>().addProduct(cartProduct);

    showSnackBarMessage(
        context,
        AppLocalizations.of(context).translate("added to cart"),
        Colors.green,
        Icons.check);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final quantityProvider = Provider.of<QuantityProvider>(context);
    double quantity = quantityProvider.getQuantity(theProductID ?? "1");

    return BlocBuilder<GetOneProductCubit, GetOneProductState>(
      builder: (context, state) {
        if (state is GetOneProductLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is GetOneProductSuccess) {
          final product = state.product.data;
          favorites.AddToFavoriteModel favoriteProduct =
              favorites.AddToFavoriteModel(product_id: product!.id.toString());

          return Scaffold(
            floatingActionButton: const MovableFloatingButton(),
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: size.width * 0.1,
                  )),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    onPressed: () async {
                      bool? isSignInDone = false;

                      await SharedPreferences.getInstance().then((prefs) {
                        setState(() {
                          isSignInDone = prefs.getBool("IsSignInDone") ?? false;
                        });
                      });

                      if (isSignInDone == true) {
                        if (isFavorite) {
                          deleteFromFavoriteService(product.id!);
                        } else {
                          addToFavoriteService(favoriteProduct);
                        }

                        updateFavoriteStatus();
                      } else {
                        navigateTo(context, const ShopLoginScreen());
                      }
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: size.width * 0.085,
                      color: Colors.red,
                    ),
                  ),
                ),

                // SvgPicture.asset(
                //   "assets/images/home_icons/vertical_dots.svg",
                //   height: size.height * 0.035,
                //   color: Colors.white,
                // )
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                        height: size.height * 0.4,
                        decoration: const BoxDecoration(
                            //border: Border.all(color: Colors.grey.shade200),
                            ),
                        child: CachedNetworkImage(
                          imageUrl: product.photo!,
                          errorWidget: (context, url, error) {
                            return const Icon(Icons.error);
                          },
                        )),
                    Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(size.width * 0.055),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   product.subCategory?.title ?? "product",
                            //   style: GoogleFonts.lato(
                            //     textStyle: TextStyle(
                            //         color: const Color(0xff28B0CE),
                            //         fontSize: size.width * 0.055,
                            //         fontWeight: FontWeight.w700),
                            //   ),
                            // ),
                            // SizedBox(height: size.height * 0.005),
                            Text(
                              product.title!,
                              style: TextStyle(
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: size.height * 0.007),
                            Text(
                              product.description ?? "",
                              style: TextStyle(fontSize: size.width * 0.035),
                            ),
                            SizedBox(height: size.height * 0.015),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/images/star.svg'),
                                    Text(
                                      '   ${product.rate} (89 reviews)',
                                      style: TextStyle(
                                          fontSize: size.width * 0.035,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(width: size.width * 0.12),
                                // Row(
                                //   children: [
                                //     SvgPicture.asset('assets/images/van.svg'),
                                //     Text(
                                //       AppLocalizations.of(context)
                                //           .translate("free delivery"),
                                //       style: TextStyle(
                                //           color: Colors.green,
                                //           fontWeight: FontWeight.bold,
                                //           fontSize: size.width * 0.035),
                                //     )
                                //   ],
                                // ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.02),
                            Text(
                              AppLocalizations.of(context).translate("price"),
                              style: TextStyle(fontSize: size.width * 0.04),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isPackaging == 1
                                      ? "${double.parse(product.price!) + double.parse(product.packaging!)}"
                                      : "${double.parse(product.price!)}",
                                  style: TextStyle(
                                    fontSize: size.width * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.025),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => quantityProvider
                                            .decreaseQuantity(theProductID!),
                                        child: Icon(
                                          Icons.remove,
                                          size: size.width * 0.06,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Text(
                                        '${quantity.toInt()} ${AppLocalizations.of(context).isEnLocale ? (product.unit?.titleEn ?? product.unit?.title ?? "Kg") : (product.unit?.titleAr ?? product.unit?.myTitle ?? "كج")}',
                                        style: TextStyle(
                                            fontSize: size.width * 0.05,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Container(
                                        height: size.width * 0.085,
                                        width: size.width * 0.085,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Color(0xFFC8EDD9),
                                        ),
                                        child: GestureDetector(
                                            onTap: () {
                                              double currentQty =
                                                  quantityProvider.getQuantity(
                                                      theProductID!);
                                              int availableStock =
                                                  product.amount ?? 0;

                                              if (currentQty < availableStock) {
                                                quantityProvider
                                                    .increaseQuantity(
                                                        theProductID!);
                                              } else {
                                                showSnackBarMessage(
                                                    context,
                                                    '${AppLocalizations.of(context).translate("Maximum available")}: $availableStock',
                                                    Colors.red,
                                                    Icons.cancel);
                                              }
                                            },
                                            child: Icon(Icons.add,
                                                color: Colors.green,
                                                size: size.width * 0.06)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.012),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isPackaging == 1,
                                  onChanged: (double.tryParse(
                                                  product.packaging ?? '0') ??
                                              0) ==
                                          0
                                      ? null
                                      : (value) {
                                          setState(() {
                                            isPackaging = value! ? 1 : 0;
                                            log("$isPackaging");
                                          });
                                        },
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                      .translate("Vacuum Packaging"),
                                  style:
                                      TextStyle(fontSize: size.width * 0.035),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.012),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  (product.amount ?? 0) > 0
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: (product.amount ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  (product.amount ?? 0) > 0
                                      ? AppLocalizations.of(context)
                                          .translate("In Stock")
                                      : AppLocalizations.of(context)
                                          .translate("Out of Stock"),
                                  style: TextStyle(
                                    color: (product.amount ?? 0) > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            defaultButton(
                              icon: Icon(
                                size: size.width * 0.065,
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                              function: (product.amount ?? 0) <= 0
                                  ? () {
                                      showSnackBarMessage(
                                          context,
                                          AppLocalizations.of(context).translate(
                                              "This product is out of stock"),
                                          Colors.red,
                                          Icons.cancel);
                                    }
                                  : () {
                                      if (quantity > (product.amount ?? 0)) {
                                        showSnackBarMessage(
                                            context,
                                            '${AppLocalizations.of(context).translate("Only")} ${product.amount} ${AppLocalizations.of(context).translate("available")}',
                                            Colors.red,
                                            Icons.cancel);

                                        return;
                                      }
                                      addToCart(product, quantity,
                                          isPackaging: isPackaging.toString());
                                      log("quantity==>>>$quantity");
                                      log("price==>>>${product.price}");
                                    },
                              text: (product.amount ?? 0) <= 0
                                  ? AppLocalizations.of(context)
                                      .translate("Out of Stock")
                                  : AppLocalizations.of(context)
                                      .translate("add to cart"),
                              textColor: (product.amount ?? 0) <= 0
                                  ? Colors.grey
                                  : Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is GetOneProductFaluire) {
          return Center(child: Text(state.errMessage));
        } else {
          return const Center(
            child: Text('Unexpected state'),
          );
        }
      },
    );
  }
}
