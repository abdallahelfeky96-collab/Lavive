// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vegesea/cubits/cart_cubit/cart_cubit.dart';
// import 'package:vegesea/models/one_product_model.dart';

// Widget buildAddToCartButton(BuildContext context, ProductModel product) {
//   return IconButton(
//     icon: const Icon(Icons.add_shopping_cart),
//     onPressed: () {
//       context.read<CartCubit>().addProduct(product);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Product added to cart'),
//           duration: Duration(seconds: 1),
//         ),
//       );
//     },
//   );
// }
