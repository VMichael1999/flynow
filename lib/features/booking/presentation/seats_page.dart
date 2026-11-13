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

/// Paso 3: elige tu asiento y extras.
class SeatsPage extends StatelessWidget {
  const SeatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<BookingFlowBloc>();
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, s) {
        final f = s.flight;
        return BookingScaffold(
          title: l.seatsTitle,
          step: 2,
          stepNames: stepNames(l),
          onBack: () => context.go('/book/passengers'),
          trailing: AppBarTextAction(
            label: l.skip,
            onTap: () => context.go('/book/pay'),
          ),
          summary: BookingSummary(
            step: BookingStep.seats,
            buttonLabel: l.continueLabel,
            onPressed:
                s.canContinueFromSeats ? () => context.go('/book/pay') : null,
          ),
          body: BookingBody(
            children: [
              BookingHeading(
                crumb: l.yourFlightLine(
                  '${Fmt.shortDate(f.departure)}, ${Fmt.time(f.departure)}',
                  f.flightNo.replaceFirst('ID ', 'ID '),
                ),
                title: '${f.from.code}–${f.to.code}',
                subtitle: l.aircraftClass,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: PassengerChip(
                    initials: s.passenger.initials,
                    name: s.passenger.firstName,
                    seatLabel:
                        s.seat == null ? l.noSeat : l.seatWord(s.seat!.id),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: InfoNote(
                  text: l.seatNote(s.fare.name, Money.whole(kExtraSeatFee)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Txt(
                          l.rowsRange,
                          style: AppText.title.copyWith(letterSpacing: 0),
                        ),
                        Txt(
                          l.cabinFront,
                          style: AppText.s(
                            12,
                            w: FontWeight.w400,
                            color: AppColors.ink3,
                          ),
                        ),
                      ],
                    ),
                    const _Pager(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SeatLegend(
                  free: l.legendFree,
                  chosen: l.legendChosen,
                  taken: l.legendTaken,
                  extra: l.legendExtra,
                ),
              ),
              const SizedBox(height: 22),
              SeatMap(
                rows: [
                  for (var r = 1; r <= 16; r++)
                    [
                      for (final c in const ['A', 'B', 'C', 'D'])
                        _cell(l, bloc, s, '$r$c', c),
                    ],
                ],
                exitRows: const {8, 9},
                selectedInitials: s.passenger.initials,
                wcLabel: l.wc,
                exitLabel: l.exitLabel,
                onSeatTap: (id) => bloc.add(SeatToggled(id)),
                // El margen de 6 px colapsa con los 8 px de la última fila.
                footer: Center(child: _MoreButton(label: l.rowsMore)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 26, bottom: 14),
                child: Txt(l.extrasTitle, style: AppText.title),
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Txt(
                  l.extrasSub,
                  style: AppText.s(
                    12,
                    w: FontWeight.w400,
                    color: AppColors.ink2,
                  ),
                ),
              ),
              const SizedBox(height: 12 - 10),
              for (var i = 0; i < bloc.extraCatalog.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                ExtraOptionTile(
                  icon: bloc.extraCatalog[i].icon,
                  name: bloc.extraCatalog[i].name,
                  detail: bloc.extraCatalog[i].detail,
                  price: l.extraPrice(Money.whole(bloc.extraCatalog[i].price)),
                  selected: s.hasExtra(bloc.extraCatalog[i].id),
                  onTap: () => bloc.add(ExtraToggled(bloc.extraCatalog[i].id)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  SeatCell _cell(
    AppL10n l,
    BookingFlowBloc bloc,
    BookingFlowState s,
    String id,
    String col,
  ) {
    final seat = bloc.seatAt(id);
    final selected = s.seat?.id == id;
    final kind =
        selected
            ? SeatKind.selected
            : switch (seat.category) {
              SeatCategory.taken => SeatKind.taken,
              SeatCategory.extra => SeatKind.extra,
              SeatCategory.standard => SeatKind.free,
            };
    final label = switch (seat.category) {
      SeatCategory.taken => l.seatSemanticsTaken(id),
      SeatCategory.extra => l.seatSemanticsExtra(id),
      SeatCategory.standard => l.seatWord(id),
    };
    return SeatCell(id: id, column: col, kind: kind, semanticsLabel: label);
  }
}

class _Pager extends StatelessWidget {
  const _Pager();

  @override
  Widget build(BuildContext context) {
    Widget b(String t, bool on) => Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: on ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            on
                ? null
                : const [BoxShadow(color: AppColors.line, spreadRadius: 1)],
      ),
      child: Txt(
        t,
        style: AppText.s(
          13.333,
          w: FontWeight.w700,
          color: on ? AppColors.white : AppColors.ink,
          h: 1.26,
        ),
      ),
    );
    return Row(
      children: [b('1', true), const SizedBox(width: 8), b('2', false)],
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon('i-down', size: 14),
          const SizedBox(width: 4),
          Txt(label, style: AppText.s(13, w: FontWeight.w600, h: 1.26)),
        ],
      ),
    );
  }
}
