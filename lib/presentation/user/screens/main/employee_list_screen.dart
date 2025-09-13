import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/core/l10n/app_localizations.dart';
import 'package:maktub/core/router/route_names.dart';
import 'package:maktub/data/models/employee.dart';
import 'package:maktub/presentation/user/blocs/app_state_cubit.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_bloc.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_event.dart';
import 'package:maktub/presentation/user/blocs/employee/employee_state.dart';
import 'package:maktub/presentation/user/widgets/common/top_snackbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:go_router/go_router.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final workplaceId = context.read<AppStateCubit>().state!.workplaceId;
    context.read<EmployeeBloc>().add(LoadEmployeees(workplaceId));
  }

  void _onEmployeeTapped(Employee employee) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8),
                    child: Text(
                      AppLocalizations.of(context)!.employees,
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
                child: BlocBuilder<EmployeeBloc, EmployeeState>(
                  builder: (context, state) {
                    if (state is EmployeeLoading) {
                      return Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: Gradients.primary,
                          size: 30,
                        ),
                      );
                    }

                    if (state is EmployeeLoaded) {
                      if (state.employees.isEmpty) {
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
                                AppLocalizations.of(context)!.onlyYou,
                                style: mainText.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.employees.length,
                        itemBuilder: (context, index) {
                          final employee = state.employees[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 200 + index * 100,
                            ), // <<< можно чуть задержку
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    (1 - value) * 20,
                                  ), // Плавный подъём
                                  child: child,
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: () => _onEmployeeTapped(employee),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Gradients.borderGray,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          employee.fullName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (employee.roleId == 2)
                                          Text(
                                            'админстратор',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Gradients.textGray,
                                            ),
                                          ),
                                        if (employee.roleId == 3)
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.receiver,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Gradients.textGray,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          employee.phone!,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Gradients.textGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 15,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.read<EmployeeBloc>().add(
                                          DeleteEmployee(employee: employee),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Gradients.textGray,
                                        ),
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

                    if (state is EmployeeError) {
                      return Center(
                        child: Text(AppLocalizations.of(context)!.error),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 20),

              /// КНОПКА "Добавить адрес"
              ElevatedButton(
                onPressed: () async {
                  final result = await context.push(
                    RouteNames.employee,
                  ); // Переход на карту

                  if (result == true) {
                    final workplaceId = context
                        .read<AppStateCubit>()
                        .state!
                        .workplaceId;
                    context.read<EmployeeBloc>().add(
                      LoadEmployeees(workplaceId),
                    );
                  }
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
                  AppLocalizations.of(context)!.addEmployee,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20), // Отступ внизу
            ],
          ),
        ),
      ),
    );
  }
}
