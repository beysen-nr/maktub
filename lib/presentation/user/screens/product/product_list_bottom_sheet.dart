import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
class ProductBottomSheetScreen extends StatefulWidget {
  final String title;
  final int? brandId;
  final int? supplierId;
  final String? tag;


  const ProductBottomSheetScreen({
    super.key,
    required this.title,
    this.brandId,
    this.supplierId,
    this.tag
  });


  @override
  State<ProductBottomSheetScreen> createState() => _ProductBottomSheetScreenState();
}

class _ProductBottomSheetScreenState extends State<ProductBottomSheetScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  
@override
void initState() {
  super.initState();

  final appState = context.read<AppStateCubit>().state!;
  context.read<ProductBloc>().add(
    LoadProducts(
      regionId: appState.regionId,
      brandId: widget.brandId,
      supplierId: widget.supplierId,
      tag: widget.tag,
      offset: 0,
      organizationId:  appState.workplaceId
    ),
  );

  _scrollController.addListener(_onScroll);
}

  void _onScroll() {
    final state = context.read<ProductBloc>().state;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        state is ProductLoaded &&
        state.hasMore) {
      isLoadingMore = true;
      context.read<ProductBloc>().add(
        LoadProducts(
          organizationId: context.read<AppStateCubit>().state!.workplaceId,
          regionId: context.read<AppStateCubit>().state!.regionId,
          categoryId: null,
          offset: state.products.length,
          brandId: state.selectedBrandId,
          supplierId: state.selectedSupplierId,
        ),
      );
    }
  }

@override
Widget build(BuildContext context) {
  final organizationId = context.read<AppStateCubit>().state!.workplaceId;
  final categoriesMap = context.read<AppStateCubit>().state?.categories ?? {};


  return BlocListener<ProductBloc, ProductState>(
    listener: (context, state) {
      if (state is ProductLoaded) {
        isLoadingMore = false;
      }
    },
    child: SafeArea(
      bottom: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, _) {
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: Gradients.primary,
                          size: 30,
                        ),
                      );
                    } else if (state is ProductLoaded) {
                      final products = state.products;
                    
                      return GridView.builder(
                        padding: EdgeInsets.only(top: 60),
                        controller: _scrollController,
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 0,
                          childAspectRatio: 0.61,
                        ),
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 200 + index * 100),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 20),
                                  child: child,
                                ),
                              );
                            },
                            child: ProductCard(
                              product: products[index],
                              organizationId: organizationId,
                              categoriesMap: categoriesMap,
                            ),
                          );
                        },
                      );
                    } else if (state is ProductError) {
               
                      return Center(
                        child: Text(
                           AppLocalizations.of(context)!.errorTryLater,
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
    
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                       Text(
                      widget.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
