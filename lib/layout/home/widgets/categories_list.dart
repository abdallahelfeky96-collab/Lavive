import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vegesea/cubits/get_categories_cubit/get_categories_cubit.dart';
import 'package:vegesea/layout/home/widgets/sub_categories_grid.dart';

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key, required this.scrollDirection});
  final Axis scrollDirection;

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  @override
  void initState() {
    final cubit = BlocProvider.of<GetCategoriesCubit>(context);
    if (cubit.state is! GetCategoriesSuccess) {
      cubit.getCategories();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<GetCategoriesCubit, GetCategoriesState>(
      builder: (context, state) {
        final cubit = BlocProvider.of<GetCategoriesCubit>(context);
        if (state is GetCategoriesLoaging) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: isPortrait ? 0.6 : 0.8,
                crossAxisCount: isPortrait ? 3 : 6,
                mainAxisSpacing: size.height * 0.001,
                crossAxisSpacing: size.width * 0.01,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: widget.scrollDirection,
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(size.width * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height * 0.1,
                        width: size.width * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        height: size.height * 0.02,
                        width: size.width * 0.15,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: size.height * 0.005),
                      Container(
                        height: size.height * 0.02,
                        width: size.width * 0.2,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        } else if (state is GetCategoriesSuccess) {
          final categories = state.categories.data;
          if (categories == null || categories.isEmpty) {
            return const Center(child: Text('No categories available'));
          }
          if ((categories.isEmpty)) {
            return const Center(child: Text('No categories found'));
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: isPortrait ? 0.6 : 0.8,
              crossAxisCount: isPortrait ? 3 : 6,
              mainAxisSpacing: size.height * 0.001,
              crossAxisSpacing: size.width * 0.01,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: widget.scrollDirection,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubCategoriesGrid(
                        subNumber: category.id!,
                        subName: category.title!,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.015),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: category.photo ?? "",
                        height: size.height * 0.1,
                        width: size.width * 0.25,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) {
                          return Icon(Icons.error, size: size.width * 0.06);
                        },
                      ),
                      Text(
                        category.title!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is GetCategoriesFaluire) {
          // Check if there are cached categories
          if (cubit.cachedCategories != null &&
              cubit.cachedCategories!.data!.isNotEmpty) {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: isPortrait ? 0.6 : 0.8,
                crossAxisCount: isPortrait ? 3 : 6,
                mainAxisSpacing: size.height * 0.001,
                crossAxisSpacing: size.width * 0.01,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: widget.scrollDirection,
              itemCount: cubit.cachedCategories!.data!.length,
              itemBuilder: (context, index) {
                final category = cubit.cachedCategories!.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubCategoriesGrid(
                          subNumber: category.id!,
                          subName: category.title!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: size.width * 0.015),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: category.photo ?? "",
                          height: size.height * 0.1,
                          width: size.width * 0.25,
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) {
                            return Icon(Icons.error, size: size.width * 0.06);
                          },
                        ),
                        Text(
                          category.title!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            // Static grid to display when there are no cached categories
            final List<Map<String, String>> staticCategories = [
              {
                "title": "Vegetables",
                "image": "assets/images/vegetables.png",
              },
              {
                "title": "Leafy Greens",
                "image": "assets/images/leafy_greens.png",
              },
              {
                "title": "Prepped Vegies",
                "image": "assets/images/prepped_veggies.png",
              },
              {
                "title": "Juices",
                "image": "assets/images/juices.png",
              },
              {
                "title": "Fruit Cups",
                "image": "assets/images/fruit_cups.png",
              },
              {
                "title": "Fruits",
                "image": "assets/images/fruits.png",
              },
              {
                "title": "Salads",
                "image": "assets/images/salt.png",
              },
            ];

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: isPortrait ? 0.6 : 0.8,
                crossAxisCount: isPortrait ? 3 : 6,
                mainAxisSpacing: size.height * 0.001,
                crossAxisSpacing: size.width * 0.01,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: widget.scrollDirection,
              itemCount: staticCategories.length,
              itemBuilder: (context, index) {
                final category = staticCategories[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubCategoriesGrid(
                          subNumber: 1,
                          subName: "vegetables",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: size.width * 0.015),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          category["image"]!,
                          height: size.height * 0.1,
                          width: size.width * 0.25,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          category["title"]!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } else {
          return const Center(child: Text('No categories found'));
        }
      },
    );
  }
}

List<CaterogyItem> caterogyItem = [
  CaterogyItem("45 Item", "assets/images/home_icons/fruits.svg", "Fruits",
      const Color.fromRGBO(72, 188, 213, 1), "fruits", '1'),
  CaterogyItem("45 Item", "assets/images/home_icons/fish.svg", "Fish",
      const Color(0xff14AA87), "fish", '2'),
  CaterogyItem("45 Item", "assets/images/home_icons/chicken.svg", "Chicken",
      const Color(0xffA131AD), "chicken", '3'),
  CaterogyItem("45 Item", "assets/images/home_icons/pizzas.svg", "Pizza",
      const Color(0xffAE7156), "pizza", '4'),
  CaterogyItem("45 Item", "assets/images/home_icons/bakery.svg", "Bakery",
      const Color(0xff1BBC5B), "bakery", '5'),
  CaterogyItem("45 Item", "assets/images/home_icons/dairy.svg", "Dairy",
      const Color(0xffE55275), "dairy", '6'),
  CaterogyItem("45 Item", "assets/images/home_icons/mushroom.svg", "Mushroom",
      const Color(0xffEC952E), "mushroom", '7'),
  CaterogyItem("45 Item", "assets/images/home_icons/vegetables.svg",
      "Vegetables", const Color(0xff2D63CD), "vegetables", '8'),
  CaterogyItem("45 Item", "assets/images/home_icons/fruits.svg", "Fruits",
      const Color.fromRGBO(72, 188, 213, 1), "fruits", '9'),
];

class CaterogyItem {
  String caterogyName, caterogyCount, caterogyIcon, screenName, categoryNumber;
  Color color;
  CaterogyItem(this.caterogyCount, this.caterogyIcon, this.caterogyName,
      this.color, this.screenName, this.categoryNumber);
}
