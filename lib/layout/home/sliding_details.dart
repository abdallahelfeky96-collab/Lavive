import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vegesea/models/banners_model.dart' as banner_model;
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import 'package:vegesea/shared/shared/helper/quantity_provider.dart';

import 'package:vegesea/models/one_product_model.dart' as product_model;
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlidingDetails extends StatefulWidget {
  final banner_model.Data banner;

  const SlidingDetails({super.key, required this.banner});

  @override
  State<SlidingDetails> createState() => _SlidingDetailsState();
}

class _SlidingDetailsState extends State<SlidingDetails> {
  int isPackaging = 0;

  void addToCart(banner_model.Data banner, double quantity,
      {String isPackaging = "0"}) async {
    bool isSignInDone = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getBool("IsSignInDone") ?? false);

    if (!isSignInDone) {
      navigateTo(context, const ShopLoginScreen());
      return;
    }

    // Calculate the total price including packaging if applicable
    double basePrice = double.tryParse(banner.price ?? "0") ?? 0;
    double totalPrice = basePrice;
    if (isPackaging == "1") {
      totalPrice += double.tryParse(banner.packaging ?? "0") ?? 0;
    }

    // Create a NEW ProductModel object
    final cartProduct = product_model.ProductModel(
      status: true,
      data: product_model.Data(
        id: banner.id,
        title: banner.myTitle ?? banner.titleEn,
        myTitle: banner.myTitle,
        photo: banner.photo,
        price: totalPrice.toString(),
        quantity: quantity,
        amount: 100, // Assuming a large enough amount if not specified
        isPackaging: int.parse(isPackaging),
        packaging: banner.packaging,
        description: banner.myDescription ?? banner.descriptionEn,
        rate: banner.rate,
        unit: banner.unit,
        // code: banner.code, // Code isn't in banner model
        // realPrice: banner.realPrice,
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
    double quantity = quantityProvider.getQuantity(widget.banner.id.toString());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: size.width * 0.1,
          ),
        ),
        actions: const [
          HomeButton(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Hero(
                  tag: 'banner_${widget.banner.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.banner.photo ?? "",
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) {
                      return const Icon(Icons.error);
                    },
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                  ),
                ),
              ),
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
                      Text(
                        widget.banner.myTitle ?? widget.banner.titleEn ?? "",
                        style: TextStyle(
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: size.height * 0.007),
                      Text(
                        widget.banner.myDescription ??
                            widget.banner.descriptionEn ??
                            "",
                        style: TextStyle(fontSize: size.width * 0.035),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Row(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset('assets/images/star.svg'),
                              Text(
                                '   ${widget.banner.rate ?? 5} (89 reviews)',
                                style: TextStyle(
                                    fontSize: size.width * 0.035,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(width: size.width * 0.12),
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
                                ? "${(double.tryParse(widget.banner.price ?? "0") ?? 0) + (double.tryParse(widget.banner.packaging ?? "0") ?? 0)}"
                                : widget.banner.price ?? "0",
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      quantityProvider.decreaseQuantity(
                                          widget.banner.id.toString()),
                                  child: Icon(
                                    Icons.remove,
                                    size: size.width * 0.06,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.04),
                                Text(
                                  '${quantity.toInt()} ${AppLocalizations.of(context).isEnLocale ? (widget.banner.unit?.titleEn ?? widget.banner.unit?.title ?? "Kg") : (widget.banner.unit?.titleAr ?? widget.banner.unit?.myTitle ?? "كج")}',
                                  style: TextStyle(
                                      fontSize: size.width * 0.05,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: size.width * 0.04),
                                Container(
                                  height: size.width * 0.085,
                                  width: size.width * 0.085,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    color: Color(0xFFC8EDD9),
                                  ),
                                  child: GestureDetector(
                                      onTap: () {
                                        quantityProvider.increaseQuantity(
                                            widget.banner.id.toString());
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
                            onChanged: (value) {
                              setState(() {
                                isPackaging = value! ? 1 : 0;
                                log("$isPackaging");
                              });
                            },
                          ),
                          Text(
                            AppLocalizations.of(context)
                                .translate("Vacuum Packaging"),
                            style: TextStyle(fontSize: size.width * 0.035),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.012),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            (widget.banner.id ?? 0) > 0
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: (widget.banner.id ?? 0) > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          SizedBox(width: size.width * 0.01),
                          Text(
                            (widget.banner.id ?? 0) > 0
                                ? AppLocalizations.of(context)
                                    .translate("In Stock")
                                : AppLocalizations.of(context)
                                    .translate("Out of Stock"),
                            style: TextStyle(
                              color: (widget.banner.id ?? 0) > 0
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
                        function: (widget.banner.id ?? 0) <= 0
                            ? () {
                                showSnackBarMessage(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        "This product is out of stock"),
                                    Colors.red,
                                    Icons.cancel);
                              }
                            : () {
                                addToCart(widget.banner, quantity,
                                    isPackaging: isPackaging.toString());
                              },
                        text: (widget.banner.id ?? 0) <= 0
                            ? AppLocalizations.of(context)
                                .translate("Out of Stock")
                            : AppLocalizations.of(context)
                                .translate("add to cart"),
                        textColor: (widget.banner.id ?? 0) <= 0
                            ? Colors.grey
                            : Colors.white,
                      ),
                      if (widget.banner.link != null &&
                          widget.banner.link.toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: defaultButton(
                            function: () async {
                              final Uri url =
                                  Uri.parse(widget.banner.link.toString());
                              try {
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  showSnackBarMessage(
                                      context,
                                      "Could not launch link",
                                      Colors.red,
                                      Icons.error);
                                }
                              } catch (e) {
                                showSnackBarMessage(
                                    context,
                                    "Invalid link format",
                                    Colors.red,
                                    Icons.error);
                              }
                            },
                            text: "View More",
                            textColor: Colors.white,
                          ),
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
  }
}
