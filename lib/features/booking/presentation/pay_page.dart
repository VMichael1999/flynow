import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/booking_domain.dart';
import 'booking_common.dart';
import 'booking_flow_bloc.dart';

/// Paso 4: revisa y paga.
class PayPage extends StatelessWidget {
  const PayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<BookingFlowBloc>();
    return BlocConsumer<BookingFlowBloc, BookingFlowState>(
      listenWhen:
          (a, b) =>
              b.payment == PaymentStatus.paid &&
              a.payment != PaymentStatus.paid,
      listener: (context, _) => context.go('/book/done'),
      builder: (context, s) {
        final f = s.flight;
        final total = Money.format(s.total);
        final fareName = l.economyFare(s.fare.name);
        final lines = <(String, String)>[
          (l.fareLine(s.fare.name), Money.format(s.fare.price)),
          (l.taxesLine, Money.format(kTaxes)),
          (l.seatsLine, s.seatFee > 0 ? Money.format(s.seatFee) : l.included),
          for (final e in s.extras) (e.name, Money.format(e.price)),
        ];
        return Stack(
          children: [
            BookingScaffold(
              title: l.reviewPay,
              step: 3,
              stepNames: stepNames(l),
              onBack: () => context.go('/book/seats'),
              summary: BookingSummary(
                step: BookingStep.pay,
                buttonLabel: l.payButton(total),
                onPressed:
                    s.canPay ? () => bloc.add(const PaymentSubmitted()) : null,
              ),
              body: BookingBody(
                top: 186,
                children: [
                  FlightSummaryCard(
                    route: '${f.from.code} → ${f.to.code}',
                    subtitle: l.oneWayDateFare(
                      Fmt.shortDate(f.departure),
                      fareName,
                    ),
                    yourFlight: l.yourFlightDate(
                      Fmt.dayMonthLower(f.departure),
                    ),
                    fromCode: f.from.code,
                    fromTime: Fmt.time(f.departure),
                    toCode: f.to.code,
                    toTime: Fmt.time(f.arrival),
                    duration: Fmt.duration(f.duration),
                    airlineLine: '${f.airline} · ${f.flightNo}',
                    seat: s.seat?.id ?? '—',
                    initials: s.passenger.initials,
                    passengerName: s.passenger.fullName,
                    ticketsTo: l.ticketsTo(s.passenger.email),
                  ),
                  const SizedBox(height: 14),
                  PaymentMethodCard(
                    brandIcon: const AppIcon(
                      'i-card',
                      size: 22,
                      color: AppColors.primary,
                    ),
                    title: l.visaLine,
                    expiry: l.visaExpiry,
                    changeLabel: l.changeLabel,
                    promoLabel: l.addPromo,
                  ),
                  const SizedBox(height: 14),
                  PriceBreakdownCard(
                    title: l.priceDetail,
                    lines: lines,
                    totalLabel: l.totalLabel,
                    total: total,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ConsentCheckbox(
                            checked: s.termsAccepted,
                            label: l.agreeText(s.fare.name),
                            onChanged: (_) => bloc.add(const TermsToggled()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Txt(
                            l.agreeText(s.fare.name),
                            style: AppText.s(
                              13,
                              w: FontWeight.w400,
                              color: AppColors.ink2,
                              h: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      children: [
                        const AppIcon(
                          'i-lock',
                          size: 14,
                          color: AppColors.ink3,
                        ),
                        const SizedBox(width: 8),
                        Txt(
                          l.securePayment,
                          style: AppText.s(
                            12,
                            w: FontWeight.w400,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BlurOverlay(
              visible: s.payment == PaymentStatus.paying,
              title: l.confirmingBooking,
              detail: l.payingDetail(total),
              loader: const PlaneOrbitLoader(),
            ),
          ],
        );
      },
    );
  }
}
