import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/cart_supplier.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/cart/cart_bloc.dart';
import 'package:maktub/presentation/user/screens/cart/cart_widgets.dart';
import 'package:maktub/presentation/user/screens/product/product_card.dart';
import 'package:shimmer/shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  final Debouncer _debouncer = Debouncer(delay: Duration(milliseconds: 15000));
  final Map<int, int> pendingIncrements = {};
  final Map<int, TextEditingController> _controllers = {};
  int get organizationId =>
      context.read<AppStateCubit>().state?.workplaceId ?? 0;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateCubit>().state;
    if (appState != null) {
      context.read<CartBloc>().add(
        LoadCart(appState.workplaceId, appState.regionId),
      );
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppStateCubit>().state;


    int regionId = appState!.regionId;
    bool cartIsEmpty = false;

    return MultiBlocListener(
      listeners: [
        BlocListener<AppStateCubit, AppState?>(
          listenWhen: (prev, curr) => prev?.regionId != curr?.regionId,
          listener: (context, state) {
            if (state != null) {
              context.read<CartBloc>().add(
                LoadCart(organizationId, state.regionId),
              );
              regionId = state.regionId;
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listener: (context, state) {
         if(state is CartEmpty){
          cartIsEmpty = true;
         }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          leading: TextButton(
            style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
            onPressed: () {
          context.push(RouteNames.order);
            },
            child: Image.asset(
              'assets/icons-system/order.png',
              height: 30,
              width: 30,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.cart,
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              onPressed: () {
                cartIsEmpty ?
              null :   context.read<CartBloc>().add(
                  ClearCart(organizationId: organizationId, regionId: regionId),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.clearCart,
                style: GoogleFonts.montserrat(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            Widget currentBody;
            if (state is CartLoading) {
              currentBody = Padding(
                key: const ValueKey('cart-loading'),
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.white,
                          child: Container(
                            height:
                                105, // Примерная высота для карточки поставщика
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),

                        child: Container(
                          height:
                              100, // Примерная высота для карточки поставщика
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: double.infinity,
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.white,
                                    child: Container(
                                      height: 100,
                                      width:
                                          100, // Примерная высота для карточки поставщика
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Gradients.primary
                                            .withOpacity(0.55),
                                        highlightColor: Gradients.primary,
                                        child: Text(
                                          AppLocalizations.of(context)!.reasonablePrice,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(height: 4),
                                      Shimmer.fromColors(
                                        baseColor: Gradients.primary
                                            .withOpacity(0.55),
                                        highlightColor: Gradients.primary,
                                        child: Text(
                                          AppLocalizations.of(context)!.onlyOnOurService,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),

                        child: Container(
                          height:
                              100, // Примерная высота для карточки поставщика
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: double.infinity,
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.white,
                                    child: Container(
                                      height: 100,
                                      width:
                                          100, // Примерная высота для карточки поставщика
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        // period:  Duration(milliseconds: 400),
                                        baseColor: Gradients.primary
                                            .withOpacity(0.55),
                                        highlightColor: Gradients.primary,
                                        child: Text(
                                          AppLocalizations.of(context)!.theBiggestDiscount,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(height: 4),
                                      Shimmer.fromColors(
                                        baseColor: Gradients.primary
                                            .withOpacity(0.55),
                                        highlightColor: Gradients.primary,
                                        child: Text(
                                          AppLocalizations.of(context)!.onlyForYou,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),

                        child: Container(
                          height:
                              100, // Примерная высота для карточки поставщика
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: double.infinity,
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[200]!,
                                    highlightColor: Colors.white,
                                    child: Container(
                                      height: 100,
                                      width:
                                          100, // Примерная высота для карточки поставщика
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Gradients.primary
                                            .withOpacity(0.55),
                                        highlightColor: Gradients.primary,
                                        child: Text(
                                          AppLocalizations.of(context)!.letsRejoiceTogether,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(height: 4),
                                      Shimmer.fromColors(
                                        baseColor: Gradients.primary
                                            .withOpacity(0.55),
                                        highlightColor: Gradients.primary,
                                        child: Text(
                                          AppLocalizations.of(context)!.youAndWeToo,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.white,
                          child: Container(
                            height:
                                60, // Примерная высота для карточки поставщика
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is CartLoaded) {
              final items = state.items;
              final suppliers = state.suppliers;
              if(items.isNotEmpty){
                cartIsEmpty = false;
              }

              // Группировка по поставщику
              final Map<int, List<ValidatedCartItem>> groupedItems = {};
              for (final item in items) {
                final supplierId = item.item.supplierId;
                groupedItems.putIfAbsent(supplierId!, () => []).add(item);
              }

              final sortedSupplierIds = groupedItems.keys.toList()..sort();
final validSupplierIds = sortedSupplierIds.where((id) {
  return suppliers.any((s) => s.supplierId == id);
}).toList();


       currentBody = ListView.builder(
  key: const ValueKey('cart-list'),
  itemCount: validSupplierIds.length,
  itemBuilder: (context, index) {
    final supplierId = validSupplierIds[index];
    final cartItems = groupedItems[supplierId]!;

    final supplier = suppliers.firstWhere((s) => s.supplierId == supplierId);


                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: CartSupplierCard(
                      organizationId: organizationId,
                      regionId: regionId,
                      supplier: supplier,
                      cartItems: cartItems,
                      headerColor: _getHeaderColor(index),
                      
                    
                    ),
                  );
                },
              );
            } else if (state is CartError) {
              currentBody = Padding(
                key: const ValueKey('cart-error'),
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.error,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            } else if (state is CartEmpty) {
           currentBody = Center(
  key: ValueKey('cart-empty'),
  child: Scaffold(
    backgroundColor: Colors.white,
    body:
    
     Center( // Этот Center центрирует свой дочерний элемент
      // Обернем содержимое body в Expanded или SizedBox.expand()
      child: SizedBox.expand( // <-- Используем SizedBox.expand() чтобы занять всё доступное пространство
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Центрируем по вертикали
            crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем по горизонтали (для кнопки и текста)
            children: [
              Text(
                AppLocalizations.of(context)!.yourCartIsEmpty,
                style: GoogleFonts.montserrat(
                  color: Gradients.bigTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center, // Центрируем сам текст
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.maybeWeWillFillYourBasket,
                style: GoogleFonts.montserrat(
                  color: Gradients.detailTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center, // Центрируем сам текст
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  context.go(RouteNames.catalog);
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
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Text(
                  AppLocalizations.of(context)!.seeCatalog,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
            } else
              // ignore: curly_braces_in_flow_control_structures
              currentBody = const Center(
                key: ValueKey('cart'),
                child: Text('себетіңіз бос екен'),
              );

            return AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 1000,
              ), // Длительность перехода
              child: currentBody,
            );
          },
        ),
      ),
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

}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class CartItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double pricePerUnit;
  final int unit;
  final double quantity;
  final double totalPrice;
  final double supplierQuantity;
  final double stockQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onFavorite;
  final VoidCallback onCardTap;

  const CartItemCard({
    super.key,
    required this.stockQuantity,
    required this.supplierQuantity,
    required this.unit,
    required this.imageUrl,
    required this.title,
    required this.pricePerUnit,
    required this.quantity,
    required this.totalPrice,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onFavorite,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final String unitLabel = unit == 1 ? '₸/шт' : '₸/кг';
    final String quantityText =
        unit == 1 ? quantity.toInt().toString() : quantity.toStringAsFixed(1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          GestureDetector(
            onTap: onCardTap,
            child: SizedBox(
              width: 100,
              height: 100,
              child: AspectRatio(
                aspectRatio: 1,
                child: FadeInNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                      child: GestureDetector(
                        onTap: onCardTap,
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
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${pricePerUnit.toStringAsFixed(0)} $unitLabel',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                   Row(
                     children: [
                                 Text(
AppLocalizations.of(context)!.inThePackage,
                                         style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                                         ),),
                       Text(
                                         '$supplierQuantity',
                                         style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                                         ),),
                     ],
                   ),
                const SizedBox(height: 33),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Кнопки   

                    // Цена
                    Text(
                      '${totalPrice.toInt()} ₸',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                          GestureDetector(

                            onTap: onDecrement,
                            child: quantity > supplierQuantity ?  Icon(Icons.remove, size: 20) : Icon(Icons.close, size: 18),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width:
                                50, // фиксированная ширина, подбери по дизайну
                            child: Center(
                              child: Text(
                                quantityText,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: quantity <= stockQuantity ? onIncrement : (){},
                            child: Container(
                              padding: EdgeInsets.all(2),
                              child: quantity != stockQuantity ? Icon(Icons.add, size: 20): SizedBox(width:20, height: 20,)) ,
                          ),
                        ],
                      ),
                    ),

                    // Spacer между кнопками и ценой
                    // const SizedBox(width: 10),

                    // // Цена
                    // Text(
                    //   '${totalPrice.toInt()} ₸',
                    //   style: GoogleFonts.montserrat(
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 16,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),

          // // Price & close
          // Column(
          //   children: [

          //     const SizedBox(height: 50),
          //     Text(
          //       '${totalPrice.toInt()} ₸',
          //       style: GoogleFonts.montserrat(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 14,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
