import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/cart_item.dart';
import 'package:maktub/data/models/cart_product.dart';
import 'package:maktub/data/models/cart_supplier.dart';
import 'package:maktub/data/models/category.dart' as category;
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/blocs/product/product_bloc.dart';
import 'package:maktub/presentation/user/screens/cart/cart_screen.dart';
import 'package:maktub/presentation/user/screens/cart/make_order_bottom_sheet.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
import 'package:maktub/presentation/user/screens/product/product_list_bottom_sheet.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';

class CartSupplierCard extends StatefulWidget {
  final CartSupplier supplier;
  final List<ValidatedCartItem> cartItems;
  final Color headerColor;

  final int organizationId;
  final int regionId;

  const CartSupplierCard({
    super.key,
    required this.organizationId,
    required this.regionId,
    required this.supplier,
    required this.cartItems,
    required this.headerColor,
  });

  @override
  State<CartSupplierCard> createState() => _CartSupplierCardState();
}

class _CartSupplierCardState extends State<CartSupplierCard> {
  final Map<int, ValueNotifier<double>> quantityNotifiers = {};
  final progressNotifier = ValueNotifier<double>(0.0);
  final totalPriceNotifier = ValueNotifier<double>(
    0.0,
  ); // НОВЫЙ ValueNotifier для общей суммы
  final Map<int, double> _itemsToUpdateInBloc = {};

  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();

    for (var cartItem in widget.cartItems) {
      final itemId = cartItem.item.id!;
      final initialQuantity = cartItem.item.cartQuantity!;
      _initQuantityNotifiers(widget.cartItems);
      quantityNotifiers[itemId] = ValueNotifier<double>(initialQuantity);

      // Добавляем слушателя для каждого quantityNotifier, чтобы обновлять и прогресс, и общую сумму
      quantityNotifiers[itemId]!.addListener(_updateTotals);
    }

    _updateTotals(); // Инициализация прогресса и общей суммы
  }

  @override
  void didUpdateWidget(covariant CartSupplierCard old) {
    super.didUpdateWidget(old);
    // если список товаров изменился — пересоздаём недостающие нотифайеры
    if (!listEquals(
      old.cartItems.map((e) => e.item.id).toList(),
      widget.cartItems.map((e) => e.item.id).toList(),
    )) {
      _initQuantityNotifiers(widget.cartItems);
      _updateTotals();
    }
  }

  void _initQuantityNotifiers(List<ValidatedCartItem> items) {
    for (var cartItem in items) {
      final id = cartItem.item.id!;
      if (!quantityNotifiers.containsKey(id)) {
        // создаём нотифайер с текущим количеством
        quantityNotifiers[id] = ValueNotifier<double>(cartItem.item.quantity);
        quantityNotifiers[id]!.addListener(_updateTotals);
      }
    }
  }

  void _debouncedCartUpdate() {
    _debouncer(() {
      if (!mounted) return;

      // Если нет изменений для отправки, выходим
      if (_itemsToUpdateInBloc.isEmpty) {
        return;
      }

      // Определяем organizationId и regionId из одного из элементов
      // Предполагается, что все товары внутри CartSupplierCard относятся к одной организации и региону.
      // Возможно, вам потребуется более надежная логика, если это предположение не всегда верно.
      int organizationId =
          widget.cartItems
              .firstWhere((ci) => ci.item.id == _itemsToUpdateInBloc.keys.first)
              .item
              .organizationId;
      int regionId = widget.regionId;

      // Создаем список для отправки в Bloc
      final List<Map<String, dynamic>> updates = [];
      _itemsToUpdateInBloc.forEach((itemId, newQuantity) {
        final item =
            widget.cartItems.firstWhere((ci) => ci.item.id == itemId).item;
        updates.add({
          'cartItemId': itemId,
          'newQuantity': newQuantity.clamp(
            item.quantity,
            double.infinity,
          ), // Убедимся, что количество не меньше шага
          'organizationId': item.organizationId,
          'regionId': widget.regionId,
        });
      });

      // Очищаем список ожидающих обновлений, так как мы их отправляем
      _itemsToUpdateInBloc.clear();

      // НОВОЕ СОБЫТИЕ BLOC: Отправляем все измененные товары одним запросом
      // Вам нужно будет добавить это событие в ваш CartBloc
      context.read<CartBloc>().add(
        UpdateMultipleCartItemsQuantity(
          updates: updates,
          regionId: regionId,
          organizationId: organizationId,
        ),
      );
    });
  }

  void _updateTotals() {
    double currentTotal = 0.0;
    for (var cartItem in widget.cartItems) {
      final itemId = cartItem.item.id!;
      final price = cartItem.item.price ?? 0.0;
      final quantity = quantityNotifiers[itemId]?.value ?? 0.0;
      currentTotal += price * quantity;
    }

    final progress = (currentTotal / widget.supplier.minOrderAmount).clamp(
      0.0,
      1.0,
    );
    progressNotifier.value = progress;
    totalPriceNotifier.value = currentTotal; // Обновляем totalPriceNotifier
  }

  // Вспомогательный метод для отправки удаления в Bloc
  void _sendRemoveToCartBloc(int cartItemId, int? organizationId) {
    // Убеждаемся, что товар удаляется из _itemsToUpdateInBloc, если он там был
    _itemsToUpdateInBloc.remove(cartItemId);

    context.read<CartBloc>().add(
      RemoveCartItem(
        regionId: widget.regionId,
        cartItemId: cartItemId,
        organizationId: organizationId!,
      ),
    );
    // После удаления, возможно, потребуется вызвать _debouncedCartUpdate(),
    // если вы хотите, чтобы удаление также дебаунсилось с другими изменениями.
    // Однако, обычно удаление делают мгновенным. Если нужно дебаунсить:
    // _debouncedCartUpdate();
  }


  @override
  void dispose() {
    for (var notifier in quantityNotifiers.values) {
      notifier.removeListener(_updateTotals);
      notifier.dispose();
    }
    progressNotifier.dispose();
    totalPriceNotifier.dispose(); // Не забудьте очистить
    _debouncer.dispose(); // Если у Debouncer есть метод dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems =
        widget
            .cartItems
            .length; // Преобразуем в double, если необходимо для сравнения

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Индикатор
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            // Здесь мы используем ValueListenableBuilder, чтобы отслеживать изменения progressNotifier
            // и передавать актуальное 'value' в TweenAnimationBuilder
            child: ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, currentValue, _) {
                // currentValue - это новое целевое значение
                return TweenAnimationBuilder<double>(
                  // TweenAnimationBuilder будет анимировать от своего предыдущего 'end' к новому 'end' (currentValue)
                  tween: Tween<double>(end: currentValue),
                  duration: const Duration(
                    milliseconds: 400,
                  ), // Длительность анимации
                  curve: Curves.easeOut, // Кривая анимации
                  builder: (context, animatedValue, _) {
                    return LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.headerColor,
                      ),
                      value: animatedValue, // Используем анимированное значение
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      minHeight: 3,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация о поставщике
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder:
                          (_) => BlocListener<AppStateCubit, AppState?>(
                            listenWhen:
                                (prev, curr) =>
                                    prev?.regionId != curr?.regionId,
                            listener: (context, state) {
                              if (state != null) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                });
                                // context.read<CartBloc>().add(LoadCart(organizationId, state.regionId));
                              }
                            },
                            child: ProductBottomSheetScreen(
                              title: widget.supplier.supplierName,
                              // brandId: selectedBrandId,
                              supplierId: widget.supplier.supplierId,
                            ),
                          ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.supplier.supplierName,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '~${getLocalizedDeliveryDate(context, widget.supplier.deliveryDay)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.minOrderAmount,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                             Text(
                              '${widget.supplier.minOrderAmount.toInt()}₸',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'тегін жеткізу – ${widget.supplier.deliveryFreeMinOrder.toInt()}₸',
                        //       style: GoogleFonts.montserrat(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4),

                // Переход в каталог поставщика
                if (totalItems < widget.supplier.minOrderItem)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent,
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.minCountOfProduct,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                               Text(
                                '${widget.supplier.minOrderItem}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder:
                                  (_) => BlocListener<AppStateCubit, AppState?>(
                                    listenWhen:
                                        (prev, curr) =>
                                            prev?.regionId != curr?.regionId,
                                    listener: (context, state) {
                                      if (state != null) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (Navigator.of(
                                                context,
                                              ).canPop()) {
                                                Navigator.of(context).pop();
                                              }
                                            });
                                        // context.read<CartBloc>().add(LoadCart(organizationId, state.regionId));
                                      }
                                    },
                                    child: ProductBottomSheetScreen(
                                      title: widget.supplier.supplierName,
                                      // brandId: selectedBrandId,
                                      supplierId: widget.supplier.supplierId,
                                    ),
                                  ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            splashFactory: NoSplash.splashFactory,
                            shadowColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            backgroundColor: widget.headerColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.catalogOfSupplier,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Список товаров
                ...widget.cartItems.map((cartItem) {
                  final item = cartItem.item;
                  final itemId = item.id!;
                  final quantityNotifier = quantityNotifiers[itemId]!;

                  // Создаем ValueNotifier для каждого item при первом рендере
                  if (!quantityNotifiers.containsKey(itemId)) {
                    quantityNotifiers[itemId] = ValueNotifier<double>(
                      item.cartQuantity!,
                    );
                  }

                  return ValueListenableBuilder(
                    valueListenable: quantityNotifier,
                    builder:
                        (context, value, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            color: Colors.white,
                            child: CartItemCard(
                              stockQuantity:  item.stockQuantity!-item.stockQuantity!%item.quantity,
                              unit: item.unit,
                              supplierQuantity: item.quantity,
                              imageUrl: item.imageUrl ?? '',
                              title: item.productName ?? '',
                              pricePerUnit: item.price ?? 0,
                              quantity: value,
                              totalPrice: (item.price ?? 0) * value,
                              onCardTap: () {
                                context.read<ProductBloc>().add(
                                  LoadProductByProductId(
                                    productId: cartItem.item.productId!,
                                  ),
                                );

                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder:
                                      (_) => BlocBuilder<
                                        ProductBloc,
                                        ProductState
                                      >(
                                        builder: (context, state) {
                                          if (state is ProductError) {
                                            Navigator.pop(context);
                                            return AlertDialog(
                                              content: Text(state.message),
                                            );
                                          }
                                          if (state is ProductLoadedById) {
                                            Navigator.pop(context);
                                            Future.microtask(() {
                                              if (!mounted) return;
                                              showProductBottomSheet(
                                                context,
                                                state.cartProduct,
                                                widget.regionId,
                                              );
                                            });
                                            return const SizedBox();
                                          }
                                          return Center(
                                            child:
                                                LoadingAnimationWidget.waveDots(
                                                  color: Gradients.primary,
                                                  size: 30,
                                                ),
                                          );
                                        },
                                      ),
                                );
                              },

                              onIncrement: () => _onIncrement(item),
                              onDecrement: () => _onDecrement(item),
                              onRemove:
                                  () => _sendRemoveToCartBloc(
                                    item.id!,
                                    item.organizationId,
                                  ),
                              onFavorite: () {},
                            ),
                          ),
                        ),
                  );
                }),

                const SizedBox(height: 4),

                // Итог и кнопка заказа
                ValueListenableBuilder<double>(
                  // НОВЫЙ ValueListenableBuilder для общей суммы
                  valueListenable: totalPriceNotifier,
                  builder: (context, currentTotalPrice, _) {
                    final isOrderValid =
                        currentTotalPrice >= widget.supplier.minOrderAmount &&
                        widget.cartItems.length >= widget.supplier.minOrderItem;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(18),
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Text(
                            //   'итого: ',
                            //   style: GoogleFonts.montserrat(
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 16,
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                '${currentTotalPrice.toStringAsFixed(0)}₸',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            ElevatedButton(
                              onPressed:
                                  isOrderValid
                                      ? () {
                                        showMakeOrderBottomSheet(
                                          context,
                                          supplier: widget.supplier,
                                          cartItems: widget.cartItems,
                                          headerColor: widget.headerColor,
                                          organizationId: widget.organizationId,
                                          regionId: widget.regionId,
                                        );
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                splashFactory: NoSplash.splashFactory,
                                overlayColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                backgroundColor:
                                    isOrderValid
                                        ? widget.headerColor
                                        : widget.headerColor.withOpacity(
                                          0.4,
                                        ), // тусклый фон
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: widget.headerColor
                                    .withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.makeOrder,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onIncrement(CartItem item) {
    final itemId = item.id!;
    final stockQuantity = item.stockQuantity!;
    final quantityStep = item.quantity;
    final currentQuantity = quantityNotifiers[itemId]!.value;

    if (currentQuantity >= stockQuantity) {
      // showTopSnackbar(
      //   context: context,
      //   vsync: this,
      //   message: 'Это всё, что есть на складе у поставщика',
      //   isError: true,
      //   withLove: false,
      // );
      return;
    }

    final newLocalQuantity = (currentQuantity + quantityStep).clamp(
      0.0,
      stockQuantity,
    );
    quantityNotifiers[itemId]!.value = newLocalQuantity;

    // ТЕПЕРЬ: Отслеживаем этот элемент для пакетного обновления в Bloc
    _itemsToUpdateInBloc[itemId] = newLocalQuantity;
    _debouncedCartUpdate(); // Вызываем общий Debouncer
  }

  void _onDecrement(CartItem item) {
    final itemId = item.id!;
    final quantityStep = item.quantity;
    final currentQuantity = quantityNotifiers[itemId]!.value;

    // Если текущее количество меньше или равно шагу, то удаляем
    if (currentQuantity <= quantityStep) {
      _sendRemoveToCartBloc(
        itemId,
        item.organizationId,
      ); // Удаление происходит сразу
      return;
    }

    final newLocalQuantity = (currentQuantity - quantityStep).clamp(
      0.0,
      double.infinity,
    );
    quantityNotifiers[itemId]!.value = newLocalQuantity;

    // ТЕПЕРЬ: Отслеживаем этот элемент для пакетного обновления в Bloc
    _itemsToUpdateInBloc[itemId] = newLocalQuantity;
    _debouncedCartUpdate(); // Вызываем общий Debouncer
  }
String getLocalizedDeliveryDate(BuildContext context, int offset) {
  final loc = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final deliveryDate = now.add(
    Duration(days: offset + (now.hour >= 20 ? 1 : 0)),
  );

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

  final dayName = weekdays[deliveryDate.weekday - 1];
  final monthName = months[deliveryDate.month - 1];

  return '$dayName, ${deliveryDate.day} $monthName';
}


}

void showProductBottomSheet(
  BuildContext parentContext,
  CartProduct product,
  int regionId,
) {
  int currentImageIndex = 0;
  final pageController = PageController();
  final controller = DraggableScrollableController();
  late final Map<category.Category, List<category.Category>> categoriesMap;
  final productDetailsBloc = parentContext.read<ProductBloc>();
  productDetailsBloc.add(
    LoadBothProductAndSuppliers(
      regionId: regionId,
      categoryId: product.categoryId,
      productId: product.productId,
    ),
  );

  final cartBloc = parentContext.read<CartBloc>();
  categoriesMap = parentContext.read<AppStateCubit>().state?.categories ?? {};
  int organizationId =
      parentContext.read<AppStateCubit>().state?.workplaceId ?? 1;

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
          
                                      double quantity = 0;
                                      bool isInCart = false;
                                      final cartState =
                                          context.watch<CartBloc>().state;
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
                                //     onTap: () {},
                                //     child: Container(
                                //       decoration: const BoxDecoration(
                                //         color: Colors.transparent,
                                //         shape: BoxShape.circle,
                                //       ),
                                //       child: Image.asset(
                                //         'assets/icons-system/favorites-green.png',
                                //         width: 25,
                                //         height: 25,
                                //       ),
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

Color _getHeaderColor(int index) {
  const colors = [
    Gradients.primary,

    Colors.amber,
    Colors.pink,
    // Colors.greenAccent,
  ];
  return colors[index % colors.length];
}
