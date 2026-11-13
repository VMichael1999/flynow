import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'booking_common.dart';
import 'booking_flow_bloc.dart';

/// Paso 1: elige tu tarifa.
class FarePage extends StatelessWidget {
  const FarePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<BookingFlowBloc>();
    return BlocBuilder<BookingFlowBloc, BookingFlowState>(
      builder: (context, s) {
        final fares = bloc.faresFor(s.flight);
        final f = s.flight;
        return BookingScaffold(
          title: l.fareTitle,
          step: 0,
          stepNames: stepNames(l),
          onBack: () => context.go('/select'),
          summary: BookingSummary(
            step: BookingStep.fare,
            buttonLabel: l.continueLabel,
            onPressed: () => context.go('/book/passengers'),
          ),
          body: BookingBody(
            children: [
              BookingHeading(
                crumb:
                    '${f.from.code} → ${f.to.code} · ${Fmt.shortDate(f.departure)}',
                title: l.chooseFare,
                subtitle: l.fareSubtitle,
              ),
              const SizedBox(height: 22),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < fares.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: FareOptionCard(
                          option: FareOption(
                            id: fares[i].id,
                            name: fares[i].name,
                            price: Money.whole(fares[i].price),
                            tag: fares[i].tag,
                            popular: fares[i].popular,
                          ),
                          selected: fares[i].id == s.fare.id,
                          popularLabel: l.mostPopular,
                          onTap: () => bloc.add(FareSelected(fares[i].id)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              IncludesList(
                title: l.fareIncludes(s.fare.name),
                subtitle: s.fare.summary,
                rows: [
                  for (final b in s.fare.benefits)
                    IncludeRow(b.label, b.value, included: b.included),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
                child: Txt(
                  l.fareFootnote,
                  textAlign: TextAlign.center,
                  style: AppText.s(
                    11.5,
                    w: FontWeight.w400,
                    color: AppColors.ink3,
                    h: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
