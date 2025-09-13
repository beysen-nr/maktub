import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/brand_category.dart';
import 'package:maktub/data/models/category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
import 'package:maktub/presentation/user/widgets/common/seller_bottom_sheet.dart';

class ProductListScreen extends StatelessWidget {
  final int? categoryId;
  final List<Category> subcategories;
  final String title;

  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.subcategories,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    int regionId = context.read<AppStateCubit>().state!.regionId;
    int organizationId = context.read<AppStateCubit>().state!.workplaceId;
    return BlocProvider(
      create:
          (_) => ProductBloc(repository: context.read())..add(
            LoadProducts(
              categoryId: categoryId,
              regionId: regionId,
              organizationId: organizationId,
            ),
          ),

      child: _ProductListView(
        subcategories: subcategories,
        title: title,
        categoryId: categoryId,
      ),
    );
  }
}

class _ProductListView extends StatefulWidget {
  final String title;
  final List<Category> subcategories;
  final int? categoryId;

  const _ProductListView({
    required this.subcategories,
    required this.title,
    required this.categoryId,
  });

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  int? selectedCategoryId;
  bool showSubcategories = true;

  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.categoryId ?? widget.subcategories.first.id;

    context.read<ProductBloc>().add(
      LoadProducts(
        categoryId: selectedCategoryId,
        regionId: context.read<AppStateCubit>().state!.regionId,
        offset: 0,
        organizationId: context.read<AppStateCubit>().state!.workplaceId,
      ),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<ProductBloc>().state;

    if (state is ProductLoaded) {}
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        state is ProductLoaded &&
        state.hasMore) {
      _loadMoreProducts();
    }
  }

  void _loadMoreProducts() {
    final bloc = context.read<ProductBloc>();
    final state = bloc.state;
    if (state is ProductLoaded) {
      isLoadingMore = true;
      offset = state.products.length;
      bloc.add(
        LoadProducts(
          regionId: context.read<AppStateCubit>().state!.regionId,
          categoryId: selectedCategoryId,
          brandId: state.selectedBrandId,
          supplierId: state.selectedSupplierId,
          offset: offset,
          organizationId: context.read<AppStateCubit>().state!.workplaceId,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int organizationId = context.read<AppStateCubit>().state!.workplaceId;
    return BlocListener<AppStateCubit, AppState?>(
      listenWhen: (prev, curr) => prev?.regionId != curr?.regionId,
      listener: (context, state) {
        if (state != null) {
          context.read<ProductBloc>().add(
            LoadProducts(
              categoryId: selectedCategoryId,
              regionId: state.regionId,
              organizationId: organizationId,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 80),
                  Expanded(
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
                          if (state.products.isNotEmpty || offset != 0) {
                            if (isLoadingMore) {
                              isLoadingMore = false;
                              offset = state.products.length;
                            }

                            final products = [...state.products];
                            int organizationId =
                                context
                                    .read<AppStateCubit>()
                                    .state!
                                    .workplaceId;
                            return GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 0,
                                    childAspectRatio: 0.61,
                                  ),
                              itemBuilder: (context, index) {
                                final categoriesMap =
                                    context
                                        .read<AppStateCubit>()
                                        .state
                                        ?.categories ??
                                    {};

                                return TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 200 + index * 100,
                                  ),
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
                          } else {
                            return Center(
                              // Этот Center центрирует свой дочерний элемент
                              // Обернем содержимое body в Expanded или SizedBox.expand()
                              child: SizedBox.expand(
                                // <-- Используем SizedBox.expand() чтобы занять всё доступное пространство
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center, // Центрируем по вертикали
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .stretch, // Растягиваем по горизонтали (для кнопки и текста)
                                    children: [
                                      Text(
                                         AppLocalizations.of(context)!.thisListIsEmpty,
                                        style: GoogleFonts.montserrat(
                                          color: Gradients.bigTextColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign:
                                            TextAlign
                                                .center, // Центрируем сам текст
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                         AppLocalizations.of(context)!.registerYourSupplierAndGetDiscounts,
                                        style: GoogleFonts.montserrat(
                                          color: Gradients.detailTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign:
                                            TextAlign
                                                .center, // Центрируем сам текст
                                      ),
                                      const SizedBox(height: 14),
                                      ElevatedButton(
                                        onPressed: () {
                                        showRegisterSupplierBottomSheet(context);
                                        },
                                        style: ButtonStyle(
                                          elevation: WidgetStateProperty.all(0),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                Gradients.primary,
                                              ),
                                          minimumSize: WidgetStateProperty.all(
                                            const Size(double.infinity, 50),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          splashFactory: NoSplash.splashFactory,
                                          overlayColor: WidgetStateProperty.all(
                                            Colors.transparent,
                                          ),
                                        ),
                                        child: Text(
                                           AppLocalizations.of(context)!.registerSupplier,
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        } else if (state is ProductError) {
                          return Center(child: Text( AppLocalizations.of(context)!.error));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(
                                  3.1416,
                                ), // π радиан = 180 градусов
                                child: Image.asset(
                                  'assets/icons-system/arrow.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => _showFilterBottomSheet(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(
                                  0,
                                ), // π радиан = 180 градусов
                                child: Image.asset(
                                  'assets/icons-system/filter.png',
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 10), // тень СНИЗУ
                        ),
                      ],
                    ),
                    child: _buildSubcategoryToggle(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final int organizationId = context.read<AppStateCubit>().state!.workplaceId;
    final state = productBloc.state;

    if (state is! ProductLoaded) return;

    final brandSuppliers = state.brandSuppliers;
    final uniqueBrands =
        brandSuppliers.map((e) => e.brandName).toSet().toList();
    final uniqueSuppliers =
        brandSuppliers.map((e) => e.supplierName).toSet().toList();

    String? selectedBrand;
    String? selectedSupplier;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return BlocProvider.value(
          value: productBloc,
          child: SafeArea(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.9,
                  maxChildSize: 0.95,
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
                          Text(
                            'бренд',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: -8.0,

                            children:
                                uniqueBrands.map((brand) {
                                  final isSelected = selectedBrand == brand;
                                  return ChoiceChip(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    showCheckmark: false,
                                    label: Text(
                                      brand.toLowerCase(),
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
                                        selectedBrand = selected ? brand : null;
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                             AppLocalizations.of(context)!.supplier,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: -8.0,
                            children:
                                uniqueSuppliers.map((supplier) {
                                  final isSelected =
                                      selectedSupplier == supplier;
                                  return ChoiceChip(
                                    backgroundColor: Colors.grey.withOpacity(
                                      0.18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    showCheckmark: false,
                                    selectedColor: Colors.pink,
                                    label: Text(
                                      supplier.toLowerCase(),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Gradients.textGray,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setModalState(() {
                                        selectedSupplier =
                                            selected ? supplier : null;
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final regionId =
                                    context
                                        .read<AppStateCubit>()
                                        .state!
                                        .regionId;

                                final selectedBrandId =
                                    brandSuppliers
                                        .firstWhere(
                                          (e) => e.brandName == selectedBrand,
                                          orElse:
                                              () => BrandSupplier(
                                                brandId: 0,
                                                brandName: '',
                                                supplierId: 0,
                                                supplierName: '',
                                              ),
                                        )
                                        .brandId;

                                final selectedSupplierId =
                                    brandSuppliers
                                        .firstWhere(
                                          (e) =>
                                              e.supplierName ==
                                              selectedSupplier,
                                          orElse:
                                              () => BrandSupplier(
                                                brandId: 0,
                                                brandName: '',
                                                supplierId: 0,
                                                supplierName: '',
                                              ),
                                        )
                                        .supplierId;

                                context.read<ProductBloc>().add(
                                  LoadProducts(
                                    regionId: regionId,
                                    categoryId: selectedCategoryId,
                                    brandId:
                                        selectedBrand != null
                                            ? selectedBrandId
                                            : null,
                                    supplierId:
                                        selectedSupplier != null
                                            ? selectedSupplierId
                                            : null,
                                    organizationId: organizationId,
                                  ),
                                );

                                context.pop();
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

  Widget _buildSubcategoryToggle() {
    final subcategories = [
      if (widget.subcategories.any((c) => c.id == selectedCategoryId))
        widget.subcategories.firstWhere((c) => c.id == selectedCategoryId),
      ...widget.subcategories.where((c) => c.id != selectedCategoryId),
    ];

    final productState = context.watch<ProductBloc>().state;
    int? selectedBrandId;
    int? selectedSupplierId;

    if (productState is ProductLoaded) {
      selectedBrandId = productState.selectedBrandId;
      selectedSupplierId = productState.selectedSupplierId;
    }

    List<BrandSupplier> brandSuppliers = [];

    if (productState is ProductLoaded) {
      selectedBrandId = productState.selectedBrandId;
      selectedSupplierId = productState.selectedSupplierId;
      brandSuppliers = productState.brandSuppliers;
    }

    final brand = brandSuppliers.firstWhere(
      (bs) => bs.brandId == selectedBrandId,
      orElse:
          () => BrandSupplier(
            brandId: -1,
            brandName: '',
            supplierId: -1,
            supplierName: '',
          ),
    );

    final supplier = brandSuppliers.firstWhere(
      (bs) => bs.supplierId == selectedSupplierId,
      orElse:
          () => BrandSupplier(
            brandId: -1,
            brandName: '',
            supplierId: -1,
            supplierName: '',
          ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedBrandId != null || selectedSupplierId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (brand.brandId != -1)
                    Chip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Text(
                        brand.brandName.toLowerCase(),
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.amber,
                    ),

                  if (supplier.supplierId != -1)
                    Chip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      label: Text(
                        supplier.supplierName.toLowerCase(),
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.pink,
                    ),
                ],
              ),
            ),
          // const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    builder: (modalContext) {
                      return BlocProvider.value(
                        value: context.read<ProductBloc>(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: subcategories.length,
                          itemBuilder: (context, index) {
                            final category = subcategories[index];
                            return ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -4),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 8,
                              ),
                              title: Text(
                                category.nameRu,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedCategoryId = category.id;
                                  offset = 0;
                                  isLoadingMore = false;
                                });

                                context.read<ProductBloc>().add(
                                  LoadProducts(
                                    organizationId:
                                        context
                                            .read<AppStateCubit>()
                                            .state!
                                            .workplaceId,
                                    categoryId: selectedCategoryId,
                                    regionId:
                                        context
                                            .read<AppStateCubit>()
                                            .state!
                                            .regionId,
                                    brandId: null,
                                    supplierId: null,
                                    offset: 0,
                                  ),
                                );

                                context.pop();
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (_scrollController.hasClients &&
                                      _scrollController.position.pixels >=
                                          _scrollController
                                                  .position
                                                  .maxScrollExtent -
                                              200) {
                                    _loadMoreProducts();
                                  }
                                });
                              },
                            );
                          },
                          separatorBuilder:
                              (context, index) => const Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Gradients.primary,
                                indent: 8,
                                endIndent: 8,
                              ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Gradients.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 12),
                      itemCount: subcategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final category = subcategories[index];
                        final isSelected = selectedCategoryId == category.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                              context.read<ProductBloc>().add(
                                LoadProducts(
                                  organizationId:
                                      context
                                          .read<AppStateCubit>()
                                          .state!
                                          .workplaceId,
                                  categoryId: selectedCategoryId,
                                  regionId:
                                      context
                                          .read<AppStateCubit>()
                                          .state!
                                          .regionId,
                                  brandId: null,
                                  supplierId: null,
                                ),
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Gradients.primary
                                      : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                category.nameRu,
                                style: GoogleFonts.montserrat(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Gradients.textGray,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
