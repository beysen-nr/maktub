import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/permission_manager.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/cart_item.dart';
import 'package:maktub/data/models/category.dart';
import 'package:maktub/data/models/product.dart';
import 'package:maktub/data/models/supplier_product.dart';
import 'package:maktub/presentation/blocs/auth/user_role.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/product/product_list_bottom_sheet.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timezone/timezone.dart' as tz;

class ProductCard extends StatelessWidget {
  final Product product;
  final int organizationId;
  final Map<Category, List<Category>> categoriesMap;
  ProductCard({
    super.key,
    required this.product,
    required this.organizationId,
    required this.categoriesMap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        double quantity = 0;
        int? cartItemId;
        final String unitLabel = product.unit == 1 ? 'шт' : 'кг';
        final String quantityText = product.unit == 1
            ? product.quantity.toInt().toString()
            : product.quantity.toString();

        if (cartState is CartLoaded) {
          final match = cartState.items.firstWhereOrNull(
            (e) => e.item.productId == product.productId,
          );

          if (match != null) {
            quantity = match.item.quantity;
            cartItemId = match.item.id;
          }
        }

        return GestureDetector(
          onTap: () {
            showProductBottomSheet(context, product);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: FadeInNetworkImage(
                    imageUrl: product.imageUrl.first,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    product.productNameRu.toLowerCase(),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(product.price * product.quantity).toInt()}₸ / $quantityText $unitLabel',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Gradients.detailTextColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text( AppLocalizations.of(context)!.price,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Gradients.detailTextColor,
                            ),
                          ),
                          Text(
                            product.supplierName,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Gradients.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: quantity == 0
                            ? ElevatedButton(
                                onPressed: () async {
                                  showProductBottomSheet(context, product);
                                },
                                style: ButtonStyle(
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.grey.withOpacity(0.15),
                                  ),
                                  fixedSize: WidgetStateProperty.all(
                                    const Size(130, 45),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product.price.toInt()}₸',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Gradients.productTextColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Gradients.primary,
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  context.go(RouteNames.cart);
                                },
                                style: ButtonStyle(
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Gradients.primary,
                                    // Colors.grey.withOpacity(0.15)
                                  ),
                                  fixedSize: WidgetStateProperty.all(
                                    const Size(130, 45),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                       AppLocalizations.of(context)!.inCart,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
  }

  Color _getHeaderColor(int index) {
    const colors = [
      Gradients.primary,

      Colors.amber,
      Colors.pink,
      // Colors.greenAccent,
    ];
    return colors[index % colors.length];
  }

  void showProductBottomSheet(BuildContext parentContext, Product product) {
    int currentImageIndex = 0;
    final pageController = PageController();
    final controller = DraggableScrollableController();
    late final Map<Category, List<Category>> categoriesMap;

    final productDetailsBloc = ProductBloc(repository: parentContext.read());
    productDetailsBloc.add(
      LoadBothProductAndSuppliers(
        regionId: product.regionId,
        categoryId: product.categoryId,
        productId: product.productId,
      ),
    );

    final cartBloc = parentContext.read<CartBloc>();
    categoriesMap = parentContext.read<AppStateCubit>().state?.categories ?? {};

    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.5),
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: productDetailsBloc,
          child: BlocProvider.value(
            value: cartBloc,
            child: DraggableScrollableSheet(
              controller: controller,
              initialChildSize: 0.93,
              minChildSize: 0.9,
              maxChildSize: 0.93,
              expand: false,
              builder: (context, scrollController) {
                final cartState = context.watch<CartBloc>().state;
                double quantity = 0;
                int? cartItemId;
            
                if (cartState is CartLoaded) {
                  final match = cartState.items.firstWhere(
                    (e) => e.item.productId == product.productId,
                    orElse: () => ValidatedCartItem(
                      item: CartItem(
                        id: -1,
                        productId: product.productId,
                        productName: product.productNameKz,
                        price: product.price,
                        quantity: 0,
                        supplierProductId: 0,
                        supplierId: product.supplierId,
                        supplierName: product.supplierName,
                        organizationId: 0,
                        unit: 1,
                      ),
                      isInStock: true,
                    ),
                  );
                  quantity = match.item.quantity;
                  cartItemId = match.item.id;
                }
            
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: PageView.builder(
                                      controller: pageController,
                                      itemCount: product.imageUrl.length,
                                      onPageChanged: (index) {
                                        currentImageIndex = index;
                                        (context as Element).markNeedsBuild();
                                      },
                                      itemBuilder: (_, index) {
                                        BorderRadius imageRadius =
                                            BorderRadius.zero;
            
                                        if (index == 0) {
                                          imageRadius =
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(12),
                                              );
                                        } else if (index ==
                                            product.imageUrl.length - 1) {
                                          imageRadius =
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(12),
                                              );
                                        }
            
                                        return ClipRRect(
                                          borderRadius: imageRadius,
                                          child: Image.network(
                                            product.imageUrl[index],
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    product.imageUrl.length,
                                    (index) {
                                      final isActive =
                                          index == currentImageIndex;
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width: isActive ? 16 : 8,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              product.productNameKz.toLowerCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                   AppLocalizations.of(context)!.inOneCopy,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MaktubConstants.detailTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                  Text(
                                  product.netContent.toLowerCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MaktubConstants.detailTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                     AppLocalizations.of(context)!.description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Gradients.bigTextColor,
                                    ),
                                  ),
                                  Text(
                                    product.description,
            
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Gradients.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, state) {
                              if (state is ProductCombinedLoaded) {
                                final products = state.products;
                                final suppliers = state.suppliers;
            
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                         AppLocalizations.of(context)!.allSuppliersAndPrices,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...List.generate(suppliers.length, (
                                        index,
                                      ) {
                                        final sp = suppliers[index];
                                        final color = _getHeaderColor(index);
            
                                        bool isInCart = false;
                                        final cartState = context
                                            .watch<CartBloc>()
                                            .state;
                                        if (cartState is CartLoaded) {
                                          isInCart = cartState.items.any(
                                            (validated) =>
                                                validated
                                                    .item
                                                    .supplierProductId ==
                                                sp.spId,
                                          );
                                        }
            
                            
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: 1,
                                          ),
                                          duration: Duration(
                                            milliseconds: 200 + index * 100,
                                          ),
                                          builder: (context, value, child) {
                                            return Opacity(
                                              opacity: value,
                                              child: Transform.translate(
                                                offset: Offset(
                                                  0,
                                                  (1 - value) * 20,
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: SupplierProductCard(
                                              onGoToCart: () {
                                                context.go(RouteNames.cart);
                                              },
                                              product: sp,
                                              headerColor: color,
                                              isInCart: isInCart,
                                              unit: product.unit,
                                              onAddToCart: () {
                                                context.read<CartBloc>().add(
                                                  AddCartItem(
                                                    CartItem(
                                                      id: null,
                                                      unit: product.unit,
                                                      productId:
                                                          product.productId,
                                                      productName: product
                                                          .productNameKz,
                                                      price: sp.price,
                                                      quantity: sp.quantity,
                                                      supplierProductId:
                                                          sp.spId,
                                                      supplierId:
                                                          sp.supplierId,
                                                      supplierName:
                                                          sp.supplierName,
                                                      organizationId:
                                                          organizationId,
                                                    ),
                                                    organizationId,
                                                    products.first.regionId,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }
            
                              return const SizedBox.shrink();
                            },
                          ),
                          BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, state) {
                              if (state is ProductCombinedLoaded) {
                                return HorizontalProductList(
                                  key: const ValueKey('product-bottomsheet'),
                                  filterType: 'category',
                                  filterId: product.categoryId,
                                  title: AppLocalizations.of(context)!.similarProducts,
                                  products: state.products,
                                  organizationId: organizationId,
                                  categoriesMap: categoriesMap,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Transform.rotate(
                                          angle: 3.1416 / 2,
                                          child: Image.asset(
                                            'assets/icons-system/arrow.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
            
                                  // Align(
            
                                  //   alignment: Alignment.centerRight,
                                  //   child: GestureDetector(
                                  //     onTap: product.isInFavorites! ? () {
                                  //       context.read<ProductBloc>().add(AddToFavorites(regionId:product.regionId , organizationId: organizationId, productId: product.productId));
                                  //     }:
                                  //     () {
                                  //       context.read<ProductBloc>().add(DeleteFromFavorites(regionId:product.regionId , organizationId: organizationId, productId: product.productId));
                                  //     }
                                  //      ,
                                  //     child: Container(
                                  //       decoration: const BoxDecoration(
                                  //         color: Colors.transparent,
                                  //         shape: BoxShape.circle,
                                  //       ),
                                  //       child:product.isInFavorites! ?
                                  //       Image.asset(
                                  //         'assets/filledHeart.png',
                                  //         width: 25,
                                  //         height: 25,
                                  //       )
                                  //       : Image.asset(
                                  //         'assets/icons-system/favorites-green.png',
                                  //         width: 25,
                                  //         height: 25,
                                  //       ) ,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class ProductBigCard extends StatelessWidget {
  final String title;
  final Product product;
  final int organizationId;
  final Map<Category, List<Category>> categoriesMap;
  ProductBigCard({
    super.key,
    required this.title,
    required this.product,
    required this.organizationId,
    required this.categoriesMap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        if (cartState is CartLoaded) {
          final match = cartState.items.firstWhere(
            (e) => e.item.productId == product.productId,
            orElse: () => ValidatedCartItem(
              item: CartItem(
                unit: 0,
                id: 0,
                productId: -1,
                supplierProductId: 0,
                supplierId: 0,
                quantity: 0,
                price: 0,
                organizationId: organizationId,
              ),
              isInStock: true,
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            showProductBottomSheet(context, product);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  // border: Border.all(color: Gradients.primary)
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: FadeInNetworkImage(
                        imageUrl: product.imageUrl.first,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: double.infinity * 0.3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                                child: Text(
                                  product.productNameKz.toLowerCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                child: Text(
                                  product.description.toLowerCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              ElevatedButton(
                                onPressed: () async {
                                  showProductBottomSheet(context, product);
                                },
                                style: ButtonStyle(
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.grey.withOpacity(0.15),
                                  ),
                                  fixedSize: WidgetStateProperty.all(
                                    const Size(130, 45),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product.price.toInt()}₸',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Gradients.productTextColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Gradients.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getHeaderColor(int index) {
    const colors = [
      Gradients.primary,

      Colors.amber,
      Colors.pink,
      // Colors.greenAccent,
    ];
    return colors[index % colors.length];
  }

  void showProductBottomSheet(BuildContext parentContext, Product product) {
    int currentImageIndex = 0;
    final pageController = PageController();
    final controller = DraggableScrollableController();
    late final Map<Category, List<Category>> categoriesMap;

    final productDetailsBloc = ProductBloc(repository: parentContext.read());
    productDetailsBloc.add(
      LoadBothProductAndSuppliers(
        regionId: product.regionId,
        categoryId: product.categoryId,
        productId: product.productId,
      ),
    );

    final cartBloc = parentContext.read<CartBloc>();
    categoriesMap = parentContext.read<AppStateCubit>().state?.categories ?? {};
    // cartBloc.add(LoadCart(organizationId, product.regionId));

    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.5),
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: productDetailsBloc,
          child: BlocProvider.value(
            value: cartBloc,
            child: DraggableScrollableSheet(
              controller: controller,
              initialChildSize: 0.93,
              minChildSize: 0.9,
              maxChildSize: 0.93,
              expand: false,
              builder: (context, scrollController) {
                final cartState = context.watch<CartBloc>().state;
                double quantity = 0;
                int? cartItemId;
            
                if (cartState is CartLoaded) {
                  final match = cartState.items.firstWhere(
                    (e) => e.item.productId == product.productId,
                    orElse: () => ValidatedCartItem(
                      item: CartItem(
                        id: -1,
                        productId: product.productId,
                        productName: product.productNameKz,
                        price: product.price,
                        quantity: 0,
                        supplierProductId: 0,
                        supplierId: product.supplierId,
                        supplierName: product.supplierName,
                        organizationId: 0,
                        unit: 1,
                      ),
                      isInStock: true,
                    ),
                  );
                  quantity = match.item.quantity;
                  cartItemId = match.item.id;
                }
            
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: PageView.builder(
                                      controller: pageController,
                                      itemCount: product.imageUrl.length,
                                      onPageChanged: (index) {
                                        currentImageIndex = index;
                                        (context as Element).markNeedsBuild();
                                      },
                                      itemBuilder: (_, index) {
                                        BorderRadius imageRadius =
                                            BorderRadius.zero;
            
                                        if (index == 0) {
                                          imageRadius =
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(12),
                                              );
                                        } else if (index ==
                                            product.imageUrl.length - 1) {
                                          imageRadius =
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(12),
                                              );
                                        }
            
                                        return ClipRRect(
                                          borderRadius: imageRadius,
                                          child: Image.network(
                                            product.imageUrl[index],
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    product.imageUrl.length,
                                    (index) {
                                      final isActive =
                                          index == currentImageIndex;
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width: isActive ? 16 : 8,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              product.productNameKz.toLowerCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                   AppLocalizations.of(context)!.inOneCopy,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MaktubConstants.detailTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                  Text(
                                  product.netContent.toLowerCase(),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MaktubConstants.detailTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                     AppLocalizations.of(context)!.description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Gradients.bigTextColor,
                                    ),
                                  ),
                                  Text(
                                    product.description,
            
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Gradients.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, state) {
                              if (state is ProductCombinedLoaded) {
                                final products = state.products;
                                final suppliers = state.suppliers;
            
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                         AppLocalizations.of(context)!.allSuppliersAndPrices,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...List.generate(suppliers.length, (
                                        index,
                                      ) {
                                        final sp = suppliers[index];
                                        final color = _getHeaderColor(index);
            
                                        bool isInCart = false;
                                        final cartState = context
                                            .watch<CartBloc>()
                                            .state;
                                        if (cartState is CartLoaded) {
                                          isInCart = cartState.items.any(
                                            (validated) =>
                                                validated
                                                    .item
                                                    .supplierProductId ==
                                                sp.spId,
                                          );
                                        }
            
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: 1,
                                          ),
                                          duration: Duration(
                                            milliseconds: 200 + index * 100,
                                          ),
                                          builder: (context, value, child) {
                                            return Opacity(
                                              opacity: value,
                                              child: Transform.translate(
                                                offset: Offset(
                                                  0,
                                                  (1 - value) * 20,
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: SupplierProductCard(
                                              onGoToCart: () {
                                                context.go(RouteNames.cart);
                                              },
                                              product: sp,
                                              headerColor: color,
                                              isInCart: isInCart,
                                              unit: product.unit,
                                              onAddToCart: () {
                                                context.read<CartBloc>().add(
                                                  AddCartItem(
                                                    CartItem(
                                                      id: null,
                                                      unit: product.unit,
                                                      productId:
                                                          product.productId,
                                                      productName: product
                                                          .productNameKz,
                                                      price: sp.price,
                                                      quantity: sp.quantity,
                                                      supplierProductId:
                                                          sp.spId,
                                                      supplierId:
                                                          sp.supplierId,
                                                      supplierName:
                                                          sp.supplierName,
                                                      organizationId:
                                                          organizationId,
                                                      cartQuantity:
                                                          sp.quantity,
                                                    ),
                                                    organizationId,
                                                    products.first.regionId,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }
            
                              return const SizedBox.shrink();
                            },
                          ),
                          BlocBuilder<ProductBloc, ProductState>(
                            builder: (context, state) {
                              if (state is ProductCombinedLoaded) {
                                return HorizontalProductList(
                                  key: const ValueKey('product-bottomsheet'),
                                  filterType: 'category',
                                  filterId: product.categoryId,
                                  title: AppLocalizations.of(context)!.similarProducts,
                                  products: state.products,
                                  organizationId: organizationId,
                                  categoriesMap: categoriesMap,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Transform.rotate(
                                          angle: 3.1416 / 2,
                                          child: Image.asset(
                                            'assets/icons-system/arrow.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
            
                                  // Align(
            
                                  //   alignment: Alignment.centerRight,
                                  //   child: GestureDetector(
                                  //     onTap: product.isInFavorites! ? () {
                                  //       context.read<ProductBloc>().add(AddToFavorites(regionId:product.regionId , organizationId: organizationId, productId: product.productId));
                                  //     }:
                                  //     () {
                                  //       context.read<ProductBloc>().add(DeleteFromFavorites(regionId:product.regionId , organizationId: organizationId, productId: product.productId));
                                  //     }
                                  //      ,
                                  //     child: Container(
                                  //       decoration: const BoxDecoration(
                                  //         color: Colors.transparent,
                                  //         shape: BoxShape.circle,
                                  //       ),
                                  //       child:product.isInFavorites! ?
                                  //       Image.asset(
                                  //         'assets/filledHeart.png',
                                  //         width: 25,
                                  //         height: 25,
                                  //       )
                                  //       : Image.asset(
                                  //         'assets/icons-system/favorites-green.png',
                                  //         width: 25,
                                  //         height: 25,
                                  //       ) ,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Transparent image placeholder (add this somewhere in your utils)
final kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x60,
  0x00,
  0x00,
  0x00,
  0x02,
  0x00,
  0x01,
  0xE2,
  0x21,
  0xBC,
  0x33,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
].map((e) => e.toUnsigned(8)).toList().cast<int>();

class WeeklyCacheManager {
  static CacheManager instance = CacheManager(
    Config(
      'weeklyCacheKey', // Уникальное имя
      stalePeriod: const Duration(days: 7), // Срок хранения 7 дней
      maxNrOfCacheObjects: 200, // можно изменить при необходимости
    ),
  );
}


class FadeInNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const FadeInNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<FadeInNetworkImage> createState() => _FadeInNetworkImageState();
}

class _FadeInNetworkImageState extends State<FadeInNetworkImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return ClipRRect(
    borderRadius: widget.borderRadius,
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (!_isLoaded)
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
        CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: widget.fit,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          cacheManager:  WeeklyCacheManager.instance,
          placeholder: (_, __) => const SizedBox(),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
          imageBuilder: (context, imageProvider) {
            _controller.forward();
            _isLoaded = true;
            return FadeTransition(
              opacity: _animation,
              child: Image(
                image: imageProvider,
                fit: widget.fit,
              ),
            );
          },
        ),
      ],
    ),
  );
}

}

class SupplierProductCard extends StatelessWidget {
  final SupplierProduct product;
  final VoidCallback onAddToCart;
  final VoidCallback onGoToCart;
  final bool isInCart;
  final Color headerColor;
  final int unit;

  const SupplierProductCard({
    super.key,
    required this.unit,
    required this.product,
    required this.onAddToCart,
    required this.isInCart,
    required this.headerColor,
    required this.onGoToCart,
  });

  @override
  Widget build(BuildContext context) {
    final String unitLabel = unit == 1 ? 'шт' : 'кг';
    final String quantityText = unit == 1
        ? product.quantity.toInt().toString()
        : product.quantity.toString();

    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // border: Border.all(color: headerColor, width: 1),
            color: Colors.grey.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.supplierName,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~${_getDeliveryDate(context, product.deliveryDay).toLowerCase()}',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                           AppLocalizations.of(context)!.minOrderAmount
                              .toLowerCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                         Text(
                          '${product.minOrderAmount.toInt()}₸'
                              .toLowerCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            '$quantityText $unitLabel',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              // color: headerColor
                            ),
                          ),

                          Text(
                            ' ${product.price * product.quantity}₸',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Gradients.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        final isLoading = state is CartLoading;

                        if (isInCart) {
                          return ElevatedButton(
                            onPressed: isLoading ? null : onGoToCart,
                            style: ElevatedButton.styleFrom(
                              overlayColor: Colors.transparent,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              enableFeedback: false,
                              backgroundColor: headerColor,
                              fixedSize: const Size(130, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: LoadingAnimationWidget.waveDots(
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                : Text(
                                     AppLocalizations.of(context)!.inCart,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final appState = context
                                        .read<AppStateCubit>()
                                        .state;
                                    final userRole = UserRole.values.firstWhere(
                                      (e) => e.name == appState?.role,
                                      orElse: () => UserRole.guest,
                                    );
                                    final hasAccess =
                                        PermissionManager.canAccess(
                                          userRole,
                                          'cart',
                                        );
                                    if (hasAccess) {
                                      onAddToCart();
                                    } else {
                                      context.push(RouteNames.login);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              overlayColor: Colors.transparent,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              enableFeedback: false,
                              backgroundColor: headerColor,
                              fixedSize: const Size(130, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? LoadingAnimationWidget.waveDots(
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : Text(
                                    '${product.price.toInt()}₸',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDeliveryDate(BuildContext context, int offset) {
    final loc = AppLocalizations.of(context)!;
    final location = tz.getLocation(
      'Asia/Almaty',
    ); // Казахстан (Астана, Алматы)
    final now = tz.TZDateTime.now(location);

    final isLate = now.hour >= 20;
    final deliveryDate = now.add(Duration(days: offset + (isLate ? 1 : 0)));

  final weekdays = [
    loc.weekday_mon,
    loc.weekday_tue,
    loc.weekday_wed,
    loc.weekday_thu,
    loc.weekday_fri,
    loc.weekday_sat,
    loc.weekday_sun,
  ];

  final months = [
    loc.month_jan,
    loc.month_feb,
    loc.month_mar,
    loc.month_apr,
    loc.month_may,
    loc.month_jun,
    loc.month_jul,
    loc.month_aug,
    loc.month_sep,
    loc.month_oct,
    loc.month_nov,
    loc.month_dec,
  ];
    return '${weekdays[deliveryDate.weekday - 1]}, ${deliveryDate.day} ${months[deliveryDate.month - 1]}';
  }
}

class ProductHorizontalCard extends StatelessWidget {
  final Product product;
  final int organizationId;
  final int regionId;
  ProductHorizontalCard({
    super.key,
    required this.product,
    required this.organizationId,
    required this.regionId,
  });
  @override
  Widget build(BuildContext context) {
    // Текст количества (если нужно отобразить где-либо)
    final String quantityText = product.unit == 1
        ? product.quantity.toInt().toString()
        : product.quantity.toStringAsFixed(2);

    final String unitLabel = product.unit == 1
        ? '₸/ $quantityText шт'
        : '₸/ $quantityText кг';

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        double quantity = 0;
        int? cartItemId;

        if (cartState is CartLoaded) {
          final match = cartState.items.firstWhere(
            (e) => e.item.productId == product.productId,
            orElse: () => ValidatedCartItem(
              item: CartItem(
                id: 0,
                productId: -1,
                unit: 1,
                supplierProductId: 0,
                supplierId: 0,
                quantity: 0,
                price: 0,
                organizationId: organizationId,
              ),
              isInStock: true,
            ),
          );

          if (match.item.productId != -1) {
            quantity = match.item.quantity;
            cartItemId = match.item.id;
          }
        }

        return GestureDetector(
          onTap: () {
            showProductBottomSheet(context, product);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),

              // border: Border.all(color: Gradients.primary)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: FadeInNetworkImage(
                    imageUrl: product.imageUrl.first,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    product.productNameKz.toLowerCase(),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(product.price * product.quantity).toInt()}$unitLabel',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Gradients.detailTextColor,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: quantity == 0
                            ? ElevatedButton(
                                onPressed: () async {},
                                style: ButtonStyle(
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Colors.grey.withOpacity(0.15),
                                  ),
                                  fixedSize: WidgetStateProperty.all(
                                    const Size(130, 45),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product.price.toInt()}₸',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Gradients.productTextColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Gradients.primary,
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  context.go(RouteNames.cart);
                                },
                                style: ButtonStyle(
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(
                                    Gradients.primary,
                                    // Colors.grey.withOpacity(0.15)
                                  ),
                                  fixedSize: WidgetStateProperty.all(
                                    const Size(130, 45),
                                  ),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: WidgetStateProperty.all(
                                    Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                       AppLocalizations.of(context)!.inCart,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
  }

  Color _getHeaderColor(int index) {
    const colors = [
      Gradients.primary,

      Colors.amber,
      Colors.pink,
      // Colors.greenAccent,
    ];
    return colors[index % colors.length];
  }

  void showProductBottomSheet(BuildContext parentContext, Product product) {
    int currentImageIndex = 0;
    final pageController = PageController();
    final controller = DraggableScrollableController();
    final categories = parentContext.read<AppStateCubit>().state?.categories;

    final productDetailsBloc = ProductBloc(repository: parentContext.read());
    productDetailsBloc.add(
      LoadProductSuppliers(
        regionId: product.regionId,
        productId: product.productId,
      ),
    );
    final cartBloc = parentContext.read<CartBloc>();

    // cartBloc.add(LoadCart(organizationId, regionId));

    showModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.5),
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: productDetailsBloc,
          child: BlocProvider.value(
            value: cartBloc,
            child: DraggableScrollableSheet(
              controller: controller,
              initialChildSize: 0.93,
              minChildSize: 0.9,
              maxChildSize: 0.93,
              expand: false,
              builder: (context, scrollController) {
                final cartState = context.watch<CartBloc>().state;
                double quantity = 0;
                int? cartItemId;
            
                if (cartState is CartLoaded) {
                  final match = cartState.items.firstWhere(
                    (e) => e.item.productId == product.productId,
                    orElse: () => ValidatedCartItem(
                      item: CartItem(
                        unit: 1,
                        id: -1,
                        productId: product.productId,
                        productName: product.productNameKz,
                        price: product.price,
                        quantity: 0,
                        supplierProductId: 0,
                        supplierId: product.supplierId,
                        supplierName: product.supplierName,
                        organizationId: 0,
                      ),
                      isInStock: true,
                    ),
                  );
                  quantity = match.item.quantity;
                  cartItemId = match.item.id;
                }
            
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 0,
                        ), // отступ после ползунка
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            SizedBox(height: 50),
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: PageView.builder(
                                  controller: pageController,
                                  itemCount: product.imageUrl.length,
                                  onPageChanged: (index) {
                                    currentImageIndex = index;
                                    (context as Element)
                                        .markNeedsBuild(); // перерисовать индикатор
                                  },
                                  itemBuilder: (_, index) {
                                    BorderRadius imageRadius =
                                        BorderRadius.zero;
            
                                    if (index == 0) {
                                      imageRadius =
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(12),
                                          );
                                    } else if (index ==
                                        product.imageUrl.length - 1) {
                                      imageRadius =
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(12),
                                          );
                                    }
            
                                    return ClipRRect(
                                      borderRadius: imageRadius,
                                      child: Image.network(
                                        product.imageUrl[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.imageUrl.length,
                                (index) {
                                  final isActive = index == currentImageIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    width: isActive ? 16 : 8,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                },
                              ),
                            ),
            
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                // 'rwesxtrdcvfgbhnjminohiubguvftycrdetsw5sa4srwxetrcdyfvtugbyinhuo',
                                product.productNameKz.toLowerCase(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                     AppLocalizations.of(context)!.inOneCopy,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: MaktubConstants.detailTextColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                       Text(
                                    product.netContent.toLowerCase(),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: MaktubConstants.detailTextColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
            
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                     AppLocalizations.of(context)!.description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Gradients.bigTextColor,
                                    ),
                                  ),
                                  Text(
                                    product.description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Gradients.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
            
                            BlocBuilder<ProductBloc, ProductState>(
                              builder: (context, state) {
                                if (state is SupplierProductLoaded) {
                                  final cartState = context
                                      .watch<CartBloc>()
                                      .state;
                                  final suppliers = state.supplierProduct;
                                
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 14),
                                      Text(
                                         AppLocalizations.of(context)!.allSuppliersAndPrices,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...List.generate(suppliers.length, (
                                        index,
                                      ) {
                                        final sp = suppliers[index];
                                        final color = _getHeaderColor(index);
            
                                        bool isInCart = false;
            
                                        if (cartState is CartLoaded) {
                                          isInCart = cartState.items.any(
                                            (validated) =>
                                                validated
                                                    .item
                                                    .supplierProductId ==
                                                sp.spId,
                                          );
                                        }
            
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: 1,
                                          ),
                                          duration: Duration(
                                            milliseconds: 200 + index * 100,
                                          ),
                                          builder: (context, value, child) {
                                            return Opacity(
                                              opacity: value,
                                              child: Transform.translate(
                                                offset: Offset(
                                                  0,
                                                  (1 - value) * 20,
                                                ),
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: SupplierProductCard(
                                              onGoToCart: () {
                                                context.go(RouteNames.cart);
                                              },
                                              product: sp,
                                              headerColor: color,
                                              isInCart: isInCart,
                                              unit: product.unit,
                                              onAddToCart: () {
                                                context.read<CartBloc>().add(
                                                  AddCartItem(
                                                    CartItem(
                                                      unit: product.unit,
                                                      id: null,
                                                      productId:
                                                          product.productId,
                                                      productName: product
                                                          .productNameKz,
                                                      price: sp.price,
                                                      quantity: sp.quantity,
                                                      supplierProductId:
                                                          sp.spId,
                                                      supplierId:
                                                          sp.supplierId,
                                                      supplierName:
                                                          sp.supplierName,
                                                      organizationId:
                                                          organizationId,
                                                    ),
                                                    organizationId,
                                                    regionId,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
            
                            BlocBuilder<ProductBloc, ProductState>(
                              builder: (context, state) {
                                if (state is ProductLoaded) {
                                  return HorizontalProductList(
                                    key: const ValueKey(
                                      'product-bottomsheet',
                                    ),
                                    filterType: 'category',
                                    filterId: product.categoryId,
                                    title: AppLocalizations.of(context)!.similarProducts,
                                    products: state.products,
                                    organizationId: organizationId,
                                    categoriesMap: categories ?? {},
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
            
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
            
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Transform.rotate(
                                          angle: 3.1416 / 2, // 90 градусов
                                          child: Image.asset(
                                            'assets/icons-system/arrow.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
            
                         
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class HorizontalProductList extends StatelessWidget {
  final List<Product> products;
  final int organizationId;
  final int filterId;
  final String filterType;
  final String title;
  final Map<Category, List<Category>> categoriesMap;

  const HorizontalProductList({
    super.key,
    required this.title,
    required this.products,
    required this.organizationId,
    required this.categoriesMap,
    required this.filterId,
    required this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final allCategories = categoriesMap.entries
        .expand((e) => [e.key, ...e.value])
        .toList();

    final currentCategory = allCategories.firstWhere(
      (c) => c.id == products.first.categoryId,
      orElse: () => categoriesMap.keys.first,
    );

    final parentCategory = categoriesMap.keys.firstWhere(
      (parent) => parent.id == currentCategory.parentId,
      orElse: () => categoriesMap.keys.first,
    );

    final subcategories = categoriesMap[parentCategory] ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                  // StatefulNavigationShell.of(context).goBranch(1);
                  switch (filterType) {
                    case 'category':
                      context.replaceNamed(
                        'productList',
                        extra: {
                          'categoryId': filterId,
                          'subcategories': subcategories,
                          'title': parentCategory.nameRu,
                        },
                      );
                      break;

                    case 'brand':
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) => ProductBottomSheetScreen(
                          title: title,
                          // brandId: selectedBrandId,
                          brandId: filterId,
                        ),
                      );
                      break;

                    case 'supplier':
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (_) => ProductBottomSheetScreen(
                          title: title,
                          // brandId: selectedBrandId,
                          supplierId: filterId,
                        ),
                      );

                      break;
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Text(
                         AppLocalizations.of(context)!.all,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Gradients.textGray,
                        ),
                      ),
                      Image.asset(
                        'assets/icons-system/arrow.png',
                        width: 16,
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: screenWidth / 2.5 * 1.6,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + index * 100),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 20),
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: screenWidth / 2.7,
                  child: ProductHorizontalCard(
                    product: products[index],
                    organizationId: organizationId,
                    regionId: products.first.regionId,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
