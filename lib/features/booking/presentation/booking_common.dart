import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import '../domain/booking_domain.dart';
import 'booking_flow_bloc.dart';

/// Nombres de los 4 pasos, ya traducidos.
List<String> stepNames(AppL10n l) => [
  l.stepFare,
  l.stepPassengers,
  l.stepSeats,
  l.stepPayment,
];

/// Texto de la leyenda de la barra de resumen; la elección sale del estado.
String captionText(AppL10n l, BookingFlowState s, BookingStep step) => switch (s
    .captionFor(step)) {
  BookingCaption.fareWithTaxes => l.fareCaption(Money.whole(kTaxes)),
  BookingCaption.passengerFare => l.paxCaption(s.fare.name),
  BookingCaption.chooseSeat => l.seatCaptionNone(s.passenger.firstName),
  BookingCaption.seatFree => l.seatCaptionFree,
  BookingCaption.seatExtra => l.seatCaptionExtra(Money.whole(kExtraSeatFee)),
  BookingCaption.acceptTerms => l.payCaptionAccept,
  BookingCaption.payIncluded => l.payCaptionOk,
};

/// Contenido con scroll de las pantallas de la compra (arranca bajo los pasos).
class BookingBody extends StatelessWidget {
  const BookingBody({super.key, required this.children, this.top = 196});
  final List<Widget> children;
  final double top;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22, top, 22, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// «DPS → CGK · 4 sep», título 27/800 y subtítulo.
class BookingHeading extends StatelessWidget {
  const BookingHeading({
    super.key,
    required this.crumb,
    required this.title,
    required this.subtitle,
  });
  final String crumb;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(crumb, style: AppText.s(12, color: AppColors.ink3)),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Txt(
            title,
            style: AppText.s(27, w: FontWeight.w800, ls: -.405),
          ),
        ),
        Txt(
          subtitle,
          style: AppText.s(13.5, w: FontWeight.w400, color: AppColors.ink2),
        ),
      ],
    );
  }
}

/// Barra de resumen enlazada al estado de la reserva.
class BookingSummary extends StatelessWidget {
  const BookingSummary({
    super.key,
    required this.step,
    required this.buttonLabel,
    this.onPressed,
  });
  final BookingStep step;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<BookingFlowBloc>().state;
    return PriceSummaryBar(
      total: Money.format(s.total),
      caption: captionText(l, s, step),
      buttonLabel: buttonLabel,
      onPressed: onPressed,
    );
  }
}
