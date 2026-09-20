import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegesea/cubits/orders_cubit/orders_cubit.dart';
import 'package:vegesea/layout/orders/track_order.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import 'package:vegesea/layout/orders/edit_order_screen.dart';

import '../../cubits/wallet_cubit/wallet_cubit.dart';
import '../root_view.dart';
import 'package:vegesea/models/one_order_model.dart' as one_order;

class OrderDetailScreen extends StatefulWidget {
  final dynamic orderId;
  final String? address;
  const OrderDetailScreen({super.key, this.orderId, this.address});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool? isOrderDeleted;
  String? orderTybe;
  dynamic theOrderID;
  Timer? _timer;
  int _remainingTime = 0;
  int _refundRemainingTime = 0;
  DateTime? _orderCreationTime;
  Duration _serverOffset = Duration.zero;
  var refundReasonController = TextEditingController();
  one_order.OneOrderModel? orderModel;

  Future<void> determineOrderID() async {
    final prefs = await SharedPreferences.getInstance();

    // Check arguments from ModalRoute (passed from notifications)
    final args = ModalRoute.of(context)?.settings.arguments;
    log("Checking order details arguments: $args");

    setState(() {
      if (widget.orderId != null) {
        theOrderID = widget.orderId;
      } else if (args != null) {
        theOrderID = args;
      } else if (prefs.containsKey('order_id_from_notis_screen')) {
        theOrderID = prefs.get('order_id_from_notis_screen');
      } else if (prefs.containsKey('order_id')) {
        theOrderID = prefs.get('order_id');
      } else {
        theOrderID = null;
      }
    });

    if (theOrderID != null) {
      log("Order ID determined: $theOrderID");
      triggerOrderCubit();
    } else {
      log('Error: Unable to determine order ID.');
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateFormat("yyyy-MM-dd hh:mm a", 'en_US').parse(dateStr);
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd h:mm a", 'en_US').parse(dateStr);
      } catch (_) {
        try {
          return DateTime.parse(dateStr);
        } catch (_) {
          return null;
        }
      }
    }
  }

  void _updateRemainingTimes() {
    if (_orderCreationTime == null) return;

    final now = DateTime.now().add(_serverOffset);
    final elapsed = now.difference(_orderCreationTime!).inSeconds;

    final cancelRemaining = 300 - elapsed;
    final refundRemaining = 1800 - elapsed;

    if (mounted) {
      setState(() {
        _remainingTime = cancelRemaining > 0 ? cancelRemaining : 0;
        _refundRemainingTime = refundRemaining > 0 ? refundRemaining : 0;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTimes();
      if (_remainingTime <= 0 && _refundRemainingTime <= 0) {
        timer.cancel();
      }
    });
  }

  void triggerOrderCubit() {
    BlocProvider.of<OrdersCubit>(context).getOneOrdere(theOrderID!);
  }

  Future<void> removeOrderNotificationID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('order_id');
  }

  int? orderStatus;

  @override
  void initState() {
    determineOrderID();
    isOrderDeleted = false;
    removeOrderNotificationID();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // void _showMessage(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(message)),
  //   );
  // }

  String _getStatusText(int? status) {
    switch (status) {
      case 0:
        return AppLocalizations.of(context).translate('order canceled');
      case 1:
        return AppLocalizations.of(context).translate('placed');
      case 2:
        return AppLocalizations.of(context).translate('confirmed');
      case 3:
        return AppLocalizations.of(context).translate('preparing');
      case 4:
        return AppLocalizations.of(context).translate('out for delivery');
      case 5:
        return AppLocalizations.of(context).translate('delivered');
      case 6:
        return AppLocalizations.of(context).translate('refunded');
      default:
        return AppLocalizations.of(context).translate('unknown status');
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.teal;
      case 5:
        return Colors.green;
      case 6:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  List<Widget> _buildProductSections(List<one_order.Products> products) {
    final packed = products.where((p) => p.pivot?.packaging == 1).toList();
    final normal = products.where((p) => p.pivot?.packaging != 1).toList();

    List<Widget> sections = [];

    if (packed.isNotEmpty) {
      sections.add(_buildSectionHeader(
        AppLocalizations.of(context).translate("Vacuum Packed"),
        Icons.vibration_outlined,
        Colors.blue.shade700,
      ));
      sections.addAll(packed.map((p) => _buildProductItem(p)));
      if (normal.isNotEmpty) sections.add(const SizedBox(height: 16));
    }

    if (normal.isNotEmpty) {
      sections.add(_buildSectionHeader(
        AppLocalizations.of(context).translate("Standard"),
        Icons.inventory_2_outlined,
        Colors.grey.shade700,
      ));
      sections.addAll(normal.map((p) => _buildProductItem(p)));
    }

    return sections;
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(one_order.Products product) {
    bool isPacked = product.pivot?.packaging == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.photo != null && product.photo!.isNotEmpty
                  ? Image.network(
                      product.photo!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 40),
                    )
                  : const Icon(Icons.image_not_supported, size: 40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).locale.languageCode == 'en'
                        ? (product.titleEn ??
                            product.titleAr ??
                            'Unknown Product')
                        : (product.titleAr ??
                            product.titleEn ??
                            'منتج غير معروف'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        !isPacked
                            ? '${product.price} LE'
                            : '${product.pivot?.price ?? product.price} + ${product.pivot?.packagingPrice} LE',
                        style: TextStyle(
                          color: kMainColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isPacked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate("Vacuum Packed"),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x${product.pivot?.amount ?? 0}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPriceDetailRows(one_order.Data order) {
    final packedTotal = order.products
            ?.where((p) => p.pivot?.packaging == 1)
            .fold<double>(
                0,
                (sum, p) =>
                    sum +
                    (double.tryParse(p.pivot?.price ?? '0') ?? 0) *
                        (p.pivot?.amount ?? 0)) ??
        0;

    final normalTotal = order.products
            ?.where((p) => p.pivot?.packaging != 1)
            .fold<double>(
                0,
                (sum, p) =>
                    sum +
                    (double.tryParse(p.pivot?.price ?? '0') ?? 0) *
                        (p.pivot?.amount ?? 0)) ??
        0;

    bool hasDiscount = (order.promoCodeId != null ||
        (order.amountPaidUsingWallet != null &&
            double.tryParse(order.amountPaidUsingWallet ?? '0') != 0));

    List<Widget> rows = [];

    // Subtotal Row
    rows.add(_buildPriceRow(
      AppLocalizations.of(context).translate('Subtotal'),
      '${order.price} LE',
      isBold: true,
      strikethrough: hasDiscount,
    ));

    // if (packedTotal > 0) {
    //   rows.add(Padding(
    //     padding: const EdgeInsets.only(left: 12),
    //     child: _buildPriceRow(
    //       '• ${AppLocalizations.of(context).translate("Vacuum Packed")}',
    //       '', //'$packedTotal LE',
    //       fontSize: 14,
    //       color: Colors.blue.shade700,
    //     ),
    //   ));
    // }

    // if (normalTotal > 0 && packedTotal > 0) {
    //   rows.add(Padding(
    //     padding: const EdgeInsets.only(left: 12),
    //     child: _buildPriceRow(
    //       '• ${AppLocalizations.of(context).translate("Standard")}',
    //       '$normalTotal LE',
    //       fontSize: 14,
    //       color: Colors.grey.shade700,
    //     ),
    //   ));
    // }

    return rows;
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false,
      bool strikethrough = false,
      double fontSize = 16,
      Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
              color: strikethrough ? Colors.grey : (color ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log(widget.orderId.toString());
    double height = MediaQuery.of(context).size.height;
    return BlocConsumer<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state is DeleteOrderSuccess) {
          //_showMessage(state.deleteOrderSuccessMessage);
          showSnackBarMessage(context, state.deleteOrderSuccessMessage,
              Colors.green, Icons.check);
          context.read<WalletCubit>().fetchWalletBalance();
          navigateAndFinish(context, const RootView());
          BlocProvider.of<OrdersCubit>(context).getAllOrderes();
        } else if (state is DeleteOrderFaluire) {
          //_showMessage(state.deleteOrderFaluireMessage);
          showSnackBarMessage(context, state.deleteOrderFaluireMessage,
              Colors.red, Icons.error_outline);
          showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: AlertDialog(
                  alignment: Alignment.center,
                  content: Text(
                    textAlign: TextAlign.center,
                    state.deleteOrderFaluireMessage,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
          BlocProvider.of<OrdersCubit>(context).getOneOrdere(theOrderID!);
        } else if (state is GetOneOrderSuccess) {
          setState(() {
            isOrderDeleted = false;
            orderModel = state.order;
            // Calculate remaining time based on server data
            final order = state.order.data;
            orderStatus = order?.status;
            orderTybe = order?.type.toString();
            if (orderTybe == "0") {
              isOrderDeleted = true;
            } else if (orderTybe == "1") {
              isOrderDeleted = false;
            }

            _orderCreationTime = _parseDate(order?.createdAt);
            final serverNow = _parseDate(order?.date);

            if (serverNow != null) {
              _serverOffset = serverNow.difference(DateTime.now());
            } else {
              _serverOffset = Duration.zero;
            }

            _updateRemainingTimes();

            if (_remainingTime > 0 || _refundRemainingTime > 0) {
              _startTimer();
            }
          });
        } else if (state is RefundOrderSuccess) {
          showSnackBarMessage(
              context, state.message, Colors.green, Icons.check);
          setState(() {
            orderModel = null;
          });
          BlocProvider.of<OrdersCubit>(context).getOneOrdere(theOrderID!);
          BlocProvider.of<OrdersCubit>(context).getAllOrderes();
          context.read<WalletCubit>().fetchWalletBalance();
        } else if (state is RefundOrderFaluire) {
          //_showMessage(state.message);
          showSnackBarMessage(
              context, state.message, Colors.red, Icons.error_outline);
        }
      },
      builder: (context, state) {
        if (state is GetOneOrderLoading && orderModel == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (orderModel != null && orderModel!.data != null) {
          final order = orderModel!.data!;
          return Scaffold(
            floatingActionButton: const MovableFloatingButton(),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              title: Text(
                AppLocalizations.of(context).translate('order details'),
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              actions: const [
                HomeButton(),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppLocalizations.of(context).translate("order id")}: ${order.id}',
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${AppLocalizations.of(context).translate("history")}: ${order.createdAt}',
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          isOrderDeleted == true
                              ? Text(
                                  AppLocalizations.of(context)
                                      .translate('order canceled'),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  _getStatusText(orderStatus),
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: _getStatusColor(orderStatus),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          isOrderDeleted == true
                              ? const SizedBox()
                              : Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    defaultButton(
                                      height: height * 0.06,
                                      function: () {
                                        navigateTo(
                                          context,
                                          TrackOrderView(
                                              orderStatus: orderStatus!),
                                        );
                                      },
                                      text: AppLocalizations.of(context)
                                          .translate("track order"),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("address"),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.address ?? 'غير متوفر',
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).translate("notes"),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.notes!,
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag_outlined,
                                  color: kMainColor),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)
                                    .translate("products"),
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ..._buildProductSections(order.products ?? []),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translate("price details"),
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._buildPriceDetailRows(order),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .translate('delivery_price'),
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${order.deliveryPrice} LE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: (order.promoCodeId != null ||
                                          (order.amountPaidUsingWallet !=
                                                  null &&
                                              double.tryParse(order
                                                          .amountPaidUsingWallet ??
                                                      '0') !=
                                                  0))
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: (order.promoCodeId != null ||
                                          (order.amountPaidUsingWallet !=
                                                  null &&
                                              double.tryParse(order
                                                          .amountPaidUsingWallet ??
                                                      '0') !=
                                                  0))
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          if (order.promoCodeId != null &&
                              order.couponAmount != null &&
                              double.tryParse(order.priceAfterOffer ?? '0') !=
                                  0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.local_offer,
                                        color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('Discount'),
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '- ${order.couponAmount} LE',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (order.amountPaidUsingWallet != null &&
                              double.tryParse(
                                      order.amountPaidUsingWallet ?? '0') !=
                                  0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet,
                                        color: Colors.blue, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)
                                          .translate('Wallet Deduction'),
                                      style: GoogleFonts.lato(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '- ${order.amountPaidUsingWallet} LE',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .translate('Total to Pay'),
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: kMainColor,
                                  ),
                                ),
                              ),
                              Text(
                                order.priceAfterOffer != null &&
                                        double.tryParse(
                                                order.priceAfterOffer ?? '0') !=
                                            0
                                    ? '${order.priceAfterOffer} LE'
                                    : '${order.price} LE',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: kMainColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOrderDeleted == true ||
                      orderStatus == 0 ||
                      orderStatus == 4)
                    const SizedBox()
                  else if (orderStatus == 5)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        // defaultButton(
                        //   background: Colors.orange,
                        //   function: () {
                        //     final GlobalKey<FormState> refundFormKey =
                        //         GlobalKey<FormState>();
                        //     showDialog(
                        //       context: context,
                        //       builder: (context) => Form(
                        //         key: refundFormKey,
                        //         child: AlertDialog(
                        //           backgroundColor: Colors.white,
                        //           title: Text(AppLocalizations.of(context)
                        //               .translate('refund_order')),
                        //           content: Column(
                        //             mainAxisSize: MainAxisSize.min,
                        //             children: [
                        //               Text(AppLocalizations.of(context)
                        //                   .translate('refund_reason_hint')),
                        //               const SizedBox(height: 10),
                        //               TextFormField(
                        //                 controller: refundReasonController,
                        //                 validator: (value) {
                        //                   if (value == null ||
                        //                       value.trim().isEmpty) {
                        //                     return AppLocalizations.of(context)
                        //                         .translate(
                        //                             'please_enter_reason');
                        //                   }
                        //                   if (value.trim().length < 10) {
                        //                     return AppLocalizations.of(context)
                        //                         .translate('reason_too_short');
                        //                   }
                        //                   return null;
                        //                 },
                        //                 decoration: InputDecoration(
                        //                   hintText: AppLocalizations.of(context)
                        //                       .translate('write_reason'),
                        //                   hintStyle: const TextStyle(
                        //                     color: Colors.grey,
                        //                   ),
                        //                   border: OutlineInputBorder(
                        //                     borderRadius:
                        //                         BorderRadius.circular(8),
                        //                     borderSide: const BorderSide(
                        //                       color: Colors.grey,
                        //                     ),
                        //                   ),
                        //                 ),
                        //                 maxLines: 3,
                        //               ),
                        //             ],
                        //           ),
                        //           actions: [
                        //             TextButton(
                        //               onPressed: () => Navigator.pop(context),
                        //               child: Text(
                        //                   AppLocalizations.of(context)
                        //                       .translate('cancel'),
                        //                   style: GoogleFonts.lato(
                        //                       textStyle: const TextStyle(
                        //                           color: Colors.redAccent))),
                        //             ),
                        //             TextButton(
                        //               onPressed: () {
                        //                 if (refundFormKey.currentState!
                        //                     .validate()) {
                        //                   context
                        //                       .read<OrdersCubit>()
                        //                       .refundOrder(
                        //                         orderID: theOrderID!,
                        //                         refundReason:
                        //                             refundReasonController.text,
                        //                       );
                        //                   Navigator.pop(context);
                        //                   refundReasonController.clear();
                        //                 }
                        //               },
                        //               child: Text(
                        //                 AppLocalizations.of(context)
                        //                     .translate('send'),
                        //                 style: GoogleFonts.lato(
                        //                     textStyle: const TextStyle(
                        //                         color: Colors.black)),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   text: AppLocalizations.of(context)
                        //       .translate('refund_order'),
                        // ),
                        if (_refundRemainingTime > 0) ...[
                          defaultButton(
                            background: Colors.orange,
                            function: () {
                              final GlobalKey<FormState> refundFormKey =
                                  GlobalKey<FormState>();
                              showDialog(
                                context: context,
                                builder: (context) => Form(
                                  key: refundFormKey,
                                  child: AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(AppLocalizations.of(context)
                                        .translate('refund_order')),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppLocalizations.of(context)
                                            .translate('refund_reason_hint')),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: refundReasonController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return AppLocalizations.of(
                                                      context)
                                                  .translate(
                                                      'please_enter_reason');
                                            }
                                            if (value.trim().length < 10) {
                                              return AppLocalizations.of(
                                                      context)
                                                  .translate(
                                                      'reason_too_short');
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                AppLocalizations.of(context)
                                                    .translate('write_reason'),
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                            AppLocalizations.of(context)
                                                .translate('cancel'),
                                            style: GoogleFonts.lato(
                                                textStyle: const TextStyle(
                                                    color: Colors.redAccent))),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (refundFormKey.currentState!
                                              .validate()) {
                                            context
                                                .read<OrdersCubit>()
                                                .refundOrder(
                                                  orderID: theOrderID!,
                                                  refundReason:
                                                      refundReasonController
                                                          .text,
                                                );
                                            Navigator.pop(context);
                                            refundReasonController.clear();
                                          }
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)
                                              .translate('send'),
                                          style: GoogleFonts.lato(
                                              textStyle: const TextStyle(
                                                  color: Colors.black)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            text: AppLocalizations.of(context)
                                .translate('refund_order'),
                          ),
                        ],
                      ],
                    )
                  else if ((orderStatus == 1 ||
                          orderStatus == 2 ||
                          orderStatus == 3) &&
                      _remainingTime > 0)
                    Column(
                      children: [
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            AppLocalizations.of(context)
                                .translate('order cancel notify'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context).translate("Time remaining")}: ${_formatTime(_remainingTime)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        defaultButton(
                          background: Colors.red,
                          function: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)
                                      .translate('cancel order')),
                                  content: Text(AppLocalizations.of(context)
                                      .translate('confirm_cancel_order')),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(AppLocalizations.of(context)
                                          .translate('no')),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        BlocProvider.of<OrdersCubit>(context)
                                            .deleteOrder(theOrderID!);
                                        setState(() {
                                          isOrderDeleted = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(AppLocalizations.of(context)
                                          .translate('yes')),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          text: AppLocalizations.of(context)
                              .translate('cancel order'),
                        ),
                      ],
                    )
                  else if ((orderStatus == 1 || orderStatus == 2
                      // ||orderStatus == 3
                      ) &&
                      _remainingTime <= 0)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        defaultButton(
                          background: Colors.grey,
                          function: () {
                            navigateTo(context, EditOrderScreen(order: order));
                          },
                          text: AppLocalizations.of(context)
                              .translate('edit_order'),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),
          );
        } else if (state is GetOrdersFaluire) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              title: Text(AppLocalizations.of(context).translate('order details')),
              actions: const [HomeButton()],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      state.getOrdersFaluireMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => triggerOrderCubit(),
                    child: Text(AppLocalizations.of(context).translate("Retry")),
                  )
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              title: Text(
                AppLocalizations.of(context).translate('order details'),
              ),
              actions: const [
                HomeButton(),
              ],
            ),
            body: Center(
              child:
                  Text(AppLocalizations.of(context).translate("empty order")),
            ),
          );
        }
      },
    );
  }
}
