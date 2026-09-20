import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:vegesea/models/one_product_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  // void addProduct(ProductModel product) {
  //   if (state is CartSuccess) {
  //     final currentProducts = (state as CartSuccess).products;
  //     final existingProductIndex =
  //         currentProducts.indexWhere((p) => p.data?.id == product.data?.id);

  //     if (existingProductIndex != -1) {
  //       final updatedProducts = List<ProductModel>.from(currentProducts);
  //       updatedProducts[existingProductIndex].data?.quantity =
  //           product.data?.quantity ?? 1;
  //       emit(CartSuccess(updatedProducts));
  //     } else {
  //       final updatedProducts = List<ProductModel>.from(currentProducts)
  //         ..add(product);
  //       emit(CartSuccess(updatedProducts));
  //     }
  //   } else {
  //     emit(CartSuccess([product]));
  //   }

  //   saveCartToStorage();
  // }

  void addProduct(ProductModel product) {
    if (state is CartSuccess) {
      final currentProducts =
          List<ProductModel>.from((state as CartSuccess).products);

      // Find existing product with SAME id AND SAME packaging type
      final productIsPackaging = product.data?.isPackaging ?? 0;
      final existingProductIndex = currentProducts.indexWhere((p) =>
          p.data?.id == product.data?.id &&
          (p.data?.isPackaging ?? 0) == productIsPackaging);

      if (existingProductIndex != -1) {
        // Product exists, update quantity
        final existingProduct = currentProducts[existingProductIndex];

        // We create a new Data object if we want to be safe, but let's just update the field
        // as the Cubit state is being replaced anyway.
        double oldQuantity = existingProduct.data?.quantity ?? 0.0;
        double addedQuantity = product.data?.quantity ?? 1.0;
        existingProduct.data?.quantity = oldQuantity + addedQuantity;

        emit(const CartSuccess([])); // Force rebuild in some cases
        emit(CartSuccess(currentProducts));
      } else {
        // Add as new item
        currentProducts.add(product);
        emit(CartSuccess(currentProducts));
      }
    } else {
      emit(CartSuccess([product]));
    }

    saveCartToStorage();
  }

  void updateQuantity(ProductModel product, double change) {
    if (state is CartSuccess) {
      final currentProducts =
          List<ProductModel>.from((state as CartSuccess).products);
      final index =
          currentProducts.indexWhere((p) => p.data?.id == product.data?.id);

      if (index != -1) {
        final newQuantity =
            (currentProducts[index].data?.quantity ?? 1.0) + change;
        if (newQuantity > 0) {
          currentProducts[index].data?.quantity = newQuantity;
          emit(const CartSuccess([]));
          emit(CartSuccess(currentProducts));
          saveCartToStorage();
        }
      }
    }
  }

  // void removeProduct(ProductModel product) {
  //   if (state is CartSuccess) {
  //     final updatedProducts =
  //         List<ProductModel>.from((state as CartSuccess).products)
  //           ..removeWhere((p) => p.data?.id == product.data?.id);
  //     emit(CartSuccess(updatedProducts));
  //     saveCartToStorage();
  //   }
  // }
  void removeProduct(ProductModel product) {
    if (state is CartSuccess) {
      final updatedProducts =
          List<ProductModel>.from((state as CartSuccess).products)
            ..removeWhere((p) =>
                p.data?.id == product.data?.id &&
                p.data?.isPackaging == product.data?.isPackaging);
      emit(CartSuccess(updatedProducts));
      saveCartToStorage();
    }
  }

  Future<void> saveCartToStorage() async {
    if (state is CartSuccess) {
      final box = Hive.box('cartBox');
      await box.put('cartItems', (state as CartSuccess).products);
    }
  }

  Future<void> loadCartFromStorage() async {
    final box = Hive.box('cartBox');
    final cartItems = box.get('cartItems', defaultValue: <ProductModel>[]);

    if (cartItems is List) {
      final products = cartItems.cast<ProductModel>();
      emit(CartSuccess(products));
    } else {
      emit(const CartSuccess([]));
    }
  }

  // void addProduct(ProductModel product) {
  //   if (state is CartSuccess) {
  //     final currentProducts = (state as CartSuccess).products;
  //     final existingProductIndex =
  //     currentProducts.indexWhere((p) => p.data?.id == product.data?.id);

  //     if (existingProductIndex != -1) {
  //       // Product exists, update quantity
  //       final updatedProducts = List<ProductModel>.from(currentProducts);
  //       updatedProducts[existingProductIndex].data?.quantity =
  //           product.data?.quantity ?? 1;
  //       emit(CartSuccess(updatedProducts));
  //     } else {
  //       // New product
  //       final updatedProducts = List<ProductModel>.from(currentProducts)
  //         ..add(product);
  //       emit(CartSuccess(updatedProducts));
  //     }
  //   } else {
  //     // First product in cart
  //     emit(CartSuccess([product]));
  //   }
  // }

  // void updateQuantity(ProductModel product, int change) {
  //   if (state is CartSuccess) {
  //     final currentProducts =
  //     List<ProductModel>.from((state as CartSuccess).products);
  //     final index =
  //     currentProducts.indexWhere((p) => p.data?.id == product.data?.id);

  //     if (index != -1) {
  //       final newQuantity =
  //           (currentProducts[index].data?.quantity ?? 1) + change;
  //       if (newQuantity > 0) {
  //         currentProducts[index].data?.quantity = newQuantity;
  //         // Force emit new state
  //         emit(const CartSuccess([])); // Temporary state
  //         emit(CartSuccess(currentProducts)); // Final state
  //       }
  //     }
  //   }
  // }

  // void removeProduct(ProductModel product) {
  //   if (state is CartSuccess) {
  //     final updatedProducts =
  //     List<ProductModel>.from((state as CartSuccess).products)
  //       ..removeWhere((p) => p.data?.id == product.data?.id);
  //     emit(CartSuccess(updatedProducts));
  //   }
  // }

  String get totalPrice {
    if (state is CartSuccess) {
      double total = 0;
      for (var product in (state as CartSuccess).products) {
        double price = double.tryParse(product.data?.price ?? '0') ?? 0;
        double quantity = product.data?.quantity ?? 1.0;
        total += price * quantity;
      }
      return total.toStringAsFixed(2);
    }
    return '0.00';
  }

  void clearCart() async {
    final box = await Hive.openBox('cartBox');
    box.clear();
    emit(const CartSuccess([]));
  }

  // Future<void> loadCartFromStorage() async {
  //   final box = await Hive.openBox('cartBox');
  //   final cartItems = box.get('cartItems') as List<ProductModel>? ?? [];
  //   emit(CartSuccess(cartItems));
  // }

  // Future<void> saveCartToStorage() async {
  //   if (state is CartSuccess) {
  //     final box = await Hive.openBox('cartBox');
  //     await box.put('cartItems', (state as CartSuccess).products);
  //   }
  // }
}
