import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'booking_common.dart';
import 'booking_flow_bloc.dart';

/// Paso 2: ¿Quién viaja?
class PassengersPage extends StatefulWidget {
  const PassengersPage({super.key});

  @override
  State<PassengersPage> createState() => _PassengersPageState();
}

class _PassengersPageState extends State<PassengersPage> {
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final p = context.read<BookingFlowBloc>().state.passenger;
    _email = TextEditingController(text: p.email)..addListener(_changed);
    _phone = TextEditingController(text: p.phone)..addListener(_changed);
  }

  void _changed() {
    final bloc = context.read<BookingFlowBloc>();
    bloc.add(
      PassengerUpdated(
        bloc.state.passenger.copyWith(email: _email.text, phone: _phone.text),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, s) {
        final f = s.flight;
        final p = s.passenger;
        return BookingScaffold(
          title: l.stepPassengers,
          step: 1,
          stepNames: stepNames(l),
          onBack: () => context.go('/book/fare'),
          summary: BookingSummary(
            step: BookingStep.passengers,
            buttonLabel: l.continueLabel,
            onPressed: () => context.go('/book/seats'),
          ),
          body: BookingBody(
            children: [
              BookingHeading(
                crumb:
                    '${f.from.code} → ${f.to.code} · ${Fmt.shortDate(f.departure)}',
                title: l.whoTravels,
                subtitle: l.passportHint,
              ),
              const SizedBox(height: 18),
              TravellerCard(
                initials: p.initials,
                caption: l.passengerOne,
                name: p.fullName,
                editLabel: l.edit,
                fields: [
                  (
                    l.birthDate,
                    Fmt.fullDate(p.birthDate).replaceFirst(RegExp(r'^0'), ''),
                  ),
                  (l.nationality, p.nationality),
                  (l.passport, p.passport),
                  (l.expires, Fmt.fullDate(p.passportExpiry)),
                ],
              ),
              const SizedBox(height: 14),
              SkyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const IconBox('i-mail'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Txt(
                                l.contactData,
                                style: AppText.s(15, w: FontWeight.w700),
                              ),
                              // <small> en línea: la línea la fija el bloque de 15 px.
                              StrutText(
                                l.contactSub,
                                style: AppText.s(
                                  12,
                                  w: FontWeight.w400,
                                  color: AppColors.ink3,
                                ),
                                strutSize: 15,
                                lineHeight: 1.3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GroupedInputCard(
                      fields: [(l.emailField, _email), (l.mobileField, _phone)],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  children: [
                    const AppIcon('i-lock', size: 14, color: AppColors.ink3),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Txt(
                        l.passportNote,
                        style: AppText.s(
                          12,
                          w: FontWeight.w400,
                          color: AppColors.ink3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
