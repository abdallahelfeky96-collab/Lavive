import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vegesea/layout/Auth/login.dart';
import 'package:vegesea/layout/orders/order_detail_screen.dart';
import 'package:vegesea/models/all_orders_model.dart';
import 'package:vegesea/services/orders_services.dart';
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

import '../../shared/shared/constants.dart';
import '../Auth/register.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    this.showBackButton = true,
  });
  final bool showBackButton;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<AllOrdersModel> futureOrders;

  Future<void> _refreshOrders() async {
    setState(() {
      futureOrders = fetchAllOrders();
    });
    await futureOrders;
  }

  @override
  void initState() {
    super.initState();
    futureOrders = fetchAllOrders(); // استدعاء خدمة جلب الطلبات
    log("token===>>$token");
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    return Scaffold(
      floatingActionButton: const MovableFloatingButton(),
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.arrow_back_ios))
            : null,
        title: Text(
          AppLocalizations.of(context).translate("orders"),
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        // actions: const [
        //         HomeButton(),
        //       ],
        centerTitle: true,
      ),
      body: FutureBuilder<AllOrdersModel>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (token == null) {
            return Padding(
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
            );
          } else if (snapshot.hasError) {
            log("FutureBuilder error: ${snapshot.error}");
            log("Error stack trace: ${snapshot.stackTrace}");
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/no-signal.png",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Text(
                            style: const TextStyle(
                                color: Color(0xffF54D40),
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                            AppLocalizations.of(context)
                                .translate("orders load error")),
                        const SizedBox(height: 8),
                        Text(
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                            "${snapshot.error}"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final orders = snapshot.data!.data;
            if (orders == null || orders.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshOrders,
                child: ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                        child: Text(AppLocalizations.of(context)
                            .translate("orders empty"))),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: Padding(
                padding: EdgeInsetsGeometry.only(bottom: 80.h),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return OrderItem(
                      order: orders[index],
                      onRefresh: _refreshOrders,
                    ); // عرض الطلب
                  },
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                    child: Text(AppLocalizations.of(context)
                        .translate("orders empty"))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final Data order;
  final VoidCallback? onRefresh;

  const OrderItem({super.key, required this.order, this.onRefresh});

  String _getStatusText(BuildContext context, int? status) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(
                orderId: order.id!,
                address: order.address?.address ?? "",
              ),
            ),
          );
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id}',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: kMainColor,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(context, order.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    order.createdAt ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.address?.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.productsCount ?? 0} ${AppLocalizations.of(context).translate("products")}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '${order.priceAfterOffer} LE',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
