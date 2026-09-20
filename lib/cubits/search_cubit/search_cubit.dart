import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vegesea/models/all_products_model.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final List<Data>? products;

  SearchCubit({this.products}) : super(SearchInitial());

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      if (products == null) {
        emit(const SearchError('No products available'));
        return;
      }

      final searchResults = products!.where((product) {
        final titleMatch =
            product.myTitle?.toLowerCase().contains(query.toLowerCase()) ??
                false;
        final descMatch = product.myDescription
                ?.toLowerCase()
                .contains(query.toLowerCase()) ??
            false;

        return titleMatch;
      }).toList();

      emit(SearchSuccess(searchResults));
    } catch (e) {
      emit(SearchError('Error searching products: ${e.toString()}'));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}
