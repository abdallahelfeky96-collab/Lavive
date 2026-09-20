import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import '../../cubits/favorites_cubit/favorites_cubit.dart';
import '../../shared/shared/app_localization.dart';
import '../../shared/shared/constants.dart';
import '../../shared/shared/helper/quantity_provider.dart';
import '../../services/favorite_services.dart';
import '../Auth/login.dart';
import '../Auth/register.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    BlocProvider.of<FavoritesCubit>(context).getAllFavorites();
    log("token===>>$token");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final quantityProvider = Provider.of<QuantityProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return token != null
        ? BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              if (state is FavoritesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FavoritesSuccess) {
                final favProducts = state.favorites.data;

                return Scaffold(
                    floatingActionButton: const MovableFloatingButton(),
                    appBar: AppBar(
                      title: const Text('Favorites'),
                      // actions: const [
                      //   HomeButton(),
                      // ],
                      centerTitle: true,
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: favProducts!.isNotEmpty
                          ? ListView.builder(
                              itemCount: favProducts.length,
                              itemBuilder: (context, index) {
                                final product = favProducts[index];
                                final productID = product.id.toString();
                                final basePrice =
                                    double.parse(product.price ?? '0.0');
                                final quantity =
                                    quantityProvider.getQuantity(productID);
                                final totalPrice = basePrice * quantity;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 12.0),
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: product.photo!,
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error, size: 80),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.myTitle ??
                                                    'Unknown Product',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.lato(
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '$totalPrice LE',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await deleteFromFavoriteService(
                                                int.parse(productID));
                                            await BlocProvider.of<
                                                    FavoritesCubit>(context)
                                                .getAllFavorites();
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No favorite products found.'),
                            ),
                    ));
              } else if (state is FavoritesFailure) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
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
                  ),
                );
              } else {
                return const Center(
                  child: Text('No favorite products found.'),
                );
              }
            },
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Favorites'),
              actions: const [
                HomeButton(),
              ],
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    defaultButton(
                      height: screenHeight * 0.059,
                      width: screenWidth * 0.5,
                      function: () async {
                        navigateTo(context, const ShopLoginScreen());
                      },
                      text: AppLocalizations.of(context).translate("login"),
                      isUpperCase: true,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    SizedBox(
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.055,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: kMainColor),
                            borderRadius: BorderRadius.circular(
                                CupertinoContextMenu.kOpenBorderRadius),
                          ),
                          child: TextButton(
                              onPressed: () {
                                navigateTo(context, const ShopRegisterScreen());
                              },
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate("create account"),
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        color: kMainColor,
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ))),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
