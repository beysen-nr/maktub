import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/data/models/banner.dart' as banner;
import 'package:maktub/data/models/category.dart';
import 'package:maktub/presentation/user/screens/product/product_list_bottom_sheet.dart';

class BannerWidget extends StatelessWidget {
  final banner.Banner model;
  final Map<Category, List<Category>> subcategories;
  const BannerWidget({
    super.key,
    required this.model,
    required this.subcategories,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (model.onTap != null) {
          handleOnTapAction(context, model.onTap!);
        }
      },
      child: AspectRatio(
        aspectRatio: 4.6,
        child: FadingImage(url: model.imageUrl),
      ),
    );
  }

  void handleOnTapAction(BuildContext context, banner.OnTapAction action) {

    switch (action.target) {
      case 'productList':
        final parentId = action.params?['parentCategoryId'];
        final subcats =
            parentId != null
                ? (subcategories.entries
                    .firstWhere(
                      (entry) => entry.key.id == parentId,
                      orElse:
                          () => MapEntry(
                            Category(id: -1, name: '', nameRu: ''),
                            [],
                          ),
                    )
                    .value)
                : [];

        context.goNamed(
          'productList',
          extra: {
            'categoryId': action.params?['categoryId'],
            'title': action.params?['title'] ?? '',
            'subcategories': subcats,
          },
        );
        break;

      case 'brandBottomSheet':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder:
              (_) => ProductBottomSheetScreen(
                title: action.params?['title'] ?? '',
                // brandId: selectedBrandId,
                brandId: action.params?['brandId'],
              ),
        );

        break;

      case 'supplierBottomSheet':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder:
              (_) => ProductBottomSheetScreen(
                title: action.params?['title'] ?? '',
                // brandId: selectedBrandId,
                supplierId: action.params?['supplierId'],
              ),
        );

        break;

      // Добавь другие case если нужно
      default:
        break;
    }
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
        Container(
          color: Colors.grey.shade300,
          width: double.infinity,
          height: double.infinity,
        ),
        AnimatedOpacity(
          opacity: _loaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Image.network(
            widget.url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                Future.microtask(() {
                  if (mounted) setState(() => _loaded = true);
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
