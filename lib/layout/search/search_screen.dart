import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vegesea/cubits/search_cubit/search_cubit.dart';
import 'package:vegesea/layout/product_screen/product_screen.dart';
import 'package:vegesea/shared/shared/components/components.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        actions: const [
          HomeButton(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: _searchController,
              onChanged: (value) {
                context.read<SearchCubit>().searchProducts(value);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchError) {
                  return Center(child: Text(state.message));
                } else if (state is SearchSuccess) {
                  final results = state.searchResults;
                  if (results.isEmpty) {
                    return const Center(child: Text('No results found'));
                  } else {
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final product = results[index];
                        return GestureDetector(
                          onTap: () {
                            navigateTo(
                                context,
                                ProductScreen(
                                    productID: product.id.toString()));
                          },
                          child: ListTile(
                            title: Text(
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                product.myTitle ?? 'No Title'),
                            subtitle: Text(
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                                product.myDescription ?? 'No Description'),
                            leading: CachedNetworkImage(
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                imageUrl: product.photo!),
                          ),
                        );
                      },
                    );
                  }
                }
                return const Center(child: Text('Start typing to search...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
