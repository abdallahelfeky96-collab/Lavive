import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:vegesea/cubits/get_sub_products_cubit/get_sub_products_cubit.dart';
import 'package:vegesea/layout/home/widgets/sub_categories_list.dart';
import 'package:vegesea/layout/product_screen/product_screen.dart';
import 'package:vegesea/models/one_product_model.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../shared/shared/app_localization.dart';
import '../../shared/shared/helper/quantity_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen(
      {required this.subNumber, super.key, required this.catID});
  final String subNumber;
  final int catID;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  Map<String, bool> favoriteStatusMap = {};
  Map<String, int> quantityMap = {};
  @override
  void initState() {
    BlocProvider.of<GetSubProductsCubit>(context)
        .getSubProducts(widget.subNumber);
    super.initState();
  }

  Future<void> _loadFavoriteStatus(String productID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteStatusMap[productID] =
          prefs.getBool('favorite_$productID') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final quantityProvider = Provider.of<QuantityProvider>(context);

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
      return BlocBuilder<GetSubProductsCubit, GetSubProductsState>(
        builder: (context, state) {
          if (state is GetSubProductsLoading) {
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
                    // Shimmer for Products Section
                    Expanded(
                      child: ListView.builder(
                        itemCount: 6, // Number of shimmer placeholders
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                EdgeInsets.all(constraints.maxWidth * 0.025),
                            child: Row(
                              children: [
                                // Image placeholder
                                Column(
                                  children: [
                                    Container(
                                      height: constraints.maxWidth * 0.26,
                                      width: constraints.maxWidth * 0.26,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      width: constraints.maxWidth * 0.26,
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              constraints.maxWidth * 0.025),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(16),
                                            bottomRight: Radius.circular(16)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: constraints.maxWidth * 0.08,
                                            height: constraints.maxWidth * 0.08,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            width: constraints.maxWidth * 0.08,
                                            height: constraints.maxWidth * 0.08,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: constraints.maxWidth * 0.025),
                                // Details placeholder
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: constraints.maxWidth * 0.5,
                                        height: constraints.maxHeight * 0.03,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                          height:
                                              constraints.maxHeight * 0.005),
                                      Row(
                                        children: [
                                          Container(
                                            width: constraints.maxWidth * 0.2,
                                            height:
                                                constraints.maxHeight * 0.02,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                              width:
                                                  constraints.maxWidth * 0.02),
                                          Container(
                                            width: constraints.maxWidth * 0.2,
                                            height:
                                                constraints.maxHeight * 0.02,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: constraints.maxWidth * 0.06,
                                            height: constraints.maxWidth * 0.06,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                              width:
                                                  constraints.maxWidth * 0.02),
                                          Expanded(
                                            child: Container(
                                              width: constraints.maxWidth * 0.3,
                                              height:
                                                  constraints.maxHeight * 0.02,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            width: constraints.maxWidth * 0.15,
                                            height: constraints.maxWidth * 0.15,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is GetSubProductsSuccess) {
            final subProducts = state.subProducts.data;
            final productsList = subProducts![1];

            return Scaffold(
              floatingActionButton: const MovableFloatingButton(),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: gridPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: maxHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: constraints.maxWidth * 0.08,
                            )),
                        const HomeButton(),
                      ],
                    ),
                    Expanded(
                        child: SubCategoriesList(
                            subNumber: widget.catID)), //logic تتشال
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: productsList.products!.length,
                        itemBuilder: (context, index) {
                          String productID =
                              productsList.products![index].id.toString();
                          _loadFavoriteStatus(productID);
                          double unitPrice = double.parse(
                              productsList.products![index].price!);
                          double quantity =
                              quantityProvider.getQuantity(productID);
                          double totalPrice = unitPrice * quantity;
                          return Card(
                            color: Colors.transparent,
                            elevation: 0,
                            margin: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth * 0.02,
                              vertical: constraints.maxWidth * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.025),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image & Quantity Control
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          navigateTo(
                                              context,
                                              ProductScreen(
                                                  productID: productID));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            height: constraints.maxWidth * 0.28,
                                            width: constraints.maxWidth * 0.28,
                                            decoration: BoxDecoration(
                                              //color: Colors.grey.shade50,
                                              border: Border.all(
                                                  color: Colors.grey.shade100),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: productsList
                                                      .products![index].photo ??
                                                  '',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 2)),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                          Icons.error_outline),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Quantity Selector
                                      Container(
                                        width: constraints.maxWidth * 0.28,
                                        height: constraints.maxWidth * 0.09,
                                        decoration: BoxDecoration(
                                          //color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => quantityProvider
                                                  .decreaseQuantity(productID),
                                              child: Container(
                                                width:
                                                    constraints.maxWidth * 0.06,
                                                height:
                                                    constraints.maxWidth * 0.06,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: kMainColor,
                                                ),
                                                child: const Icon(Icons.remove,
                                                    size: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    "${quantity.toInt()} ${AppLocalizations.of(context).isEnLocale ? (productsList.products![index].unit?.titleEn ?? "") : (productsList.products![index].unit?.titleAr ?? "")}",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: fontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                double currentQty =
                                                    quantityProvider
                                                        .getQuantity(productID);
                                                int availableStock =
                                                    productsList
                                                            .products?[index]
                                                            .amount ??
                                                        0;
                                                if (currentQty <
                                                    availableStock) {
                                                  quantityProvider
                                                      .increaseQuantity(
                                                          productID);
                                                } else {
                                                  showSnackBarMessage(
                                                    context,
                                                    '${AppLocalizations.of(context).translate("Maximum available")}: $availableStock',
                                                    Colors.red,
                                                    Icons.cancel,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width:
                                                    constraints.maxWidth * 0.06,
                                                height:
                                                    constraints.maxWidth * 0.06,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: kMainColor,
                                                ),
                                                child: const Icon(Icons.add,
                                                    size: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Product Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productsList
                                                  .products![index].myTitle ??
                                              'No title',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize:
                                                constraints.maxWidth * 0.042,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "LE ${totalPrice.toStringAsFixed(2)}",
                                              style: GoogleFonts.poppins(
                                                fontSize: constraints.maxWidth *
                                                    0.045,
                                                fontWeight: FontWeight.w700,
                                                color: kMainColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.amber,
                                                    size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "5.0",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: fontSize,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.check_circle,
                                                    size: 14,
                                                    color: Colors.green),
                                                const SizedBox(width: 4),
                                                Text(
                                                  AppLocalizations.of(context)
                                                      .translate("In Stock"),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: fontSize * 0.9,
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () => addToCart(
                                                context,
                                                productsList.products![index],
                                                quantity,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: kMainColor,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: kMainColor
                                                          .withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.shopping_cart_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is GetSubProductsFaluire) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/no-signal.png",
                      height: constraints.maxHeight * 0.15),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Text(
                    "There was an error please try again later or check your internet connection ❗",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: const Color(0xffF54D40),
                        fontSize: constraints.maxWidth * 0.045,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No products found'));
          }
        },
      );
    });
  }
}

void addToCart(BuildContext context, dynamic product, double quantity) async {
  bool isSignInDone = await SharedPreferences.getInstance()
      .then((prefs) => prefs.getBool("IsSignInDone") ?? false);

  if (!isSignInDone) {
    navigateTo(context, const ShopLoginScreen());
    return;
  }

  final cartProduct = ProductModel(
    status: true,
    data: Data(
      id: product.id,
      myTitle: product.myTitle,
      title: product.titleEn ?? product.myTitle,
      photo: product.photo,
      price: product.price,
      quantity: quantity,
      isPackaging: product.isPackaging ?? 0,
      amount: product.amount,
      packaging: product.packaging,
    ),
  );

  context.read<CartCubit>().addProduct(cartProduct);

  showSnackBarMessage(
      context,
      AppLocalizations.of(context).translate("added to cart"),
      Colors.green,
      Icons.check_circle);
}
