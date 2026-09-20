import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vegesea/cubits/banners_cubit/banners_cubit.dart';
import 'package:vegesea/layout/home/sliding_details.dart';
import 'package:vegesea/models/banners_model.dart' as banner_model;
import 'package:vegesea/shared/shared/components/components.dart';

class SlidingItem extends StatefulWidget {
  const SlidingItem({super.key});

  @override
  State<SlidingItem> createState() => _SlidingItemState();
}

class _SlidingItemState extends State<SlidingItem> {
  final ScrollController _scrollController = ScrollController();
  bool _scrolling = true;

  @override
  void initState() {
    super.initState();
    context.read<BannersCubit>().getBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() async {
    while (_scrolling) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 0) {
            await _scrollToEnd();
          } else {
            await _scrollToStart();
          }
        } else {
          await _scrollToEnd();
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _scrollToEnd() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 5),
        curve: Curves.linear,
      );
    }
  }

  Future<void> _scrollToStart() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(seconds: 5),
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    _scrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBannerItem(banner_model.Data banner, {bool isAsset = false}) {
    return GestureDetector(
      onTap: () {
        if (!isAsset) {
          navigateTo(context, SlidingDetails(banner: banner));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          width: 320.w,
          height: 200.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Hero(
              tag: 'banner_${banner.id}',
              child: isAsset
                  ? Image.asset(
                      banner.photo ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: banner.photo ?? "",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, state) {
        final cubit = context.read<BannersCubit>();

        if (state is BannersLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: SizedBox(
              height: 200.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 320.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is BannersSuccess) {
          final banners = state.bannersModel.data;

          if (banners == null || banners.isEmpty) {
            return _buildStaticBanners();
          }

          return SizedBox(
            height: 200.h,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                return _buildBannerItem(
                  banners[index],
                );
              },
            ),
          );
        } else if (state is BannersFailure) {
          if (cubit.cachedBanners?.data?.isNotEmpty == true) {
            final cachedBanners = cubit.cachedBanners!.data!;
            return SizedBox(
              height: 200.h,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: cachedBanners.length,
                itemBuilder: (context, index) {
                  return _buildBannerItem(
                    cachedBanners[index],
                  );
                },
              ),
            );
          } else {
            return _buildStaticBanners();
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStaticBanners() {
    final List<banner_model.Data> staticBanners = [
      banner_model.Data(
          id: -1,
          photo: "assets/images/banner1.png",
          myTitle: "Offer 1",
          myDescription: "Description 1"),
      banner_model.Data(
          id: -2,
          photo: "assets/images/banner2.png",
          myTitle: "Offer 2",
          myDescription: "Description 2"),
      banner_model.Data(
          id: -3,
          photo: "assets/images/banner3.png",
          myTitle: "Offer 3",
          myDescription: "Description 3"),
      banner_model.Data(
          id: -4,
          photo: "assets/images/banner4.png",
          myTitle: "Offer 4",
          myDescription: "Description 4"),
    ];

    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: staticBanners.length,
        itemBuilder: (context, index) {
          return _buildBannerItem(
            staticBanners[index],
            isAsset: true,
          );
        },
      ),
    );
  }
}
