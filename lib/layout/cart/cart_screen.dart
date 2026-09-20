import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:vegesea/cubits/all_products_cubit/all_products_cubit.dart';
import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
import 'package:vegesea/layout/cart/success_view.dart';
import 'package:vegesea/models/all_products_model.dart' hide Data;
import 'package:vegesea/layout/orders/orders_screen.dart';
import 'package:vegesea/layout/orders/shipping_address_screen.dart';
import 'package:vegesea/layout/orders/webview_screen.dart';
import 'package:vegesea/models/get_all_addresses_model.dart' hide Data;
import 'package:vegesea/services/address_services.dart';
import 'package:vegesea/services/deep_link_service.dart';
import 'package:vegesea/services/marketing_service.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import 'package:vegesea/shared/shared/constants.dart';
import 'dart:convert';
import '../../cubits/wallet_cubit/wallet_cubit.dart';
import '../../cubits/wallet_cubit/wallet_state.dart';
import '../../models/one_product_model.dart';
import '../../models/promo_code_model.dart';
import '../../services/promo_code_services.dart';
import '../../shared/shared/Network/end_points.dart';
import '../Auth/login.dart';
import '../Auth/register.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../cubits/get_popular_deals_cubit/get_popular_deals_cubit.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isDonateSelected = false;
  double vaccumPrice = 0.0;
  bool isVaccumSelected = false;

  final TextEditingController promoCodeController = TextEditingController();
  PromoCodeData? appliedPromoCode;
  bool isPromoCodeApplied = false;
  bool isValidatingPromoCode = false;
  final TextEditingController notesController = TextEditingController();
  bool _isCreatingOrder = false; // Prevent duplicate submissions
  bool _deepLinkPromoAttempted = false; // Guard re-triggering deep link promo

  String? selectedDeliveryDate;
  String? selectedDeliveryTime;
  bool isFastDelivery = false;

  // Dio instance with TalkerDioLogger for order creation
  late final Dio _orderDio = Dio()
    ..interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseData: true,
          printRequestData: true,
        ),
      ),
    );

  @override
  void initState() {
    super.initState();
    context.read<GetPopularDealsCubit>().getPopularDeals();
    if (DeepLinkService.instance.pendingPromoCode != null) {
      // Apply a deep-link promo after the first frame, once the cart is loaded.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyPendingPromoFromDeepLink();
      });
    }
  }

  /// Applies a promo code delivered by a deep link (?promo={code}).
  ///
  /// If the cart is empty the promo is kept pending and applied the moment the
  /// first product is added (see the CartCubit listener in build()).
  void _applyPendingPromoFromDeepLink() {
    final promo = DeepLinkService.instance.pendingPromoCode;
    if (promo == null || promo.isEmpty || _deepLinkPromoAttempted) return;

    final cartState = context.read<CartCubit>().state;
    final hasItems = cartState is CartSuccess && cartState.products.isNotEmpty;
    if (!hasItems) return;

    _deepLinkPromoAttempted = true;
    if (promoCodeController.text.trim().isEmpty) {
      promoCodeController.text = promo;
    }
    if (!isPromoCodeApplied) {
      DeepLinkService.instance.clearPendingPromo();
      _validatePromoCode();
    }
  }

  Future<bool> createOrder(String addressId, String paymentType) async {
    // Prevent duplicate submissions
    if (_isCreatingOrder) {
      print('createOrder – Already creating order, ignoring duplicate request');
      return false;
    }

    print(
        'createOrder START – addressId: $addressId, paymentType: $paymentType');

    try {
      _isCreatingOrder = true;

      // احصل على الـ Cubits من الـ Global context (لازم تكون متاحة)
      final cartCubit = context.read<CartCubit>();
      final walletCubit = context.read<WalletCubit>();

      final cartState = cartCubit.state;
      if (cartState is! CartSuccess || cartState.products.isEmpty) {
        print('createOrder FAIL – cart empty');
        return false;
      }

      String? token = await SharedPreferences.getInstance()
          .then((v) => v.getString('token'));
      final prefs = await SharedPreferences.getInstance();
      String notes = notesController.text;
      await prefs.setString('order_notes', notes);
      print('createOrder – notes saved: $notes');

      double subtotal = double.tryParse(cartCubit.totalPrice) ?? 0.0;
      double promoDiscount = 0.0;
      if (isPromoCodeApplied && appliedPromoCode != null) {
        if (appliedPromoCode!.discountType == 'percentage') {
          final discountValue =
              double.tryParse(appliedPromoCode!.discountValue) ?? 0.0;
          promoDiscount = subtotal * (discountValue / 100);
        } else if (appliedPromoCode!.discountType == 'fixed') {
          promoDiscount =
              double.tryParse(appliedPromoCode!.discountValue) ?? 0.0;
        }
      }

      double shippingFees = 0.0;
      final allProductsState = context.read<AllProductsCubit>().state;
      if (allProductsState is AllProductsSuccess) {
        shippingFees = isFastDelivery
            ? (allProductsState.allProductsModel.deliveryPrice?.instant
                    ?.toDouble() ??
                0.0)
            : (allProductsState.allProductsModel.deliveryPrice?.scheduled
                    ?.toDouble() ??
                0.0);
      }

      double totalBeforeWallet = (subtotal - promoDiscount) + shippingFees;
      if (totalBeforeWallet < 0) totalBeforeWallet = 0;

      double walletBalance = 0.0;
      if (walletCubit.state is WalletSuccess) {
        walletBalance = (walletCubit.state as WalletSuccess).wallet.balance;
      }
      double walletDeduction = walletBalance > 0
          ? (walletBalance >= totalBeforeWallet
              ? totalBeforeWallet
              : walletBalance)
          : 0.0;

      // Prepare FormData for Dio
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('address_id', addressId),
        MapEntry('payment_type', paymentType),
        MapEntry('notes', notes),
        MapEntry('wallet_deduction', walletDeduction.toStringAsFixed(2)),
        MapEntry('fast_delivery', isFastDelivery.toString()),
      ]);

      if (isFastDelivery) {
        formData.fields.add(const MapEntry('delivery_type', '1'));
      } else {
        formData.fields.add(const MapEntry('delivery_type', '0'));
        formData.fields.add(
            MapEntry('scheduled_delivery_date', selectedDeliveryDate ?? ''));
        formData.fields.add(
            MapEntry('scheduled_delivery_time', selectedDeliveryTime ?? ''));
      }

      if (isPromoCodeApplied && appliedPromoCode != null) {
        formData.fields.add(MapEntry('promo_code', appliedPromoCode!.code));
      }

      final products = cartState.products;
      for (int i = 0; i < products.length; i++) {
        formData.fields.addAll([
          MapEntry('products[$i][id]', products[i].data!.id.toString()),
          MapEntry('products[$i][amount]',
              products[i].data!.quantity?.toInt().toString() ?? "1"),
          MapEntry('products[$i][packaging]',
              products[i].data!.isPackaging?.toString() ?? '0'),
        ]);
      }

      print('createOrder – sending request with Dio...');

      final response = await _orderDio.post(
        '$BASE_URL/order',
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('createOrder – response statusCode: ${response.statusCode}');
      print('createOrder – response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == true) {
          print('createOrder SUCCESS – clearing cart & wallet');
          // Facebook Purchase event (order total, EGP) for ad optimisation.
          MarketingService.instance.logPurchase(totalBeforeWallet, currency: 'EGP');
          cartCubit.clearCart();
          walletCubit.updateWalletBalance(walletBalance - walletDeduction);

          // لا تستخدم setState هنا – الـ widget ممكن يكون اتقفل
          promoCodeController.clear();
          notesController.clear();
          isPromoCodeApplied = false;
          appliedPromoCode = null;
          isDonateSelected = false;

          await prefs.remove('order_notes');

          return true;
        } else if (data is Map && data['status'] == false) {
          print('createOrder FAILED – ${data['message']}');
          if (context.mounted) {
            showSnackBarMessage(
                context,
                data['message'] ?? 'Order creation failed',
                Colors.red,
                Icons.error_outline);
          }
          return false;
        }
      }
    } on DioException catch (e) {
      print('createOrder DIO EXCEPTION: ${e.message}');
      print('createOrder – response: ${e.response?.data}');
      print('createOrder – statusCode: ${e.response?.statusCode}');

      // Handle duplicate order_code error specifically
      if (e.response?.statusCode == 500) {
        final responseData = e.response?.data;
        if (responseData is Map) {
          final message = responseData['message']?.toString() ?? '';
          if (message.contains('Duplicate entry') &&
              message.contains('orders_order_code_unique')) {
            print(
                'createOrder – Duplicate order_code detected. This may be a race condition.');
            // You might want to show a user-friendly message here
            // or implement retry logic with a delay
          }
        }
      }
    } catch (e, s) {
      print('createOrder EXCEPTION: $e\n$s');
    } finally {
      _isCreatingOrder = false;
    }

    print('createOrder FAIL');
    return false;
  }

  double _getFinalPriceDisplay() {
    double originalPrice =
        double.tryParse(context.read<CartCubit>().totalPrice) ?? 0.0;

    // Apply discount if promo code is applied
    if (isPromoCodeApplied && appliedPromoCode != null) {
      if (appliedPromoCode!.discountType == 'percentage') {
        final discountValue =
            double.tryParse(appliedPromoCode!.discountValue) ?? 0.0;
        originalPrice = originalPrice * (1 - (discountValue / 100));
      } else if (appliedPromoCode!.discountType == 'fixed') {
        final discountValue =
            double.tryParse(appliedPromoCode!.discountValue) ?? 0.0;
        originalPrice = originalPrice - discountValue;
      }
    }

    return originalPrice > 0 ? originalPrice : 0.0;
  }

  double _getShippingFees(AllProductsModel? allProductsModel) {
    if (allProductsModel == null || allProductsModel.deliveryPrice == null) {
      return 0.0;
    }
    return isFastDelivery
        ? (allProductsModel.deliveryPrice!.instant?.toDouble() ?? 0.0)
        : (allProductsModel.deliveryPrice!.scheduled?.toDouble() ?? 0.0);
  }

  double _getWalletDeduction(AllProductsModel? allProductsModel) {
    double finalPrice =
        _getFinalPriceDisplay() + _getShippingFees(allProductsModel);

    if (context.read<WalletCubit>().state is WalletSuccess) {
      double walletBalance =
          (context.read<WalletCubit>().state as WalletSuccess).wallet.balance;
      return walletBalance > 0
          ? (walletBalance >= finalPrice ? finalPrice : walletBalance)
          : 0.0;
    }
    return 0.0;
  }

  double _getAmountToPay(AllProductsModel? allProductsModel) {
    return _getFinalPriceDisplay() +
        _getShippingFees(allProductsModel) -
        _getWalletDeduction(allProductsModel);
  }

  Future<void> _validatePromoCode() async {
    if (promoCodeController.text.trim().isEmpty) {
      showSnackBarMessage(
          context,
          AppLocalizations.of(context).translate('enter promo code'),
          Colors.red,
          Icons.error_outline);
      return;
    }

    setState(() {
      isValidatingPromoCode = true;
    });

    try {
      final result = await validatePromoCode(promoCodeController.text.trim());

      if (result.status && result.data != null) {
        setState(() {
          appliedPromoCode = result.data;
          isPromoCodeApplied = true;
          isValidatingPromoCode = false;
        });

        if (mounted) {
          showSnackBarMessage(
              context,
              AppLocalizations.of(context)
                  .translate('promo code applied successfully'),
              Colors.green,
              Icons.check);
        }
      } else {
        setState(() {
          isValidatingPromoCode = false;
          isPromoCodeApplied = false;
          appliedPromoCode = null;
        });

        if (mounted) {
          showSnackBarMessage(context, result.msg, Colors.red, Icons.error_outline);
        }
      }
    } catch (e) {
      setState(() {
        isValidatingPromoCode = false;
        isPromoCodeApplied = false;
        appliedPromoCode = null;
      });

      if (mounted) {
        showSnackBarMessage(
            context,
            AppLocalizations.of(context)
                .translate('error validating promo code'),
            Colors.red,
            Icons.error_outline);
      }
    }
  }

  double _calculateDiscountedPrice() {
    return _getFinalPriceDisplay();
  }

  double _calculateDiscountAmount() {
    final totalPrice =
        double.tryParse(context.read<CartCubit>().totalPrice) ?? 0.0;

    if (isPromoCodeApplied && appliedPromoCode != null) {
      if (appliedPromoCode!.discountType == 'percentage') {
        final discountValue =
            double.tryParse(appliedPromoCode!.discountValue) ?? 0.0;
        return totalPrice * (discountValue / 100);
      } else if (appliedPromoCode!.discountType == 'fixed') {
        final discountValue =
            double.tryParse(appliedPromoCode!.discountValue) ?? 0.0;
        return discountValue;
      }
    }

    return 0.0;
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> storeOrderCreationTime(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    prefs.setInt('order_creation_time_$orderId', now);
  }

  void _openPaymentLink(String link) {
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(link: link),
      ),
    );
  }

  void _showPaymentTypeSelection(NavigatorState navigator, String addressId) {
    print('_showPaymentTypeSelection OPEN – addressId: $addressId');

    showDialog(
      context: navigator.context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(navigator.context)
              .translate('payment method')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: ListTile(
                  title: Text(AppLocalizations.of(navigator.context)
                      .translate('cash on delivery')),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    print('Cash on delivery TAP');
                    Navigator.of(dialogContext).pop(); // اقفل الـ Dialog
                    print('Dialog POPPED');

                    // نفذ الطلب
                    final success = await createOrder(addressId, 'cash');
                    print('createOrder returned: $success');

                    if (success) {
                      print('NAVIGATING TO SuccessView');
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SuccessView()),
                        (route) => false,
                      );

                      final prefs = await SharedPreferences.getInstance();
                      prefs.setInt('order_creation_time',
                          DateTime.now().millisecondsSinceEpoch);
                      print('order_creation_time saved');
                    } else {
                      print('Order FAILED');
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddressSelectionBottomSheet(BuildContext context) async {
    // Show a loading indicator while fetching addresses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    GetAllAddressesModel addresses;
    try {
      addresses = await fetchAllAddresses();
      if (context.mounted) Navigator.pop(context); // Remove loading indicator
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading indicator
        showSnackBarMessage(
            context, e.toString(), Colors.red, Icons.error_outline);
      }
      return;
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        int? selectedAddressId;
        if (addresses.data != null && addresses.data!.isNotEmpty) {
          selectedAddressId = addresses.data![0].id;
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    AppLocalizations.of(context)
                        .translate('choose an address or payment method'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ADD NEW ADDRESS Button
                  defaultButton(
                    function: () {
                      Navigator.pop(context);
                      navigateTo(context, const ShippingAddressScreen());
                    },
                    text: AppLocalizations.of(context)
                        .translate('add new address'),
                    isUpperCase: true,
                  ),

                  const SizedBox(height: 30),

                  if (addresses.data != null && addresses.data!.isNotEmpty) ...[
                    // Dropdown for Addresses
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: selectedAddressId,
                          hint: Text(AppLocalizations.of(context)
                              .translate('address')),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: kMainColor),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          items: addresses.data!.map((address) {
                            return DropdownMenuItem<int>(
                              value: address.id,
                              child: Text(
                                address.address ?? address.title ?? '',
                                style: GoogleFonts.lato(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setModalState(() {
                              selectedAddressId = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // DONATE Button
                    defaultButton(
                      function: () {
                        if (selectedAddressId != null) {
                          final navigator = Navigator.of(bottomSheetContext);
                          Navigator.pop(bottomSheetContext);
                          _showPaymentTypeSelection(
                            navigator,
                            selectedAddressId.toString(),
                          );
                        }
                      },
                      text: AppLocalizations.of(context).translate('Donate'),
                      isUpperCase: true,
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        AppLocalizations.of(context).translate('no addresses'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> checkStockAvailability() async {
    final cartCubit = context.read<CartCubit>();
    if (cartCubit.state is! CartSuccess) return true;

    final products = (cartCubit.state as CartSuccess).products;
    List<String> outOfStockItems = [];

    String? token =
        await SharedPreferences.getInstance().then((v) => v.getString('token'));

    for (var cartItem in products) {
      try {
        final response = await http.get(
          Uri.parse('$BASE_URL/product/${cartItem.data!.id}'),
          headers: {
            "Accept": "application/json",
            if (token != null) 'Authorization': 'Bearer $token'
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true && data['data'] != null) {
            num currentStock = data['data']['amount'] ?? 0;
            double requestedQty = cartItem.data!.quantity ?? 0;

            if (currentStock < requestedQty) {
              String packagingInfo = cartItem.data!.isPackaging == 1
                  ? ' (${AppLocalizations.of(context).translate("Vacuum Packed")})'
                  : '';
              outOfStockItems.add(
                  '${cartItem.data!.title}$packagingInfo: ${AppLocalizations.of(context).translate("Only")} $currentStock ${AppLocalizations.of(context).translate("available")}');
            }
          }
        }
      } catch (e) {
        print('Error checking stock for product ${cartItem.data!.id}: $e');
      }
    }

    if (outOfStockItems.isNotEmpty) {
      if (!mounted) return false;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).translate('Stock Alert'),
            style:
                const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate(
                      'Some items are out of stock or have limited quantity:'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ...outOfStockItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).translate('OK')),
            ),
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> _checkCartStock() async {
    final cartCubit = context.read<CartCubit>();
    if (cartCubit.state is! CartSuccess) return true;

    final products = (cartCubit.state as CartSuccess).products;

    String? token =
        await SharedPreferences.getInstance().then((v) => v.getString('token'));

    for (var cartItem in products) {
      try {
        final response = await http.get(
          Uri.parse('$BASE_URL/product/${cartItem.data!.id}'),
          headers: {
            "Accept": "application/json",
            if (token != null) 'Authorization': 'Bearer $token'
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true && data['data'] != null) {
            num currentStock = data['data']['amount'] ?? 0;
            double requestedQty = cartItem.data!.quantity ?? 0;

            if (currentStock < requestedQty) {
              return false;
            }
          }
        }
      } catch (e) {
        print('Error checking stock: $e');
      }
    }

    return true;
  }

  List<String> _getAvailableTimeSlots() {
    final allSlots = [
      '6 AM - 9 AM',
      '9 AM - 12 PM',
      '12 PM - 3 PM',
      '3 PM - 6 PM',
      '6 PM - 9 PM',
      '9 PM - 12 AM',
    ];

    if (selectedDeliveryDate != 'today') {
      return allSlots;
    }

    final now = DateTime.now();
    final currentTotalMinutes = now.hour * 60 + now.minute;

    return allSlots.where((slot) {
      int endHour;
      if (slot == '6 AM - 9 AM') {
        endHour = 9;
      } else if (slot == '9 AM - 12 PM') {
        endHour = 12;
      } else if (slot == '12 PM - 3 PM') {
        endHour = 15;
      } else if (slot == '3 PM - 6 PM') {
        endHour = 18;
      } else if (slot == '6 PM - 9 PM') {
        endHour = 21;
      } else if (slot == '9 PM - 12 AM') {
        endHour = 24;
      } else {
        return false;
      }

      // Slot end time in minutes from start of day
      final endTotalMinutes = endHour * 60;

      // Show only if more than 1 hour (60 minutes) remains until the slot ends
      return (endTotalMinutes - currentTotalMinutes) > 60;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).translate('cart'),
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                navigateTo(context, const OrdersScreen());
              },
              child: Text(
                AppLocalizations.of(context).translate('previos orders'),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    color: kMainColor),
              ))
        ],
      ),
      body: token != null
          ? BlocConsumer<CartCubit, CartState>(
              listener: (context, state) {
                setState(() {});
                // Apply a pending deep-link promo as soon as items appear.
                if (state is CartSuccess && state.products.isNotEmpty) {
                  _applyPendingPromoFromDeepLink();
                }
              },
              builder: (context, state) {
                if (state is CartSuccess) {
                  if (state.products.isEmpty) {
                    return Center(
                      child: Text(
                          AppLocalizations.of(context).translate('Empty Cart')),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                        child: Column(
                          children: [
                            // Wallet Display Widget - TOP POSITION
                            BlocBuilder<WalletCubit, WalletState>(
                              builder: (context, walletState) {
                                if (walletState is WalletSuccess) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: constraints.maxHeight * 0.02),
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          constraints.maxWidth * 0.04),
                                      decoration: BoxDecoration(
                                        color: kMainColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.account_balance_wallet,
                                                  color: Colors.white,
                                                  size: 28),
                                              SizedBox(
                                                  width: constraints.maxWidth *
                                                      0.03),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'Wallet Balance'),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${walletState.wallet.balance.toStringAsFixed(2)} LE',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),

                            const SizedBox(height: 10),

                            // Similar Products Section
                            BlocBuilder<GetPopularDealsCubit,
                                GetPopularDealsState>(
                              builder: (context, dealsState) {
                                if (dealsState is GetPopularDealsSuccess) {
                                  final deals =
                                      (dealsState.popularDeals.data ?? [])
                                          .where((product) =>
                                              (product.amount ?? 0) > 0)
                                          .toList();
                                  if (deals.isEmpty) return const SizedBox();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('Similar Products'),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.045,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: constraints.maxWidth * 0.35,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: deals.length,
                                          itemBuilder: (context, index) {
                                            final product = deals[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: constraints
                                                                .maxWidth *
                                                            0.1,
                                                        backgroundColor:
                                                            Colors.grey[200],
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                product.photo ??
                                                                    '',
                                                            width: constraints
                                                                    .maxWidth *
                                                                0.2,
                                                            height: constraints
                                                                    .maxWidth *
                                                                0.2,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                const CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .shopping_cart),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          if ((product.amount ??
                                                                  0) <=
                                                              0) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    '${product.myTitle} ${AppLocalizations.of(context).translate('out of stock')}'),
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                backgroundColor:
                                                                    Colors.red,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                              ),
                                                            );
                                                            return;
                                                          }
                                                          final cartData = Data(
                                                            id: product.id,
                                                            title:
                                                                product.titleEn,
                                                            myTitle:
                                                                product.myTitle,
                                                            photo:
                                                                product.photo,
                                                            price:
                                                                product.price,
                                                            realPrice: product
                                                                .realPrice,
                                                            isPackaging: product
                                                                    .isPackaging ??
                                                                0,
                                                            quantity: 1,
                                                            amount:
                                                                product.amount,
                                                            packaging: product
                                                                .packaging,
                                                          );
                                                          final productModel =
                                                              ProductModel(
                                                            status: true,
                                                            data: cartData,
                                                          );
                                                          context
                                                              .read<CartCubit>()
                                                              .addProduct(
                                                                  productModel);

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  '${product.myTitle} ${AppLocalizations.of(context).translate('added to cart')}'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                              backgroundColor:
                                                                  kMainColor,
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: kMainColor,
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius: 4,
                                                                offset: Offset(
                                                                    0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  SizedBox(
                                                    width:
                                                        constraints.maxWidth *
                                                            0.2,
                                                    child: Text(
                                                      product.myTitle ?? '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: constraints
                                                                .maxWidth *
                                                            0.03,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                }
                                return const SizedBox();
                              },
                            ),

                            const SizedBox(height: 5),

                            // Cart Products List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: state.products.length,
                              itemBuilder: (context, index) {
                                final item = state.products[index];
                                return CartItemTile(
                                  data: item.data!,
                                  onRemove: () {
                                    context
                                        .read<CartCubit>()
                                        .removeProduct(item);
                                  },
                                  onQuantityChange: (change) {
                                    context
                                        .read<CartCubit>()
                                        .updateQuantity(item, change);
                                  },
                                  constraints: constraints,
                                );
                              },
                            ),

                            // Delivery Date & Time section
                            Container(
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.04),
                              margin: EdgeInsets.only(
                                  top: constraints.maxHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('Delivery Details'),
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontSize: constraints.maxWidth * 0.04,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  // Date Dropdown
                                  if (isFastDelivery) ...[
                                    SizedBox(
                                      height: constraints.maxHeight * 0.01,
                                    ),
                                  ] else ...[
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedDeliveryDate,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)
                                            .translate('Delivery Date'),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'today',
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate('Today')),
                                        ),
                                        DropdownMenuItem(
                                          value: 'tomorrow',
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate('Tomorrow')),
                                        ),
                                        DropdownMenuItem(
                                          value: 'day_after_tomorrow',
                                          child: Text(AppLocalizations.of(
                                                  context)
                                              .translate('Day after tomorrow')),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          selectedDeliveryDate = val;
                                          // Reset time if it's no longer valid for the selected date
                                          if (selectedDeliveryTime != null) {
                                            if (!_getAvailableTimeSlots()
                                                .contains(
                                                    selectedDeliveryTime)) {
                                              selectedDeliveryTime = null;
                                            }
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.015),
                                    // Time Slot Dropdown
                                    DropdownButtonFormField<String>(
                                      initialValue: selectedDeliveryTime,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)
                                            .translate('Delivery Time'),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      items:
                                          _getAvailableTimeSlots().map((time) {
                                        return DropdownMenuItem(
                                          value: time,
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate(time),
                                              textDirection:
                                                  AppLocalizations.of(context)
                                                          .isEnLocale
                                                      ? TextDirection.ltr
                                                      : TextDirection.rtl),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedDeliveryTime = val;
                                        });
                                      },
                                    ),
                                  ],

                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  // Fast Delivery Checkbox
                                  CheckboxListTile(
                                    title: Text(
                                      AppLocalizations.of(context)
                                          .translate('Fast Delivery'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    value: isFastDelivery,
                                    activeColor: kMainColor,
                                    onChanged: (val) {
                                      setState(() {
                                        isFastDelivery = val ?? false;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),

                            // Notes Section
                            Container(
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.04),
                              margin: EdgeInsets.only(
                                  top: constraints.maxHeight * 0.02,
                                  bottom: constraints.maxHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('notes'),
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontSize: constraints.maxWidth * 0.04,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  TextField(
                                    controller: notesController,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .translate('add order description'),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: constraints.maxWidth * 0.03,
                                        vertical: constraints.maxHeight * 0.015,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Promo Code Section
                            Container(
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.04),
                              margin: EdgeInsets.only(
                                  bottom: constraints.maxHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('have a promo code'),
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        fontSize: constraints.maxWidth * 0.04,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: promoCodeController,
                                          enabled: !isPromoCodeApplied,
                                          decoration: InputDecoration(
                                            hintText: AppLocalizations.of(
                                                    context)
                                                .translate('enter promo code'),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal:
                                                  constraints.maxWidth * 0.03,
                                              vertical:
                                                  constraints.maxHeight * 0.015,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: constraints.maxWidth * 0.02),
                                      isPromoCodeApplied
                                          ? IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'Remove Promo Code?'),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'This promo code can only be used once. If you remove it now, you won\'t be able to apply it again.'),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'Cancel'),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            isPromoCodeApplied =
                                                                false;
                                                            appliedPromoCode =
                                                                null;
                                                            promoCodeController
                                                                .clear();
                                                          });
                                                        },
                                                        child: Text(
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  'Remove'),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            )
                                          : ElevatedButton(
                                              onPressed: isValidatingPromoCode
                                                  ? null
                                                  : _validatePromoCode,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: kMainColor,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      constraints.maxWidth *
                                                          0.04,
                                                  vertical:
                                                      constraints.maxHeight *
                                                          0.015,
                                                ),
                                              ),
                                              child: isValidatingPromoCode
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate('apply'),
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                            ),
                                    ],
                                  ),
                                  if (isPromoCodeApplied &&
                                      appliedPromoCode != null)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: constraints.maxHeight * 0.01),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: Colors.green, size: 16),
                                          SizedBox(
                                              width:
                                                  constraints.maxWidth * 0.02),
                                          Text(
                                            '${appliedPromoCode!.discountValue}${appliedPromoCode!.discountType == 'percentage' ? '%' : ' LE'} ${AppLocalizations.of(context).translate('discount applied')}',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize:
                                                  constraints.maxWidth * 0.035,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Price Summary
                            BlocBuilder<AllProductsCubit, AllProductsState>(
                              builder: (context, allProductsState) {
                                AllProductsModel? allProductsModel;
                                if (allProductsState is AllProductsSuccess) {
                                  allProductsModel =
                                      allProductsState.allProductsModel;
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate('Subtotal'),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.045,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${context.read<CartCubit>().totalPrice} LE',
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.045,
                                            fontWeight: FontWeight.w600,
                                            decoration: isPromoCodeApplied
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isPromoCodeApplied
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isPromoCodeApplied) ...[
                                      SizedBox(
                                          height: constraints.maxHeight * 0.01),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)
                                                .translate('Discount'),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                fontSize: constraints.maxWidth *
                                                    0.045,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '- ${_calculateDiscountAmount().toStringAsFixed(2)} LE',
                                            style: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.045,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    SizedBox(
                                        height: constraints.maxHeight * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate('Shipping fees'),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.045,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${_getShippingFees(allProductsModel).toStringAsFixed(2)} LE',
                                          style: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.045,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    // Wallet Deduction Section
                                    BlocBuilder<WalletCubit, WalletState>(
                                      builder: (context, walletState) {
                                        if (walletState is WalletSuccess &&
                                            _getWalletDeduction(
                                                    allProductsModel) >
                                                0) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                top: constraints.maxHeight *
                                                    0.01),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .account_balance_wallet,
                                                        color: Colors.blue,
                                                        size: 18),
                                                    SizedBox(
                                                        width: constraints
                                                                .maxWidth *
                                                            0.02),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'Wallet Deduction'),
                                                      style: GoogleFonts.lato(
                                                        textStyle: TextStyle(
                                                          fontSize: constraints
                                                                  .maxWidth *
                                                              0.045,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '- ${_getWalletDeduction(allProductsModel).toStringAsFixed(2)} LE',
                                                  style: TextStyle(
                                                    fontSize:
                                                        constraints.maxWidth *
                                                            0.045,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.01),
                                    // Final Total Section
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate(isPromoCodeApplied ||
                                                      _getWalletDeduction(
                                                              allProductsModel) >
                                                          0
                                                  ? 'Total to Pay'
                                                  : 'Total'),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.05,
                                              fontWeight: FontWeight.w900,
                                              color: kMainColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${_getAmountToPay(allProductsModel).toStringAsFixed(2)} LE',
                                          style: TextStyle(
                                            fontSize:
                                                constraints.maxWidth * 0.05,
                                            fontWeight: FontWeight.w900,
                                            color: kMainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: defaultButton(
                                      function: () async {
                                        if (!isFastDelivery &&
                                            (selectedDeliveryDate == null ||
                                                selectedDeliveryTime == null)) {
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   SnackBar(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(
                                          //             horizontal: 15,
                                          //             vertical: 25),
                                          //     content: Text(
                                          //       AppLocalizations.of(context)
                                          //           .translate(
                                          //               'select_delivery_details'),
                                          //     ),
                                          //     backgroundColor: Colors.red,
                                          //     behavior:
                                          //         SnackBarBehavior.floating,
                                          //   ),
                                          // );
                                          showSnackBarMessage(
                                              context,
                                              AppLocalizations.of(context)
                                                  .translate(
                                                  'select_delivery_details'),
                                              Colors.red,
                                              Icons.error_outline);
                                          return;
                                        }

                                        bool stockAvailable =
                                            await checkStockAvailability();
                                        if (stockAvailable) {
                                          _showAddressSelectionBottomSheet(
                                              context);
                                        }
                                      },
                                      text: AppLocalizations.of(context)
                                          .translate('CheckOut'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            )
          : Padding(
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

class CartItemTile extends StatelessWidget {
  final Data data;
  final VoidCallback onRemove;
  final Function(double) onQuantityChange;
  final BoxConstraints constraints;

  const CartItemTile({
    super.key,
    required this.data,
    required this.onRemove,
    required this.onQuantityChange,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    double quantity = data.quantity ?? 1;
    double itemPrice = (double.tryParse(data.price ?? '0') ?? 0.0) * quantity;
    // Use smaller of width/height for icon sizing to avoid huge icons on tablets if constraints are weird
    final responsiveUnit = constraints.maxWidth;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 0, // Parent has padding
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(responsiveUnit * 0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: data.photo != null && data.photo!.isNotEmpty
                  ? Image.network(
                      data.photo!,
                      width: responsiveUnit * 0.20,
                      height: responsiveUnit * 0.20,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: responsiveUnit * 0.20,
                        height: responsiveUnit * 0.20,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: responsiveUnit * 0.1),
                      ),
                    )
                  : Container(
                      width: responsiveUnit * 0.20,
                      height: responsiveUnit * 0.20,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: responsiveUnit * 0.1),
                    ),
            ),
            SizedBox(width: responsiveUnit * 0.03),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title ?? 'Unknown Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: responsiveUnit * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (data.isPackaging == 1) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory,
                          size: responsiveUnit * 0.035,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('Vacuum Packed'),
                            style: TextStyle(
                              fontSize: responsiveUnit * 0.03,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${itemPrice.toStringAsFixed(2)} LE',
                    style: TextStyle(
                        fontSize: responsiveUnit * 0.04,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Quantity and Actions
            // Using a Column here if horizontal space is tight, or just a compact Row
            // Let's try to keep it in a Row but cleaner.
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Quantity Row
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => onQuantityChange(-1.0),
                        child: Icon(Icons.remove, size: responsiveUnit * 0.05),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${quantity.toInt()} ${AppLocalizations.of(context).isEnLocale ? (data.unit?.titleEn ?? data.unit?.title ?? "") : (data.unit?.titleAr ?? data.unit?.myTitle ?? "")}',
                          style: TextStyle(
                            fontSize: responsiveUnit * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => onQuantityChange(1.0),
                        child: Icon(Icons.add, size: responsiveUnit * 0.05),
                      ),
                    ],
                  ),
                ),
                // Remove Button
                IconButton(
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: responsiveUnit * 0.06,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
