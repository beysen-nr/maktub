import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/data/models/order.dart';
import 'package:maktub/data/models/order_item.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/domain/repositories/order_repo.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_bloc.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_event.dart';
import 'package:maktub/presentation/user/screens/cart/make_order_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class OrderDetailsDeliveryScreen extends StatefulWidget {
  final Order order;
  final DateTime day;
  const OrderDetailsDeliveryScreen({super.key, required this.order, required this.day});
  

  @override
  State<OrderDetailsDeliveryScreen> createState() => _OrderDetailsDeliveryScreenState();
}

class _OrderDetailsDeliveryScreenState extends State<OrderDetailsDeliveryScreen> {
  @override
  Widget build(BuildContext context) {

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
                  ' №${widget.order.id}',
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
                  widget.order.supplierName,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                buildStatusContainer(context, widget.order.status ?? 0),
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
              ).loadOrderItems(widget.order.id),
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
                  widget.order.items = items;
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

            if (widget.order.status == 2) ...[
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
                      '${widget.order.finalPrice?.toStringAsFixed(2) ?? ''}₸',
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
                    widget.order.otp.toString().padLeft(4, '0'),
                    widget.day
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
                  AppLocalizations.of(context)!.confirm
                  ,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
       
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

void showOtpBottomSheet(BuildContext context, String otp, DateTime day) {
  final TextEditingController _otpController = TextEditingController();
   DeliveryOrdersBloc bloc = context.read<DeliveryOrdersBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      bool isOtpButtonEnabled = false;
      bool isOtpIncorrect = false;

      return StatefulBuilder(
        builder: (context, setModalState) {
          _otpController.addListener(() {
            final cleaned = _otpController.text.replaceAll(RegExp(r'\s+'), '');
            if (cleaned != _otpController.text) {
              _otpController.text = cleaned;
              _otpController.selection = TextSelection.fromPosition(
                TextPosition(offset: _otpController.text.length),
              );
            }

            setModalState(() {
              isOtpButtonEnabled = cleaned.length == 4 && cleaned == otp;
              isOtpIncorrect = cleaned.length == 4 && cleaned != otp;
            });
          });

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
                        AppLocalizations.of(context)!.enterTheConfirmationCode,
                        style: GoogleFonts.montserrat(
                          fontSize: 17.5,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'код',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0,
                          ),
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isOtpIncorrect
                                  ? Gradients.error
                                  : const Color(0xFFe5e5e5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isOtpIncorrect
                                  ? Gradients.error
                                  : Gradients.primary,
                            ),
                          ),
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isOtpButtonEnabled
                            ? () async {
                                FocusScope.of(context).unfocus();
                                if (_otpController.text == otp) {
                                  OrderRepository(
                                    client: SupabaseService.client,
                                  ).orderDelivered(orderId: widget.order.id);
                                  

                                  context.pop();
                                  
                                  context.pop();
                                  bloc.add(FetchDeliveryOrders(day));
                                } else {
                                  setModalState(() {
                                    isOtpIncorrect = false;
                                  });
                                }
                              }
                            : null,
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor: WidgetStateProperty.all(
                            isOtpButtonEnabled
                                ? Gradients.primary
                                : const Color(0xFFd4f2d6),
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
                          AppLocalizations.of(context)!.apply,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: isOtpButtonEnabled
                                ? Colors.white
                                : const Color(0xFFa9e4ac),
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

