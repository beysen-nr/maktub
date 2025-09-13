// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/dto/order_item_create_dto.dart';
import 'package:maktub/data/models/address.dart';
import 'package:maktub/data/models/cart_supplier.dart';
import 'package:maktub/data/models/promo.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/domain/repositories/order_repo.dart';
import 'package:maktub/domain/utils/order_builder.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/blocs/promo/promo_bloc.dart';
import 'package:maktub/presentation/user/blocs/promo/promo_event.dart';
import 'package:maktub/presentation/user/blocs/promo/promo_state.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
import 'package:maktub/presentation/user/screens/product/product_list_bottom_sheet.dart';

void showMakeOrderBottomSheet(
  BuildContext context, {
  required CartSupplier supplier,
  required List<ValidatedCartItem> cartItems,
  required Color headerColor,
  required int organizationId,
  required int regionId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Colors.transparent,
    builder: (context) {
      return BlocProvider(
        create: (context) => PromoBloc(PromoRepository()),
        child: FractionallySizedBox(
          heightFactor: 0.93,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                CartSupplierOrderCard(
                  supplier: supplier,
                  cartItems: cartItems,
                  headerColor: headerColor,
                  organizationId: organizationId,
                  regionId: regionId,
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
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
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
                            Center(
                              child: Text(
                                AppLocalizations.of(context)!.makeOrder,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class CartSupplierOrderCard extends StatefulWidget {
  final CartSupplier supplier;
  final List<ValidatedCartItem> cartItems;
  final Color headerColor;
  final int organizationId;
  final int regionId;

  const CartSupplierOrderCard({
    super.key,
    required this.organizationId,
    required this.regionId,
    required this.supplier,
    required this.cartItems,
    required this.headerColor,
  });

  @override
  State<CartSupplierOrderCard> createState() => _CartSupplierOrderCardState();
}

class _CartSupplierOrderCardState extends State<CartSupplierOrderCard> {
  DateTime? _selectedDeliveryDate;

  Future<void> _submitOrder(BuildContext context) async {
    final appState = context.read<AppStateCubit>().state!;
    final address = appState.selectedAddress!;
    final organizationId = appState.workplaceId;
    final regionId = appState.regionId;
    final supplierId = widget.supplier.supplierId;
    final deliveryDate = DateTime.now().add(
      Duration(days: widget.supplier.deliveryDay),
    );
    final otp = Random().nextInt(9000) + 1000;
    final promoState = context.read<PromoBloc>().state;
    int? usedPromocodeId;
    String? promo;
    int? newQuantity;
    int? useCount;

    if (promoState is PromoLoaded) {
      usedPromocodeId = promoState.promo.id;
      itemDiscounts = calculateDiscountPerItem(
        widget.cartItems,
        promoState.promo,
      );
      promo = promoState.promo.promocode;
      if (promoState.promo.usedTimes == null) {
        newQuantity = 1;
      } else {
        newQuantity = promoState.promo.usedTimes! + 1;
      }
      useCount = promoState.promo.useCount;
    }

    final items = widget.cartItems.map((cartItem) {
      final item = cartItem.item;
      final discount = itemDiscounts[item.id] ?? 0;

      return OrderItemCreateDto.fromCartItem(
        item,
        discount: discount,
        ndsPercentage: widget.supplier.ndsPercentage,
      );
    }).toList();



    final dto = buildOrderFromCart(
      addressPoint: address.point,
      cartItems: widget.cartItems,
      organizationId: organizationId,
      supplierId: supplierId,
      deliveryAddress: address.address,
      deliveryDate: _selectedDeliveryDate ?? deliveryDate,
      deliveryFee: 0,
      otp: otp,
      status: 1,
      nameOfPoint: address.nameOfPoint,
      usedPromocodeId: usedPromocodeId,
      itemDiscounts: itemDiscounts,
      ndsPercentage: widget.supplier.ndsPercentage,
      note: address.commentForDelivery,
    );

    try {
      final repository = OrderRepository(client: SupabaseService.client);
      if (usedPromocodeId != null) {
        final promoRepo = PromoRepository();
        await promoRepo.updateUsecountPromo(
          organizationId,
          supplierId,
          promo!,
          newQuantity!,
          useCount!,
        );
      }
      await repository.createOrder(dto);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.orderSuccessfullyMaked,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Gradients.primary,
          elevation: 0,
          showCloseIcon: true,
          closeIconColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );

      context.read<CartBloc>().add(
        RemoveSupplierItems(
          supplierId: supplierId,
          organizationId: organizationId,
          regionId: regionId,
        ),
      );
      context.pop(); // или очистка корзины, переход и т.д.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorTryLater,
          
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.redAccent,
          elevation: 0,
          showCloseIcon: true,
          closeIconColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
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

  Map<int, double> itemDiscounts = {};

  Map<int, double> calculateDiscountPerItem(
    List<ValidatedCartItem> items,
    PromoModel promo,
  ) {
    final double total = items.fold(
      0,
      (sum, item) => sum + (item.item.price ?? 0) * item.item.cartQuantity!,
    );

    if (promo.fixedDiscount!) {
      final double discount = promo.discount!.toDouble();
      return {
        for (var item in items)
          item.item.id!:
              ((item.item.price ?? 0) * item.item.cartQuantity! / total) *
              discount,
      };
    } else {
      final double discountRate = promo.discount! / 100;
      return {
        for (var item in items)
          item.item.id!:
              ((item.item.price ?? 0) * item.item.cartQuantity!) * discountRate,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateCubit>().state;
    final address = appState?.selectedAddress;
    final regionId = appState?.regionId ?? widget.regionId;
    final organizationId = appState?.workplaceId ?? widget.organizationId;
    final totalPrice = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + ((item.item.price ?? 0) * item.item.cartQuantity!),
    );
    final supplierId = widget.cartItems.first.item.supplierId ?? 0;

    return BlocListener<AppStateCubit, AppState?>(
      listenWhen: (prev, curr) =>
          prev?.regionId != curr?.regionId ||
          prev?.selectedAddress != curr?.selectedAddress,
      listener: (context, state) {
        if (state != null) {
          if (state.regionId != appState?.regionId && context.canPop()) {
            context.pop();
          } else {
            // setState(() {});
          }
        }
      },
      child: _buildContent(
        context,
        address,
        regionId,
        organizationId,
        totalPrice,
        supplierId,
      ),
    );
  }

  String? _lastAppliedPromoCode;

  Widget _buildContent(
    BuildContext context,
    Address? address,
    int regionId,
    int organizationId,
    double totalPrice,
    int supplierId,
  ) {
    final totalItems = widget
        .cartItems
        .length; // Преобразуем в double, если необходимо для сравнения
    Address? address = context.read<AppStateCubit>().state!.selectedAddress;
    int regionId = context.read<AppStateCubit>().state!.regionId;
    int organizationId = context.read<AppStateCubit>().state!.workplaceId;

    final double totalPrice = widget.cartItems.fold(0, (sum, cartItem) {
      final item = cartItem.item;
      return sum + ((item.price ?? 0) * item.cartQuantity!);
    });

    int supplierId = widget.cartItems.first.item.supplierId ?? 0;


    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),

            // Индикатор
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.deliveryAddress,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      context.push(
                        RouteNames.addressList,
                        extra: {
                          'workplaceId': context
                              .read<AppStateCubit>()
                              .state!
                              .workplaceId,
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          address == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.chooseAddress,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      address.nameOfPoint,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      address.address,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                          Spacer(),
                          Image.asset(
                            'assets/icons-system/arrow.png',
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.day,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DaySlotSelector(
                    context: context,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDeliveryDate = date;
                      });
                    },
                    supplierDeliveryDay: widget.supplier.deliveryDay,
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: 100),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut, // Кривая анимации
                builder: (context, animatedValue, _) {
                  return LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.headerColor,
                    ),
                    value: animatedValue,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    minHeight: 3,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
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
                        builder: (_) => BlocListener<AppStateCubit, AppState?>(
                          listenWhen: (prev, curr) =>
                              prev?.regionId != curr?.regionId,
                          listener: (context, state) {
                            if (state != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
                          // Text(
                          //   'тегін жеткізу – ${widget.supplier.deliveryFreeMinOrder.toInt()}₸',
                          //   style: GoogleFonts.montserrat(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.w500,
                          //   ),
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
                              context.pop();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (_) =>
                                    BlocListener<AppStateCubit, AppState?>(
                                      listenWhen: (prev, curr) =>
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

                  ...widget.cartItems.map((cartItem) {
                    final item = cartItem.item;
                
                    final itemDiscount = itemDiscounts[item.id] ?? 0;
                    final discountedTotal =
                        ((item.price ?? 0) * item.cartQuantity!) - itemDiscount;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        color: Colors.white,
                        child: OrderItemCard(
                          unit: item.unit,
                          supplierQuantity: item.quantity,
                          imageUrl: item.imageUrl ?? '',
                          title: item.productName ?? '',
                          pricePerUnit: item.price ?? 0,
                          quantity: item.cartQuantity!,
                          totalPrice: (item.price ?? 0) * item.cartQuantity!,
                          discount: itemDiscount,
                          discountedTotal: discountedTotal,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  PromoCodeInput(
                    headerColor: widget.headerColor,
                    regionId: regionId,
                    supplierId: supplierId,
                    organizationId: organizationId,
                  ),
                  const SizedBox(height: 8),

                  // BlocBuilder<PromoBloc, PromoState>(
                  //   builder: (context, state) {
                  //     if (state is PromoLoaded) {
                  //       final promo = state.promo;
                  //       final originalPrice =
                  //           10000.0; // Замените на вашу логику расчета
                  //       final discountedPrice = context
                  //           .read<PromoBloc>()
                  //           .calculateDiscountedPrice(originalPrice, promo);
                  //       return Padding(
                  //         padding: const EdgeInsets.symmetric(
                  //           vertical: 8.0,
                  //         ),
                  //         child: PromoEffectWidget(
                  //           originalPrice: originalPrice,
                  //           discountedPrice: discountedPrice,
                  //         ),
                  //       );
                  //     }
                  //     return SizedBox.shrink();
                  //   },
                  // ),
                  BlocListener<PromoBloc, PromoState>(
                    listener: (context, state) {
                      if (state is PromoLoaded &&
                          _lastAppliedPromoCode != state.promo.promocode) {
                        setState(() {
                          itemDiscounts = calculateDiscountPerItem(
                            widget.cartItems,
                            state.promo,
                          );
                          _lastAppliedPromoCode = state.promo.promocode;
                        });
                      } else if (state is PromoError) {
                        setState(() {
                          itemDiscounts.clear();
                          _lastAppliedPromoCode = null;
                        });
                      }
                    },
                    child: BlocBuilder<PromoBloc, PromoState>(
                      builder: (context, state) {
                        double finalPrice = totalPrice;
                        double? discountPrice;

                        if (state is PromoLoaded) {
                          final promo = state.promo;
                          finalPrice = context
                              .read<PromoBloc>()
                              .calculateDiscountedPrice(totalPrice, promo);
                          discountPrice = finalPrice;
                        }

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
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: discountPrice != null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${totalPrice.toStringAsFixed(2)}₸',
                                              style: GoogleFonts.montserrat(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontSize: 16,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            ShaderMask(
                                              shaderCallback: (bounds) =>
                                                  LinearGradient(
                                                    colors: [
                                                      Gradients.primary,
                                                      Colors.amber,
                                                      Gradients.primary,
                                                      Colors.redAccent,
                                                    ],
                                                  ).createShader(bounds),
                                              child: Text(
                                                '${discountPrice.toStringAsFixed(2)}₸',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '${totalPrice.toStringAsFixed(2)}₸',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                ),
                                ElevatedButton(
                                  onPressed: address != null
                                      ? () => _submitOrder(context)
                                      : () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(context)!.chooseAddress,
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              backgroundColor: Colors.redAccent,
                                              elevation: 0,
                                              showCloseIcon: true,
                                              closeIconColor: Colors.white,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    splashFactory: NoSplash.splashFactory,
                                    overlayColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    backgroundColor: widget.headerColor,
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
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double pricePerUnit;
  final int unit;
  final double quantity;
  final double totalPrice;
  final double supplierQuantity;
  final double discount;
  final double discountedTotal;

  const OrderItemCard({
    super.key,
    required this.supplierQuantity,
    required this.unit,
    required this.imageUrl,
    required this.title,
    required this.pricePerUnit,
    required this.quantity,
    required this.totalPrice,
    required this.discount,
    required this.discountedTotal,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = discount > 0;
    final String unitLabel = unit == 1 ? '₸/шт' : '₸/кг';
    final String quantityText = quantity.toStringAsFixed(2);

    final double discountedPricePerUnit = hasDiscount
        ? discountedTotal / quantity
        : pricePerUnit;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          SizedBox(
            width: 100,
            height: double.infinity,
            child: FadeInNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          const SizedBox(width: 12),

          // Title, price/kg, actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (hasDiscount) ...[
                  Text(
                    '${pricePerUnit.toStringAsFixed(2)} $unitLabel',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.amber,
                        Gradients.primary,
                        Colors.redAccent,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '${discountedPricePerUnit.toStringAsFixed(2)} $unitLabel',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else
                  Text(
                    '${pricePerUnit.toStringAsFixed(2)} $unitLabel',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                // const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.inThePackage,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                     Text(
                      '$supplierQuantity',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Цена
                    Column(
                      children: [
                        Text(
                          hasDiscount
                              ? '${(totalPrice).toStringAsFixed(2)}₸'
                              : '${discountedTotal.toStringAsFixed(2)}₸',
                          style: GoogleFonts.montserrat(
                            decoration: hasDiscount
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: hasDiscount ? Colors.grey : Colors.black,
                          ),
                        ),
                        if (hasDiscount)
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.amber,
                                Gradients.primary,
                                Colors.redAccent,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '${discountedTotal.toStringAsFixed(2)}₸',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.quantity,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50,
                            child: Center(
                              child: Text(
                                quantityText,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromoCodeInput extends StatefulWidget {
  final Color headerColor;
  final int supplierId;
  final int organizationId;
  final int regionId;

  const PromoCodeInput({
    Key? key,
    required this.headerColor,
    required this.supplierId,
    required this.organizationId,
    required this.regionId,
  }) : super(key: key);

  @override
  State<PromoCodeInput> createState() => _PromoCodeInputState();
}

class _PromoCodeInputState extends State<PromoCodeInput> {
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _promoCodeController.addListener(_validateInput);
  }

  void _validateInput() {
    final text = _promoCodeController.text;
    final isMatch = RegExp(r'^[a-zA-Z0-9]{8}$').hasMatch(text);
    setState(() {
      _isValid = isMatch;
    });
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  void _applyPromoCode(BuildContext context) {
    final code = _promoCodeController.text.trim();
 
    context.read<PromoBloc>().add(
      FetchPromoByCode(
        code: code,
        supplierId: widget.supplierId,
        organizationId: widget.organizationId,
        regionId: widget.regionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromoBloc, PromoState>(
      listener: (context, state) {
        if (state is PromoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.code,
                // 'Промокод жарамсыз',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              backgroundColor: Colors.redAccent,
              elevation: 0,
              showCloseIcon: true,
              closeIconColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
        } else if (state is PromoLoaded) {

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: state.promo.fixedDiscount!
                  ? Row(
                    children: [
                      Text(
                          AppLocalizations.of(context)!.discountOfPromo,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                                Text(
                          '${state.promo.discount}₸',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  )
                  : Row(
                    children: [
                      Text(
                          AppLocalizations.of(context)!.discountOfPromo,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                                 Text(
                          '-${state.promo.discount}%',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
              backgroundColor: Gradients.primary,
              elevation: 0,
              showCloseIcon: true,
              closeIconColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
   
        }
      },
      builder: (context, state) {
        final isLoading = state is PromoLoading;

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
              top: Radius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCodeController,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterPromo,
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: widget.headerColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isValid && !isLoading)
                      ? () => _applyPromoCode(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    backgroundColor: _isValid
                        ? widget.headerColor
                        : widget.headerColor.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(100, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.apply,
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
    );
  }
}

class DaySlotSelector extends StatefulWidget {
  final int supplierDeliveryDay;
  final BuildContext context;
  final Function(DateTime) onDateSelected;

  const DaySlotSelector({
    super.key,
    required this.context,
    required this.supplierDeliveryDay,
    required this.onDateSelected,
  });

  @override
  State<DaySlotSelector> createState() => _DaySlotSelectorState();
}

class _DaySlotSelectorState extends State<DaySlotSelector> {
  late DateTime _startDate;


  late List<String> _days;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final shouldShift = now.hour >= 20;
    _startDate = now.add(
      Duration(days: widget.supplierDeliveryDay + (shouldShift ? 1 : 0)),
    );
    _days = _generateNextDeliveryDays(widget.context, _startDate);
  }

  List<String> _generateNextDeliveryDays(BuildContext context, DateTime startDate) {
      final loc = AppLocalizations.of(context)!;
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
    return List.generate(7, (i) {
      final date = startDate.add(Duration(days: i));
      final day = weekdays[date.weekday - 1];
      final month = months[date.month - 1];
      return '$day, ${date.day} $month';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_days.length, (index) {
              final isSelected = index == _selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    widget.onDateSelected(
                      _startDate.add(Duration(days: index)),
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE4F7E9)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Gradients.primary
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _days[index],
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class PromoEffectWidget extends StatelessWidget {
  final double originalPrice;
  final double discountedPrice;

  const PromoEffectWidget({
    Key? key,
    required this.originalPrice,
    required this.discountedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${originalPrice.toStringAsFixed(2)}₸',
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.amber, Gradients.primary, Colors.redAccent],
          ).createShader(bounds),
          child: Text(
            '${discountedPrice.toStringAsFixed(2)}₸',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Цвет будет заменен ShaderMask
            ),
          ),
        ),
      ],
    );
  }
}
