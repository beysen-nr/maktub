import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/order.dart';
import 'package:maktub/data/services/supabase/supabase_service.dart';
import 'package:maktub/domain/repositories/order_repo.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/order/order_event.dart';
import 'package:maktub/presentation/user/blocs/order/order_state.dart';
import 'package:maktub/presentation/user/blocs/order/order_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderRepository repository = OrderRepository(
    client: SupabaseService.client,
  );

  @override
  Widget build(BuildContext context) {
    final int organizationId = context.read<AppStateCubit>().state!.workplaceId;
    final String organizationName = context.read<AppStateCubit>().state!.organizationName;
    OrderBloc orderBloc = OrderBloc(repository);
    return BlocProvider(
      create: (_) => orderBloc..add(LoadOrders(orgainzationId: organizationId, organizationName: organizationName)),
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCancelled) {
            context.read<OrderBloc>().add(
              LoadOrders(orgainzationId: organizationId, organizationName: organizationName),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(3.1416),
                              child: Image.asset(
                                'assets/icons-system/arrow.png',
                                width: 25,
                                height: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8),
                        child: Text(
                         AppLocalizations.of(context)!.orders,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        if (state is OrderLoading) {
                          return Center(
                            child: LoadingAnimationWidget.waveDots(
                              color: Gradients.primary,
                              size: 30,
                            ),
                          );
                        } else if (state is OrderFailure) {
                          return Center(child: Text(AppLocalizations.of(context)!.error));
                        } else if (state is OrderLoaded) {
                          final orders = state.orders;

                          if (orders.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/ohh.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!.noOrders,
                                    style: mainText.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);

                          // Разделение на сегодняшние и остальные
                          final todayOrders = <Order>[];
                          final otherOrders = <Order>[];

                          for (final order in orders) {
                            final orderDate = DateTime(
                              order.deliveryDate!.year,
                              order.deliveryDate!.month,
                              order.deliveryDate!.day,
                            );

                            if (orderDate == today) {
                              todayOrders.add(order);
                            } else {
                              otherOrders.add(order);
                            }
                          }

                          // Сортировка остальных по убыванию
                          otherOrders.sort(
                            (a, b) =>
                                b.deliveryDate!.compareTo(a.deliveryDate!),
                          );

                          // Группировка отдельно
                          final groupedToday = {today: todayOrders};

                          final groupedOther = groupBy(
                            otherOrders,
                            (order) => DateTime(
                              order.deliveryDate!.year,
                              order.deliveryDate!.month,
                              order.deliveryDate!.day,
                            ),
                          )..remove(today); // на всякий случай

                          final sortedGroupedOther =
                              groupedOther.entries.toList()..sort(
                                (a, b) => b.key.compareTo(a.key),
                              ); // по убыванию

                          final List<MapEntry<DateTime, List<Order>>>
                          sortedEntries = [
                            ...groupedToday.entries,
                            ...sortedGroupedOther,
                          ];
final List<Widget> animatedItems = [];
int animationDelay = 0;

for (var entry in sortedEntries) {
  animatedItems.add(
    Padding(
      padding: const EdgeInsets.only(top: 8, left: 16),
      child: Text(
        formatKazakhDate(entry.key),
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Gradients.primary,
        ),
      ),
    ),
  );

  for (var order in entry.value) {
    animationDelay += 100;

    animatedItems.add(
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: animationDelay),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          );
        },
        child: buildOrderCard(order, context),
      ),
    );
  }
}

                          return ListView(children: animatedItems);
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOrderCard(Order order, BuildContext context) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Gradients.borderGray),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              order.supplierName,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            buildStatusContainer(context, order.status!),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${order.finalPrice}₸',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Gradients.textGray,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.push(
                  RouteNames.orderDetails,
                  extra: {
                    'order': order,
                    'bloc': context.read<OrderBloc>(),
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                splashFactory: NoSplash.splashFactory,
                overlayColor: Colors.transparent,
                backgroundColor: Gradients.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.aboutOrder,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget buildStatusContainer(BuildContext context,int status) {
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
        text =  AppLocalizations.of(context)!.delivered;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String formatKazakhDate(DateTime date) {
    const months = [
      'қаңтар',
      'ақпан',
      'наурыз',
      'сәуір',
      'мамыр',
      'маусым',
      'шілде',
      'тамыз',
      'қыркүйек',
      'қазан',
      'қараша',
      'желтоқсан',
    ];
    const weekdays = [
      'дүйсенбі',
      'сейсенбі',
      'сәрсенбі',
      'бейсенбі',
      'жұма',
      'сенбі',
      'жексенбі',
    ];

    final localDate = date.toLocal();
    return '${localDate.day} ${months[localDate.month - 1]}, ${weekdays[localDate.weekday - 1]}';
  }
}
