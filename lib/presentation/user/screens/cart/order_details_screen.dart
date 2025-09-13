import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/data/models/order.dart';
import 'package:maktub/data/models/order_item.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/domain/repositories/order_repo.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/order/order_bloc.dart';
import 'package:maktub/presentation/user/blocs/order/order_event.dart';
import 'package:maktub/presentation/user/screens/cart/make_order_bottom_sheet.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shimmer/shimmer.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String ownerName = context.read<AppStateCubit>().state!.ownerName;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.order,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' №${order.id}',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  order.supplierName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                buildStatusContainer(context, order.status ?? 0),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FutureBuilder<List<OrderItem>>(
              future: OrderRepository(
                client: SupabaseService.client,
              ).loadOrderItems(order.id),
              builder: (context, snapshot) {
                Widget content;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  content = Column(
                    key: const ValueKey('shimmer'),
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: OrderItemCardShimmer(),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  content = Center(
                    key: const ValueKey('error'),
                    child: Text(
                      AppLocalizations.of(context)!.error,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  );
                } else {
                  final items = snapshot.data ?? [];
                  order.items = items;
                  content = Column(
                    key: const ValueKey('items'),
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: OrderItemCard(
                              imageUrl: item.image,
                              title: item.productName,
                              pricePerUnit: item.finalPrice! / item.quantity,
                              unit: 1,
                              quantity: item.quantity,
                              totalPrice: item.finalPrice!,
                              supplierQuantity: item.supplierQuantity,
                              discount: 0,
                              discountedTotal: item.finalPrice!,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }

                return AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1000),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Builder(
                      builder: (_) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            key: const ValueKey('shimmer'),
                            children: List.generate(
                              3,
                              (_) => Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: OrderItemCardShimmer(),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            key: const ValueKey('error'),
                            child: Text(
                              AppLocalizations.of(context)!.error,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }

                        final items = snapshot.data ?? [];
                        return Column(
                          key: const ValueKey('items'),
                          children: items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: OrderItemCard(
                                    imageUrl: item.image,
                                    title: item.productName,
                                    pricePerUnit:
                                        item.finalPrice! / item.quantity,
                                    unit: 1,
                                    quantity: item.quantity,
                                    totalPrice: item.finalPrice!,
                                    supplierQuantity: item.supplierQuantity,
                                    discount: 0,
                                    discountedTotal: item.finalPrice!,
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            if (order.status == 2) ...[
              // const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalSum,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${order.finalPrice?.toStringAsFixed(2) ?? ''}₸',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showOtpBottomSheet(
                    context,
                    order.otp.toString().padLeft(4, '0'),
                  );
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Gradients.primary),
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
                  AppLocalizations.of(context)!.applyOrder,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showCancelBottomSheet(context, context.read<OrderBloc>());
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Colors.redAccent),
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
                  AppLocalizations.of(context)!.cancelOrder,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (order.status == 3) ...[
              // const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalSum,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${order.finalPrice?.toStringAsFixed(2) ?? ''}₸',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (order.rating == null) ...[
                ElevatedButton(
                  onPressed: () {
                    showRatingBottomSheet(context);
                  },
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(Gradients.primary),
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
                    AppLocalizations.of(context)!.rateOrder,
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],

              ElevatedButton(
                onPressed: () {
                  genExpenditureInvoice(order, ownerName);
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(Gradients.primary),
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
                  AppLocalizations.of(context)!.expenseInvoice,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildStatusContainer(BuildContext context, int status) {
    String text;
    Color color;

    switch (status) {
      case 1:
        text = AppLocalizations.of(context)!.inProcessing;
        color = Colors.amber;
        break;
      case 2:
        text = AppLocalizations.of(context)!.onTheWay;
        color = Colors.deepPurpleAccent;
        break;
      case 3:
        text = AppLocalizations.of(context)!.delivered;
        color = Gradients.primary;
        break;
      case 4:
        text = AppLocalizations.of(context)!.cancelled;
        color = Colors.redAccent;
        break;
      default:
        text = 'белгісіз';
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> showRatingBottomSheet(
    BuildContext context,
  ) async {
    int rating = 0;
    final TextEditingController reviewController = TextEditingController();

    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.rateOrder,
                          style: GoogleFonts.montserrat(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        /// 5 звёзд
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final isSelected = rating >= index + 1;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  rating = index + 1;
                                });
                              },
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 250),
                                tween: Tween<double>(
                                  begin: rating >= index + 1 ? 0 : 1,
                                  end: rating >= index + 1 ? 1 : 0,
                                ),
                                builder: (context, value, child) {
                                  final color = Color.lerp(
                                    Colors.grey.shade200,
                                    Gradients.primary,
                                    value,
                                  );
                                  final iconColor = Color.lerp(
                                    Colors.grey.shade400,
                                    Colors.amber,
                                    value,
                                  );
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      size: 28 + value * 4,
                                      color: iconColor,
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        /// Поле для отзыва
                        TextField(
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                          ),

                          controller: reviewController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.writeReview,
                            hintStyle: GoogleFonts.montserrat(),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Gradients.primary),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ), // серый по умолчанию
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Gradients.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!.thanksForReview,
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            );

                            OrderRepository(
                              client: SupabaseService.client,
                            ).leaveReview(
                              orderId: order.id,
                              rating: rating,
                              review: reviewController.text,
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
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.sendReview,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showOtpBottomSheet(BuildContext context, String otp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.codeForDelivery,
                      style: GoogleFonts.montserrat(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    /// Отображение кода без возможности редактирования
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Gradients.primary),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        otp,
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                        // TODO: действия по принятию заказа
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
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueB,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showCancelBottomSheet(BuildContext context, OrderBloc bloc) {
    String? selectedReason;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.reasonOfCancel,

                              // 'не себептен бас тартқыңыз келеді?',
                              style: GoogleFonts.montserrat(
                                fontSize: 17.5,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                context.pop();
                              },
                              child: Icon(
                                Icons.close,
                                size: 25,
                                color: Gradients.hintText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RadioListTile<String>(
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Gradients.primary,
                          ),
                          title: Text(
                            AppLocalizations.of(context)!.productQuality,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: 'Does not meet quality standards.',
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() => selectedReason = value);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(
                            AppLocalizations.of(context)!.ownDiscration,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Gradients.primary,
                          ),

                          value: 'As per the customer’s desire.',
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() => selectedReason = value);
                          },
                        ),

                        RadioListTile<String>(
                          title: Text(
                            AppLocalizations.of(context)!.deliveryAsked,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Gradients.primary,
                          ),

                          value: 'The supplier requested to cancel.',
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() => selectedReason = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: selectedReason != null
                              ? () {
                                  bloc.add(
                                    CancelOrder(
                                      reasonValue: selectedReason!,
                                      orderId: order.id,
                                      organizationId: order.organizationId,
                                      supplierId: order.supplierId,
                                    ),
                                  );
                                  context.pop();
                                  context.pop();
                                }
                              : null,
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
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.continueB,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class OrderItemCardShimmer extends StatelessWidget {
  const OrderItemCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 100,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                ShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: 6),

                // Price shimmer
                ShimmerBox(width: 80, height: 14),
                const SizedBox(height: 6),

                // Quantity shimmer
                ShimmerBox(width: 100, height: 14),
                const Spacer(),

                // Bottom row shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total price shimmer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 60, height: 16),
                        const SizedBox(height: 4),
                        ShimmerBox(width: 60, height: 16),
                      ],
                    ),

                    // Quantity control shimmer
                    ShimmerBox(width: 100, height: 36),
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

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

String getFractionalPart(double value) {
  String formatted = value.toStringAsFixed(2); // "0.00"
  return formatted.split('.')[1]; // "00"
}

String convertNumberToRussianWords(double number) {
  final units = [
    '',
    'один',
    'два',
    'три',
    'четыре',
    'пять',
    'шесть',
    'семь',
    'восемь',
    'девять',
  ];
  final teens = [
    'десять',
    'одиннадцать',
    'двенадцать',
    'тринадцать',
    'четырнадцать',
    'пятнадцать',
    'шестнадцать',
    'семнадцать',
    'восемнадцать',
    'девятнадцать',
  ];
  final tens = [
    '',
    'десять',
    'двадцать',
    'тридцать',
    'сорок',
    'пятьдесят',
    'шестьдесят',
    'семьдесят',
    'восемьдесят',
    'девяносто',
  ];
  final hundreds = [
    '',
    'сто',
    'двести',
    'триста',
    'четыреста',
    'пятьсот',
    'шестьсот',
    'семьсот',
    'восемьсот',
    'девятьсот',
  ];

  int intPart = number.floor();
  if (intPart == 0) return 'ноль тенге';

  String result = '';
  int millions = intPart ~/ 1000000;
  int thousandsPart = (intPart % 1000000) ~/ 1000;
  int hundredsPart = intPart % 1000;
  int getForm(int number) {
    int n = number % 100;
    if (n >= 11 && n <= 14) return 2;
    int lastDigit = n % 10;
    if (lastDigit == 1) return 0;
    if (lastDigit >= 2 && lastDigit <= 4) return 1;
    return 2;
  }

  void appendSegment(
    int number,
    bool isFemale,
    String singular,
    String few,
    String many,
  ) {
    if (number == 0) return;

    int h = number ~/ 100;
    int t = (number % 100) ~/ 10;
    int u = number % 10;

    if (h > 0) result += '${hundreds[h]} ';

    if (t > 1) {
      result += '${tens[t]} ';
      if (u > 0) {
        result +=
            '${isFemale && u <= 2 ? (u == 1 ? 'одна' : 'две') : units[u]} ';
      }
    } else if (t == 1) {
      result += '${teens[u]} ';
    } else {
      if (u > 0) {
        result +=
            '${isFemale && u <= 2 ? (u == 1 ? 'одна' : 'две') : units[u]} ';
      }
    }

    if (number > 0) {
      int form = getForm(number);
      result +=
          '${form == 0
              ? singular
              : form == 1
              ? few
              : many} ';
    }
  }

  if (millions > 0) {
    appendSegment(millions, false, 'миллион', 'миллиона', 'миллионов');
  }

  if (thousandsPart > 0) {
    appendSegment(thousandsPart, true, 'тысяча', 'тысячи', 'тысяч');
  }

  if (hundredsPart > 0) {
    appendSegment(hundredsPart, false, '', '', '');
  }

  result = result.trim();
  result = result[0].toUpperCase() + result.substring(1);

  return result;
}

Future<void> genExpenditureInvoice(Order order, String ownerName) async {
  final pdf = pw.Document();

  final font = await rootBundle.load("assets/fonts/times.ttf");
  final fontItalic = await rootBundle.load("assets/fonts/times-italic.ttf");
  final fontBold = await rootBundle.load("assets/fonts/times-bold.ttf");
  final formattedDate = DateFormat('dd.MM.yyyy').format(order.deliveryDate!);

  final ttf = pw.Font.ttf(font);
  final ttfItalic = pw.Font.ttf(fontItalic);
  final ttfBold = pw.Font.ttf(fontBold);

  final ndsSum = order.items
      .where((item) => item.ndsPrice != null)
      .fold<double>(0, (sum, item) => sum + item.ndsPrice!);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      build: (context) => [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 2)),
          ),
          child: pw.Text(
            'Расходная накладная №${order.id} от $formattedDate',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              font: ttfBold,
            ),
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  'Поставщик: ',
                  style: pw.TextStyle(fontSize: 12, font: ttf),
                ),
                pw.Text(
                  order.supplierName,
                  style: pw.TextStyle(fontSize: 12, font: ttfBold),
                ),
              ],
            ),

            pw.SizedBox(height: 4),

            pw.Row(
              children: [
                pw.Text(
                  'Покупатель: ',
                  style: pw.TextStyle(fontSize: 12, font: ttf),
                ),
                pw.Text(
                  'ИП "${order.organizationName}"',
                  style: pw.TextStyle(fontSize: 12, font: ttfBold),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 8),

        pw.Table(
          border: pw.TableBorder.all(width: 0.7),
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    '№',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Товар',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Количество',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Ед. измерения',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Цена',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Сумма',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),

            ...order.items.asMap().entries.map((entry) {
              final index = entry.key + 1; // индекс с 1
              final item = entry.value;

              return pw.TableRow(
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(1),
                    child: pw.Text(
                      '$index',
                      style: pw.TextStyle(font: ttf, fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.productName,
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                      style: pw.TextStyle(font: ttf, fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),

                  // Подлежит отпуску
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.quantity.toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.unit == 1 ? 'шт' : 'кг',
                      style: pw.TextStyle(font: ttf, fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      (item.finalPrice! / item.quantity).toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.finalPrice!.toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 9),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Итого: ${order.finalPrice!.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              if (ndsSum > 0)
                pw.Text(
                  'В том числе НДС: ${ndsSum.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),

        pw.SizedBox(height: 8),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text(
                'Всего наименований ${order.items.length}, на сумму ${order.finalPrice!.toStringAsFixed(2)} KZT',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),

              pw.Text(
                '${convertNumberToRussianWords(order.finalPrice!)} тенге ${getFractionalPart(order.finalPrice!)} тиын',
                style: pw.TextStyle(font: ttfBold, fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text(
                'Отпустил',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 4),
              pw.Text(
                order.deliveryName!,
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.SizedBox(width: 8),

              pw.Text(
                'Получил',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 4),

              pw.Text(
                ownerName,
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  final outputDir = await getTemporaryDirectory();
  final file = File('${outputDir.path}/order${order.id}.pdf');
  await file.writeAsBytes(await pdf.save());

  await OpenFile.open(file.path);
}

Future<void> generateOrderPdf(Order order) async {
  final pdf = pw.Document();

  final font = await rootBundle.load("assets/fonts/times.ttf");
  final fontItalic = await rootBundle.load("assets/fonts/times-italic.ttf");
  final formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.now());

  final ttf = pw.Font.ttf(font);
  final ttfItalic = pw.Font.ttf(fontItalic);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      build: (context) => [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 180,
                child: pw.Text(
                  textAlign: pw.TextAlign.center,
                  'Приложение 26 \nк приказу Министра финансов Республики Казахстан \nот 20 декабря 2012 года № 562',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    font: ttfItalic,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                width: 180,
                child: pw.Text(
                  textAlign: pw.TextAlign.right,
                  'Форма 3-2',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Text(
              'Организация (индивидуальный предприниматель): ',
              style: pw.TextStyle(fontSize: 8, font: ttf),
            ),
            pw.Container(
              width: 150,
              decoration: pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 1),
              child: pw.Text(
                '${order.supplierName}',
                style: pw.TextStyle(fontSize: 8, font: ttf),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Spacer(),
            // pw.SizedBox(width: 20,),
            pw.Text('ИИН/БИН', style: pw.TextStyle(fontSize: 8, font: ttf)),
            pw.SizedBox(width: 5),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      child: pw.Text(
                        order.supplierBin,
                        style: pw.TextStyle(font: ttf, fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                textAlign: pw.TextAlign.center,
                'НАКЛАДНАЯ НА ОТПУСК ЗАПАСОВ НА СТОРОНУ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 150,
                child: pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(0),
                          child: pw.Text(
                            'Номер\nдокумента',
                            style: pw.TextStyle(
                              font: ttf,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(0),
                          child: pw.Text(
                            'Дата\nсоставления',
                            style: pw.TextStyle(
                              font: ttf,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(0),
                          child: pw.Text(
                            order.id.toString(),
                            style: pw.TextStyle(font: ttf, fontSize: 8),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(0),
                          child: pw.Text(
                            formattedDate,
                            style: pw.TextStyle(font: ttf, fontSize: 8),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),

        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Организация (индивидуальный предприниматель) - отправитель',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Организация (индивидуальный предприниматель) - получатель',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Ответственный за поставку (Ф.И.О.)',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Транспортная организация',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Товарно-транспортная накладная (номер, дата)',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    order.supplierName,
                    style: pw.TextStyle(font: ttf, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'ИП "${order.organizationName!}"',
                    style: pw.TextStyle(font: ttf, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '${order.finalPrice!.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: ttf, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '', // данные не заданы
                    style: pw.TextStyle(font: ttf, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '', // данные не заданы
                    style: pw.TextStyle(font: ttf, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),

        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          children: [
            pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    '№',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Наименование, характеристика',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Номенклатурный номер',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Единица измерения',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Подлежит отпуску',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(1),
                  child: pw.Text(
                    'Отпущено',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Цена за единицу, \nв KZT',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Сумма с НДС, \nв KZT',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'Сумма НДС, \nв KZT',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),

            pw.TableRow(
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '1',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '2',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '3',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '4',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '5',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    softWrap: false,
                    '6',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '7',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '8',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    '9',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),

            ...order.items.asMap().entries.map((entry) {
              final index = entry.key + 1; // индекс с 1
              final item = entry.value;

              return pw.TableRow(
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(1),
                    child: pw.Text(
                      '$index',
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.productName,
                      maxLines: 2,
                      overflow: pw.TextOverflow.clip,
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.nomenclatureNumber ?? item.barcode,
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.unit == 1 ? 'шт' : 'кг',
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  // Подлежит отпуску
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.quantity.toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  // Отпущено
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.quantity.toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      (item.finalPrice! / item.quantity).toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.finalPrice!.toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Text(
                      item.ndsPrice!.toStringAsFixed(2),
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              );
            }),
            pw.TableRow(
              children: [
                // Пустые ячейки без границ (1-3)
                for (int i = 0; i < 3; i++)
                  pw.Container(
                    // height: 20,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border(
                        top: pw.BorderSide(width: 0),
                        bottom: pw.BorderSide(width: 0),
                        left: pw.BorderSide(width: 0),
                        right: pw.BorderSide(width: 0),
                      ),
                    ),
                  ),

                // Единица измерения
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'ИТОГО',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Подлежит отпуску
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    order.items
                        .fold<double>(0, (sum, e) => sum + e.quantity)
                        .toStringAsFixed(2),
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Отпущено
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    order.items
                        .fold<double>(0, (sum, e) => sum + e.quantity)
                        .toStringAsFixed(2),
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Цена
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    'x',
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                // Сумма с НДС
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    order.finalPrice!.toStringAsFixed(2),
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                // Сумма НДС
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Text(
                    order.items
                        .fold<double>(0, (sum, e) => sum + e.ndsPrice!)
                        .toStringAsFixed(2),
                    style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 16),
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text(
                'Всего отпущено количество запасов (прописью) ',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${convertNumberToRussianWords(order.items.fold<double>(0, (sum, e) => sum + e.quantity))} ',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.Text(
                'на сумму (прописью) в KZT, ',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${convertNumberToRussianWords(order.finalPrice!)} тенге ${getFractionalPart(order.finalPrice!)} тиын',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  final outputDir = await getTemporaryDirectory();
  final file = File('${outputDir.path}/order${order.id}.pdf');
  await file.writeAsBytes(await pdf.save());

  await OpenFile.open(file.path);
}
