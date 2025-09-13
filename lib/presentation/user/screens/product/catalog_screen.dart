import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/brand_supplier.dart';
import 'package:maktub/data/models/cart_item.dart';
import 'package:maktub/data/models/cart_product.dart';
import 'package:maktub/data/models/category.dart';
import 'package:maktub/data/models/product_by_tag.dart';
import 'package:maktub/domain/repositories/category_repo.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
import 'package:maktub/presentation/user/screens/product/product_list_bottom_sheet.dart';

class CatalogScreen extends StatefulWidget {
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool isLoading = true;
  bool _filterRequested = false;
  bool isFilterLoading = false;

  final CategoryService _service = CategoryService();
  Map<Category, List<Category>> categoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regionId = context.read<AppStateCubit>().state!.regionId;
      context.read<ProductBloc>().add(SupplierBrandLoad(regionId: regionId));
    });
  }

  Future<void> _loadCategories() async {
    final all = await _service.fetchAllCategories();
    final sections =
        all.where((c) => c.parentId == null).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    final children = all.where((c) => c.parentId != null).toList();

    final Map<Category, List<Category>> result = {};
    for (var section in sections) {
      result[section] =
          children.where((c) => c.parentId == section.id).toList();
    }

    setState(() {
      categoryMap = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final appStateCubit = context.read<AppStateCubit>();
    // final regionId = appStateCubit.state!.regionId;

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (previous, current) => current is BrandSupplierLoaded,
      listener: (context, state) {
        if (_filterRequested) {
          _filterRequested = false;
          setState(() {
            isFilterLoading = false;
          });

          final brands = (state as BrandSupplierLoaded).brands;
          final suppliers = state.suppliers;
          _presentBottomSheet(context, brands, suppliers);
        }
      },

      child: Stack(
        children: [
          Scaffold(
            // extendBodyBehindAppBar: true,
            appBar: AppBar(
              toolbarHeight: 0,
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body:
                isLoading
                    ? Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: Gradients.primary,
                        size: 25,
                      ),
                    )
                    : 
                   Stack(
  children: [
        Container(color: Colors.white),

    // Снизу: контент с отступом сверху под поиск
    Padding(
      padding: const EdgeInsets.only(top: 0), // или сколько там у тебя высота поиска
      child: Container(
        color: Colors.transparent,
        child:
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTapDown: (_) {
    FocusScope.of(context).unfocus(); // если нужно
    context.read<ProductBloc>().add(ClearProductSuggestions());
  },
           child: CustomScrollView(
            slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 60)),
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  ...categoryMap.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final item = entry.value;
           
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
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
                          child: SectionWidget(
                            section: Section(
                              title: item.key.nameRu,
                              icon: Icons.category,
                              isExpanded: false,
                            ),
                            subcategories: item.value,
                            parentCategory: item.key,
                          ),
                        );
                      }),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
                   ),
         ),
    
      ),
    ),

    // Сверху: поиск
Positioned(
  top: 0,
  left: 0,
  right: 0,
  
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12),
             decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                       color: Colors.white.withOpacity(0.4),
                width: 0.7,
              ),
        borderRadius: BorderRadius.circular(100)
      ),
    // height: 70,
    alignment: Alignment.center,
    child: SearchBarWidget(
    
      productBloc: productBloc,
      appStateCubit: appStateCubit,
      onFilterPressed: () {
        _filterRequested = true;
        setState(() {
          isFilterLoading = true;
        });
        final regionId = appStateCubit.state!.regionId;
        productBloc.add(SupplierBrandLoad(regionId: regionId));
      },
    ),
  ),
),

  ],
)

          ),
          if (isFilterLoading)
            Container(
              color: Colors.black.withOpacity(0.05),
              child: Center(
                child: LoadingAnimationWidget.waveDots(
                  color: Gradients.primary,
                  size: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _presentBottomSheet(
    BuildContext parentContext,
    List<BrandId> brands,
    List<SupplierId> suppliers,
  ) {
    int? selectedBrandId;
    int? selectedSupplierId;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: parentContext.read<ProductBloc>(),
          child: SafeArea(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.9,
                  maxChildSize: 0.9,
                  minChildSize: 0.5,
                  builder: (context, scrollController) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'фильтр',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Бренды
                          Text(
                            'бренд',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: -8.0,
                            children:
                                brands.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final brand = entry.value;
                                  final isSelected =
                                      selectedBrandId == brand.brandId;

                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(
                                      milliseconds: 300 + index * 50,
                                    ),
                                    tween: Tween(begin: 0.8, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: child,
                                      );
                                    },
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      showCheckmark: false,
                                      label: Text(
                                        brand.brandName.toLowerCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Gradients.textGray,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey.withOpacity(
                                        0.18,
                                      ),
                                      selectedColor: Colors.amber,
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selectedBrandId =
                                              selected ? brand.brandId : null;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Поставщики
                          Text(
                             AppLocalizations.of(context)!.supplier,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: -8.0,
                            children:
                                suppliers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final supplier = entry.value;
                                  final isSelected =
                                      selectedSupplierId == supplier.supplierId;

                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(
                                      milliseconds: 300 + index * 50,
                                    ),
                                    tween: Tween(begin: 0.8, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: child,
                                      );
                                    },
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      showCheckmark: false,
                                      label: Text(
                                        supplier.supplierName.toLowerCase(),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Gradients.textGray,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey.withOpacity(
                                        0.18,
                                      ),
                                      selectedColor: Colors.pink,
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setModalState(() {
                                          selectedSupplierId =
                                              selected
                                                  ? supplier.supplierId
                                                  : null;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // Кнопка
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                modalContext.pop(); // закроет фильтр

                                String getBottomSheetTitle() {
                                  if (selectedBrandId != null) {
                                    final brand = brands.firstWhere(
                                      (b) => b.brandId == selectedBrandId,
                                      orElse:
                                          () => BrandId(
                                            brandId: 0,
                                            brandName: '',
                                          ),
                                    );
                                    return brand.brandName.isNotEmpty
                                        ? brand.brandName
                                        : AppLocalizations.of(context)!.allProducts;
                                  } else if (selectedSupplierId != null) {
                                    final supplier = suppliers.firstWhere(
                                      (s) => s.supplierId == selectedSupplierId,
                                      orElse:
                                          () => SupplierId(
                                            supplierId: 0,
                                            supplierName: '',
                                          ),
                                    );
                                    return supplier.supplierName.isNotEmpty
                                        ? supplier.supplierName
                                        : AppLocalizations.of(context)!.allProducts;
                                  } else {
                                    return AppLocalizations.of(context)!.allProducts;
                                  }
                                }

                                final bottomSheetTitle =
                                    getBottomSheetTitle().toLowerCase();

                                showModalBottomSheet(
                                  context: parentContext,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder:
                                      (_) =>      BlocListener<AppStateCubit, AppState?>(
        listenWhen: (prev, curr) => prev?.regionId != curr?.regionId,
        listener: (context, state) {
          if (state != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(parentContext).canPop()) {
                Navigator.of(parentContext).pop();
              }
            });
            // context.read<CartBloc>().add(LoadCart(organizationId, state.regionId));
          }
        },
                                        child: ProductBottomSheetScreen(
                                          title: bottomSheetTitle,
                                          brandId: selectedBrandId,
                                          supplierId: selectedSupplierId,
                                        ),
                                      ),
                                );
                              },

                              style: ButtonStyle(
                                elevation: WidgetStateProperty.all(0),
                                backgroundColor: WidgetStateProperty.all(
                                  Gradients.primary,
                                ),
                                minimumSize: WidgetStateProperty.all(
                                  const Size(double.infinity, 50),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                splashFactory: NoSplash.splashFactory,
                                overlayColor: WidgetStateProperty.all(
                                  Colors.transparent,
                                ),
                              ),
                              child: Text(
                                 AppLocalizations.of(context)!.continueB,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class SearchBarWidget extends StatefulWidget {
  final ProductBloc productBloc;
  final AppStateCubit appStateCubit;
  final VoidCallback onFilterPressed;

   SearchBarWidget({
    super.key,
    required this.productBloc,
    required this.appStateCubit,
    required this.onFilterPressed,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;

  @override
void initState() {
  super.initState();
  _focusNode.addListener(() {
    if (!_focusNode.hasFocus) {
      context.read<ProductBloc>().add(ClearProductSuggestions());
    }
  });
}


@override
void dispose() {
  _debounce?.cancel();
  _focusNode.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    int regionId = widget.appStateCubit.state!.regionId;

        List<TagProduct> suggestions = [];

    void _onSearchChanged(String value) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    if (value.isNotEmpty) {
      context.read<ProductBloc>().add(
        LoadProductsByTag(tag: value, regionId: regionId,),
      );
    }else {
 context.read<ProductBloc>().add(
        ClearProductSuggestions(),
      );
    }
  });
}

    return Column(
      children: [
        SizedBox(height: 10,),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 48,
              // margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6), // прозрачный белый фон
                border: Border.all(
                  color: Colors.blueGrey.withOpacity(0.4),
                  width: 0.7,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Icon(Icons.search, color: Gradients.primary),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: _onSearchChanged,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
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
                            title: value,
                            // brandId: selectedBrandId,
                            tag: value,
                          ),
                                      );
                        },
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                      cursorColor: Gradients.primary,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchInMaktub,
                        hintStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onFilterPressed,
                    child: Container(
                      width: 48,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Image.asset(
                        'assets/icons-system/filter.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

    BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {


    if (state is ProductsLoadedByTag) {
      suggestions = state.tagProducts.take(10).toList();
    }

    if(state is ProductLoadedById){
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showProductBottomSheet(state.cartProduct, regionId);
  });
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: suggestions.isEmpty
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : Container(
              key: ValueKey(suggestions.map((e) => e.productId).join(',')),
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      border: Border.all(
                        color: Colors.blueGrey.withOpacity(0.4),
                        width: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(16,16,16,8 ), child: Text( AppLocalizations.of(context)!.maybeYouSearch, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Gradients.primary),),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: suggestions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final product = entry.value;
                        
                            final isFirst = index == 0;
                            final isLast = index == suggestions.length - 1;
                        
                            final padding = isFirst
                                ? const EdgeInsets.fromLTRB(16, 0, 16, 8)
                                : isLast
                                    ? const EdgeInsets.fromLTRB(16, 8, 16, 20)
                                    : const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16);
                        
                            return GestureDetector(
                              onTap: (){widget.productBloc.add(LoadProductByProductId(productId: product.productId));},
                              child: Padding(
                                padding: padding,
                                child: Text(
                                  product.productNameKz,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: Gradients.mainTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  },
),

     
      ],
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


  void showProductBottomSheet(
  CartProduct product,
  int regionId,
) {
  int currentImageIndex = 0;
  final pageController = PageController();
  final controller = DraggableScrollableController();
  late final Map<Category, List<Category>> categoriesMap;
  final productDetailsBloc = context.read<ProductBloc>();
  productDetailsBloc.add(
    LoadBothProductAndSuppliers(
      regionId: regionId,
      categoryId: product.categoryId,
      productId: product.productId,
    ),
  );

  final cartBloc = context.read<CartBloc>();
  categoriesMap = context.read<AppStateCubit>().state?.categories ?? {};
  int organizationId =
      context.read<AppStateCubit>().state?.workplaceId ?? 1;

  // cartBloc.add(LoadCart(organizationId, regionId));

  showModalBottomSheet(
    barrierColor: Colors.black.withOpacity(0.5),
    context: context,
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
                  orElse:
                      () => ValidatedCartItem(
                        item: CartItem(
                          id: -1,
                          productId: product.productId,
                          productName: product.productNameKz,
                          price: 0,
                          quantity: 0,
                          supplierProductId: 0,
                          supplierId: 0,
                          supplierName: '',
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
                                        color:
                                            isActive
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
                            product.productNameRu.toLowerCase(),
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Center(
                          child: Row(
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
                                      final cartState =
                                          context.watch<CartBloc>().state;
                                      if (cartState is CartLoaded) {
                            isInCart = cartState.items.any(
              (validated) => validated.item.supplierProductId == sp.spId,
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
                                            onGoToCart:() {
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
                                                    productName:
                                                        product.productNameKz,
                                                    price: sp.price,
                                                    quantity: sp.quantity,
                                                    supplierProductId:
                                                        sp.spId,
                                                    supplierId: sp.supplierId,
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
                            child: Align(
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



class Section {
  final String title;
  final IconData icon;
  final bool isExpanded;

  Section({required this.title, required this.icon, required this.isExpanded});
}

class CategoryItem {
  final String title;
  final String emoji;

  CategoryItem(this.title, this.emoji);
}

class SectionWidget extends StatefulWidget {
  final Section section;
  final Category parentCategory;
  final List<Category> subcategories;

  const SectionWidget({
    required this.section,
    required this.parentCategory,
    required this.subcategories,
    super.key,
  });

  @override
  State<SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget>
    with SingleTickerProviderStateMixin {
  late bool expanded;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    expanded = widget.section.isExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _heightFactor = curve;
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);

    if (expanded) {
      _controller.value = 1;
    }
  }

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: toggleExpanded,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 8),
            title: Text(
              widget.section.title,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Gradients.primary,
              ),
            ),
            trailing: IconButton(
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              color: Gradients.primary,
              onPressed: toggleExpanded,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightFactor.value,
                child: Opacity(opacity: _opacity.value, child: child),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children:
                  widget.subcategories.map((category) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(
                        category.nameRu,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Gradients.mainTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        context.pushNamed(
                          'productList',
                          extra: {
                            'categoryId': category.id,
                            'subcategories': widget.subcategories,
                            'title': widget.parentCategory.nameRu,
                          },
                        );
                      },
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryItem item;

  const CategoryCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFF7E8C6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            item.title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
