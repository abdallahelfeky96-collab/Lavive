import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vegesea/cubits/notis_cubit/notis_cubit.dart';
import 'package:vegesea/layout/home/widgets/sub_categories_grid.dart';
import 'package:vegesea/layout/orders/order_detail_screen.dart';
import 'package:vegesea/layout/product_screen/product_screen.dart';
import 'package:vegesea/shared/shared/components/components.dart';
import 'package:vegesea/shared/shared/constants.dart';

class NotiItem extends StatefulWidget {
  const NotiItem({
    super.key,
  });

  @override
  State<NotiItem> createState() => _NotiItemState();
}

class _NotiItemState extends State<NotiItem> {
  @override
  void initState() {
    BlocProvider.of<NotisCubit>(context).getAllNotis();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<NotisCubit, NotisState>(
      builder: (context, state) {
        if (state is GetNotisLoading) {
          return ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Container(
                        height: screenWidth * 0.2,
                        width: screenWidth * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: screenWidth * 0.5,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: screenWidth * 0.3,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is GetNotisSuccess) {
          final allNotis = state.allnotis.data!;
          return ListView.builder(
            itemCount: allNotis.length,
            itemBuilder: (context, index) {
              final productID = allNotis[index].productId;
              final categoryID = allNotis[index].categoryId;
              final orderID = allNotis[index].orderId;
              if (productID != null) {
                sharedPreferences!
                    .setInt("product_id_from_notis_screen", productID);
              }
              if (categoryID != null) {
                sharedPreferences!
                    .setInt("category_id_from_notis_screen", categoryID);
              }
              if (orderID != null) {
                sharedPreferences!
                    .setInt("order_id_from_notis_screen", orderID);
              }
              return GestureDetector(
                onTap: () {
                  if (productID != null) {
                    navigateTo(context,
                        ProductScreen(productID: productID.toString()));
                  } else if (categoryID != null) {
                    navigateTo(
                        context, SubCategoriesGrid(subNumber: categoryID));
                  } else if (orderID != null) {
                    navigateTo(context, OrderDetailScreen(orderId: orderID));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      if (allNotis[index].photo != null &&
                          allNotis[index].photo.toString().isNotEmpty &&
                          allNotis[index].photo.toString() != 'null')
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              height: screenWidth * 0.2,
                              width: screenWidth * 0.2,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              imageUrl: allNotis[index].photo.toString(),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allNotis[index].title ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allNotis[index].body ?? '',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              allNotis[index].createdAt ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text("No Notifications"),
          );
        }
      },
    );
  }
}
