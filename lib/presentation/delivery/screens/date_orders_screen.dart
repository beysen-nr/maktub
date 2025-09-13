import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/data/models/order.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_bloc.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_event.dart';
import 'package:maktub/presentation/delivery/blocs/orders/orders_state.dart';
import 'package:maktub/presentation/delivery/repo/delivery_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryOrdersScreen extends StatelessWidget {
  final DateTime day;

  const DeliveryOrdersScreen({super.key, required this.day});


  @override
  Widget build(BuildContext context) {
   List<Order> ordersCache = [];

    return BlocProvider(
      create: (_) =>
          DeliveryOrdersBloc(repository: DeliveryRepository())
            ..add(FetchDeliveryOrders(day)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Gradients.primary),
          elevation: 0,
          title: Text(
            formatKazakhDate(context, day),
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Gradients.primary,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  80,
                ), // отступ снизу под кнопку
                child: BlocBuilder<DeliveryOrdersBloc, DeliveryOrdersState>(
                  builder: (context, state) {
                    if (state is DeliveryOrdersLoading) {
                      return Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: Gradients.primary,
                          size: 40,
                        ),
                      );
                    } else if (state is DeliveryOrdersError) {
                      return Center(child: Text(state.message));
                    } else if (state is DeliveryOrdersEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/ohh.png',
                              width: 50,
                              height: 50,
                            ),
                            const SizedBox(height: 8),
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
                    } else if (state is DeliveryOrdersLoaded) {
                      final orders = state.orders;
 ordersCache = orders;
                      return ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final order = orders[index];
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
                            child: _buildOrderCard(order, context),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: ElevatedButton(
                  onPressed: () {
            final url = generateYandexRouteUrl(ordersCache);
  launchUrl(Uri.parse(url),   mode: LaunchMode.externalApplication,);
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
                    'построить маршрут',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String generateYandexRouteUrl(List<Order> orders) {
    if (orders.isEmpty) return '';

    final coords = orders
        .map((o) => o.addressPoint)
        .cast<List<double>>()
        .toList();


    final rtext = coords.map((p) => '${p[0]}%2C${p[1]}').join('~'); // lat,lng

    return 'https://yandex.kz/maps/ru/163/astana/?mode=routes&rtext=$rtext&rtt=auto&ruri=~~~~~~&z=12';
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Container(
      width: double.infinity,
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
                order.nameOfPoint ?? '',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              _buildStatusContainer(context, order.status!),
            ],
          ),
          const SizedBox(height: 8),
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Text(
        order.deliveryAddress!,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Gradients.textGray,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    ),
    const SizedBox(width: 8),
    ElevatedButton(
      onPressed: () {
        context.push(
          RouteNames.orderDeliveryDetails,
          extra: {
            'order': order,
            'bloc': context.read<DeliveryOrdersBloc>(),
            'day': day,
          },
        );
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
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
)
 ],
      ),
    );
  }

  Widget _buildStatusContainer(BuildContext context, int status) {
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String formatKazakhDate(BuildContext context, DateTime date) {
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
  ]; final localDate = date.toLocal();
    return '${localDate.day} ${months[localDate.month - 1]}, ${weekdays[localDate.weekday - 1]}';
  }

}
