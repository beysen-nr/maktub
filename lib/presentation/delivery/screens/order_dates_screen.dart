import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/presentation/delivery/blocs/days/days_bloc.dart';
import 'package:maktub/presentation/delivery/blocs/days/days_event.dart';
import 'package:maktub/presentation/delivery/blocs/days/days_state.dart';
import 'package:maktub/presentation/delivery/repo/delivery_repo.dart';

class DeliveryDaysScreen extends StatelessWidget {
  const DeliveryDaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DeliveryRepository();

    return BlocProvider(
      create: (_) =>
          DeliveryDaysBloc(repository: repository)..add(FetchDeliveryDays()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Даты поставок',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Gradients.primary,
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<DeliveryDaysBloc, DeliveryDaysState>(
              builder: (context, state) {
                if (state is DeliveryDaysLoading) {
                  return Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: Gradients.primary,
                      size: 40,
                    ),
                  );
                } else if (state is DeliveryDaysError) {
                  return Center(child: Text(state.message));
                } else if (state is DeliveryDaysEmpty) {
                  return Center(
                    child: Text(
                      'Нет поставок',
                      style: mainText.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                } else if (state is DeliveryDaysLoaded) {
                  final days = state.days;
                 days.sort((a, b) => a.compareTo(b));// от новых к старым

return ListView.builder(
  itemCount: days.length,
  itemBuilder: (context, i) {
    final date = days[i];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 200 + i * 100),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          context.push(RouteNames.dayOrders, extra: date);
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Gradients.borderGray),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatKazakhDate(context, date),
                style: GoogleFonts.montserrat(
                  color: Gradients.mainTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Gradients.primary,
              ),
            ],
          ),
        ),
      ),
    );
  },
);

                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatKazakhDate(BuildContext context, DateTime date) {
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


    final d = date.toLocal();
    return '${d.day} ${months[d.month - 1]}, ${weekdays[d.weekday - 1]}';
  }
}
