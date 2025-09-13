  import 'package:carousel_slider/carousel_slider.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:go_router/go_router.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/router/route_names.dart';
  import 'package:maktub/data/models/carousel.dart';
import 'package:maktub/data/models/category.dart';
  import 'package:maktub/presentation/user/blocs/ad/ad_bloc.dart';
  import 'package:maktub/presentation/user/blocs/ad/ad_state.dart';
import 'package:maktub/presentation/user/screens/product/product_list_bottom_sheet.dart';
import 'package:maktub/presentation/user/widgets/common/bottom_sheet_type_mismatch.dart';
import 'package:maktub/presentation/user/widgets/common/seller_bottom_sheet.dart';
  import 'package:shimmer/shimmer.dart';

  class Carousel extends StatelessWidget {
    final     Map<Category, List<Category>> subcategories;
    const Carousel({super.key, required this.subcategories});

void _handleBannerTap(BuildContext context, CarouselModel banner) {
  final type = banner.onTap?.type;
  final url = banner.onTap?.url;
  final target = banner.onTap?.target;

  if (type == null || target == null) return;

  switch (type) {
    case 'openWebViewBottomSheet':
    showWebViewBottomSheet(context, url!,  banner.onTap!.title!);
      break;

    case 'openSupplierBottomSheet':
  
      String title = banner.onTap!.title!;
                 showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                        ),
                                        builder:
                                            (_) =>ProductBottomSheetScreen(
                            title: title,
                            // brandId: selectedBrandId,
                            supplierId: target,
                          ),
                                      );
                               
      break;

    case 'openBrandBottomSheet':
      String title = banner.onTap!.title!;
                 showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                        ),
                                        builder:
                                            (_) =>ProductBottomSheetScreen(
                            title: title,
                            // brandId: selectedBrandId,
                            brandId: target,
                          ),
                                      );
      break;

    case 'navigateCategory':
      final title = banner.onTap?.titleRu ?? 'вам понравится';
      final parentId = banner.onTap?.parentCategoryId ?? 1;
      // ignore: unnecessary_null_comparison
      final subcats = parentId != null
    ? (subcategories.entries
        .firstWhere(
          (entry) => entry.key.id == parentId,
          orElse: () => MapEntry(Category(id: -1, name: '', nameRu: ''), []),
        )
        .value)
    : [];
         context.replaceNamed(
                        'productList',
                        extra: {
                          'categoryId': target,
                          'subcategories': subcats,
                          'title': title,
                          
                        },
                      );
      break;

    case 'openRegisterSupplierBottomSheet':
    showRegisterSupplierBottomSheet(context);
    break;
    default:
      // optionally log unknown type
      break;
  }
}

    @override
    Widget build(BuildContext context) { 
      return BlocBuilder<AdBloc, AdState>(
        builder: (context, state) {
          if (state is CarouselLoading) {
            return CarouselSlider.builder(
              itemCount: 2,
              options: CarouselOptions(height: 150,  viewportFraction: 0.9,                enlargeCenterPage: true,),
              itemBuilder: (context, index, _) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade200,
                  child: Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 0),
                    // height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          } else if (state is CarouselLoaded) {
            return CarouselSlider.builder(
              itemCount: state.banners.length,
              options: CarouselOptions(
                autoPlayInterval: const Duration(seconds: 3),
                height: 150,
                autoPlay: true,
                enlargeCenterPage: true,

                viewportFraction: 0.9,
                      enableInfiniteScroll: true, // убедись, что включено
      scrollPhysics: const BouncingScrollPhysics(),
              ),
              itemBuilder: (context, index, _) {
                  if (index >= state.banners.length) return const SizedBox();
                final banner = state.banners[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,

                  onTap: () => _handleBannerTap(context, banner),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:FadingImage(url: banner.imageUrl)

                  ),
                );
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    }
  }


class FadingImage extends StatefulWidget {
  final String url;

  const FadingImage({super.key, required this.url});

  @override
  State<FadingImage> createState() => _FadingImageState();
}

class _FadingImageState extends State<FadingImage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Цветная заглушка
        Container(
          color: Colors.grey.shade300,
          width: double.infinity,
          height: double.infinity,
        ),

        // Картинка
        AnimatedOpacity(
          opacity: _loaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          child: Image.network(
            widget.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
 loadingBuilder: (context, child, loadingProgress) {
  if (loadingProgress == null) {
    if (!mounted) return child; // ✅ защита
    Future.microtask(() {
      if (mounted) setState(() => _loaded = true); // ✅ защита
    });
  }
  return child;
},

          ),
        ),
      ],
    );
  }
}
