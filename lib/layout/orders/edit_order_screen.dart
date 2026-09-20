import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vegesea/cubits/all_products_cubit/all_products_cubit.dart';
import 'package:vegesea/cubits/orders_cubit/orders_cubit.dart';
import 'package:vegesea/models/all_products_model.dart' as all_products;
import 'package:vegesea/models/one_order_model.dart' as one_order;
import 'package:vegesea/shared/shared/app_localization.dart';
import 'package:vegesea/shared/shared/components/components.dart';

class EditOrderScreen extends StatefulWidget {
  final one_order.Data order;
  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late List<one_order.Products> localProducts;
  final TextEditingController _searchController = TextEditingController();
  List<all_products.Data> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Fetch all products to be ready for adding new ones
    context.read<AllProductsCubit>().getAllProducts();
    // Deep copy products to avoid modifying the original order model directly until saved
    localProducts = widget.order.products?.map((p) {
          return one_order.Products(
            id: p.id,
            realPrice: p.realPrice,
            price: p.price,
            photo: p.photo,
            title: p.title,
            titleEn: p.titleEn,
            titleAr: p.titleAr,
            pivot: one_order.Pivot(
              orderId: p.pivot?.orderId,
              productId: p.pivot?.productId,
              price: p.pivot?.price,
              amount: p.pivot?.amount,
              packaging: p.pivot?.packaging,
              id: p.pivot?.id,
              packagingPrice: p.pivot?.packagingPrice,
            ),
          );
        }).toList() ??
        [];
  }

  void _incrementAmount(int index) {
    setState(() {
      localProducts[index].pivot!.amount =
          (localProducts[index].pivot!.amount ?? 0) + 1;
    });
  }

  void _decrementAmount(int index) {
    setState(() {
      if ((localProducts[index].pivot!.amount ?? 0) > 1) {
        localProducts[index].pivot!.amount =
            (localProducts[index].pivot!.amount ?? 0) - 1;
      }
    });
  }

  void _removeProduct(int index) {
    setState(() {
      localProducts.removeAt(index);
    });
  }

  void _addProduct(all_products.Data p, {int packaging = 0}) {
    setState(() {
      int existingIndex = localProducts.indexWhere((item) =>
          item.id == p.id && (item.pivot?.packaging ?? 0) == packaging);
      if (existingIndex != -1) {
        localProducts[existingIndex].pivot!.amount =
            (localProducts[existingIndex].pivot!.amount ?? 0) + 1;
      } else {
        int packagingPrice = 0;
        if (packaging == 1 && p.packaging != null) {
          packagingPrice = double.tryParse(p.packaging!)?.toInt() ?? 0;
        }

        localProducts.add(one_order.Products(
          id: p.id,
          realPrice: p.realPrice,
          price: p.price,
          photo: p.photo,
          titleEn: p.titleEn,
          titleAr: p.titleAr,
          pivot: one_order.Pivot(
            productId: p.id,
            amount: 1,
            packaging: packaging,
            price: p.price,
            packagingPrice: packagingPrice,
          ),
        ));
      }
    });
    Navigator.pop(context);
    showSnackBarMessage(context,
        AppLocalizations.of(context).translate('added to cart'), kMainColor, Icons.check);
  }

  void _showAddProductBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).translate('add to cart'),
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    final cubit = context.read<AllProductsCubit>();
                    if (cubit.state is AllProductsSuccess) {
                      final products = (cubit.state as AllProductsSuccess)
                          .allProductsModel
                          .data;
                      setModalState(() {
                        _filteredProducts = products?.where((p) {
                              final title = (AppLocalizations.of(context)
                                              .locale
                                              .languageCode ==
                                          'en'
                                      ? p.titleEn
                                      : p.titleAr) ??
                                  '';
                              return title
                                  .toLowerCase()
                                  .contains(value.toLowerCase());
                            }).toList() ??
                            [];
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('SEARCH'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AllProductsCubit, AllProductsState>(
                  builder: (context, state) {
                    if (state is AllProductsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AllProductsSuccess) {
                      final allProductsList = state.allProductsModel.data ?? [];
                      final displayList = _searchController.text.isEmpty
                          ? allProductsList
                          : _filteredProducts;

                      if (displayList.isEmpty) {
                        return Center(
                          child: Text(AppLocalizations.of(context)
                              .translate('orders empty')),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final product = displayList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.photo ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade100,
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (AppLocalizations.of(context)
                                                        .locale
                                                        .languageCode ==
                                                    'en'
                                                ? product.titleEn
                                                : product.titleAr) ??
                                            '',
                                        style: GoogleFonts.lato(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${product.price} LE',
                                        style:
                                            const TextStyle(color: kMainColor),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    //if (product.isPackaging == 1) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        title: Text(AppLocalizations.of(context)
                                            .translate('Select Type')),
                                        children: [
                                          SimpleDialogOption(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _addProduct(product,
                                                  packaging: 0);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                  AppLocalizations.of(context)
                                                      .translate('Normal')),
                                            ),
                                          ),
                                          SimpleDialogOption(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _addProduct(product,
                                                  packaging: 1);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(AppLocalizations.of(
                                                      context)
                                                  .translate('Vacuum Packed')),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add_circle,
                                      color: kMainColor),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else if (state is AllProductsFailure) {
                      return Center(child: Text(state.error));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitEdit() {
    final Map<String, dynamic> body = {
      "order_id": widget.order.id,
      "address_id": int.tryParse(widget.order.addressId ?? '0') ?? 0,
      // "payment_type": widget.order.paidType == 1
      //     ? "cash"
      //     : "online", // Adjust based on app logic
      "payment_type": "cash",
      "delivery_type": widget.order.deliveryType ?? 0,
      "products": localProducts.map((p) {
        return {
          "id": p.id,
          "amount": p.pivot?.amount,
          "packaging": p.pivot?.packaging ?? 0,
        };
      }).toList(),
    };

    context.read<OrdersCubit>().editOrder(body);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state is EditOrderLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is EditOrderSuccess) {
          Navigator.pop(context); // Close loading dialog
          showSnackBarMessage(context, state.message, Colors.green, Icons.check);
          Navigator.pop(context); // Go back to order details
          context.read<OrdersCubit>().getOneOrdere(widget.order.id!);
        } else if (state is EditOrderFaluire) {
          Navigator.pop(context); // Close loading dialog
          // Error message is displayed as a banner in the UI
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
            title: Text(
              AppLocalizations.of(context).translate('edit_order'),
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            actions: [
              // const HomeButton(),
              IconButton(
                onPressed: _showAddProductBottomSheet,
                icon: const Icon(Icons.add_shopping_cart, color: kMainColor),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: defaultButton(
              function: localProducts.isEmpty ? null : _submitEdit,
              text: AppLocalizations.of(context).translate('save changes'),
              background: localProducts.isEmpty ? Colors.grey : kMainColor,
            ),
          ),
          body: Column(
            children: [
              if (state is EditOrderFaluire)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.message.replaceAll("Exception: ", ""),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: localProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('Your cart is empty'),
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: localProducts.length,
                        itemBuilder: (context, index) {
                          final product = localProducts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: product.photo != null &&
                                            product.photo!.isNotEmpty
                                        ? Image.network(
                                            product.photo!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey.shade100,
                                              child: const Icon(
                                                  Icons.image_not_supported),
                                            ),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey.shade100,
                                            child: const Icon(
                                                Icons.image_not_supported),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)
                                                      .locale
                                                      .languageCode ==
                                                  'en'
                                              ? (product.titleEn ??
                                                  product.titleAr ??
                                                  '')
                                              : (product.titleAr ??
                                                  product.titleEn ??
                                                  ''),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '${(double.tryParse(product.pivot?.price ?? product.price ?? '0') ?? 0) + (product.pivot?.packaging == 1 ? (product.pivot?.packagingPrice ?? 0) : 0)} LE',
                                              style: const TextStyle(
                                                color: kMainColor,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (product.pivot?.packaging == 1)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          "Vacuum Packed"),
                                                  style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildActionButton(
                                              icon: Icons.remove,
                                              onTap: () =>
                                                  _decrementAmount(index),
                                              color: Colors.grey.shade100,
                                              iconColor: Colors.black,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Text(
                                                '${product.pivot?.amount ?? 0}',
                                                style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            _buildActionButton(
                                              icon: Icons.add,
                                              onTap: () =>
                                                  _incrementAmount(index),
                                              color: kMainColor.withValues(
                                                  alpha: 0.1),
                                              iconColor: kMainColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeProduct(index),
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
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
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
