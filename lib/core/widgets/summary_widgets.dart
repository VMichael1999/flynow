import 'package:flutter/material.dart';
import 'css_text.dart';
import 'text_helpers.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'basic_widgets.dart';
import 'booking_widgets.dart';

/// Resumen del vuelo en «Revisa y paga».
class FlightSummaryCard extends StatelessWidget {
  const FlightSummaryCard({
    super.key,
    required this.route,
    required this.subtitle,
    required this.yourFlight,
    required this.fromCode,
    required this.fromTime,
    required this.toCode,
    required this.toTime,
    required this.duration,
    required this.airlineLine,
    required this.seat,
    required this.initials,
    required this.passengerName,
    required this.ticketsTo,
  });

  final String route;
  final String subtitle;
  final String yourFlight;
  final String fromCode;
  final String fromTime;
  final String toCode;
  final String toTime;
  final String duration;
  final String airlineLine;
  final String seat;
  final String initials;
  final String passengerName;
  final String ticketsTo;

  @override
  Widget build(BuildContext context) {
    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Txt(route, style: AppText.s(22, w: FontWeight.w800)),
          Txt(
            subtitle,
            style: AppText.s(12.5, w: FontWeight.w400, color: AppColors.ink2),
          ),
          const SizedBox(height: 14),
          const Hairline(),
          const SizedBox(height: 14),
          Txt(
            yourFlight,
            style: AppText.s(
              12.5,
              w: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          RouteLine(
            fromCode: fromCode,
            fromTime: fromTime,
            toCode: toCode,
            toTime: toTime,
            duration: duration,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Txt(
                airlineLine,
                style: AppText.s(
                  12.5,
                  w: FontWeight.w400,
                  color: AppColors.ink3,
                ),
              ),
              Row(
                children: [
                  const AppIcon('i-grid', size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Txt(
                    seat,
                    style: AppText.s(
                      12.5,
                      w: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Hairline(),
          const SizedBox(height: 14),
          Row(
            children: [
              Avatar(initials: initials, size: 38, fontSize: 11.5),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      passengerName,
                      style: AppText.s(14.5, w: FontWeight.w700),
                    ),
                    StrutText(
                      ticketsTo,
                      style: AppText.s(
                        12.5,
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
        ],
      ),
    );
  }
}

/// Método de pago y fila «Agregar código promocional».
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.brandIcon,
    required this.title,
    required this.expiry,
    required this.changeLabel,
    required this.promoLabel,
  });
  final Widget brandIcon;
  final String title;
  final String expiry;
  final String changeLabel;
  final String promoLabel;

  @override
  Widget build(BuildContext context) {
    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(color: AppColors.line, spreadRadius: 1),
                  ],
                ),
                child: brandIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(title, style: AppText.s(15, w: FontWeight.w700)),
                    StrutText(
                      expiry,
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
              Txt(
                changeLabel,
                style: AppText.s(
                  14,
                  w: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Hairline(),
          const SizedBox(height: 14),
          Row(
            children: [
              const IconBox('i-promo', size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Txt(
                  promoLabel,
                  style: AppText.s(15, w: FontWeight.w600),
                ),
              ),
              const AppIcon('i-plus', size: 20, color: AppColors.ink2),
            ],
          ),
        ],
      ),
    );
  }
}

/// Desglose del precio con la fila de total.
class PriceBreakdownCard extends StatelessWidget {
  const PriceBreakdownCard({
    super.key,
    required this.title,
    required this.lines,
    required this.totalLabel,
    required this.total,
  });
  final String title;
  final List<(String, String)> lines;
  final String totalLabel;
  final String total;

  @override
  Widget build(BuildContext context) {
    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Txt(title, style: AppText.s(16, w: FontWeight.w700)),
          ),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Txt(
                    l.$1,
                    style: AppText.s(
                      13.5,
                      w: FontWeight.w400,
                      color: AppColors.ink2,
                    ),
                  ),
                  Txt(l.$2, style: AppText.s(13.5, w: FontWeight.w700)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Hairline(),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Txt(totalLabel, style: AppText.s(15, w: FontWeight.w700)),
                Txt(total, style: AppText.s(24, w: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
