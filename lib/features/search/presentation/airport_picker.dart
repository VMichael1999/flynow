import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../data/airport_catalog.dart';
import '../domain/search_domain.dart';

/// Hoja inferior para elegir un aeropuerto. Devuelve el elegido o `null`.
Future<Airport?> showAirportPicker(
  BuildContext context, {
  required String title,
  required Airport selected,
}) {
  return showModalBottomSheet<Airport>(
    context: context,
    backgroundColor: AppColors.transparent,
    barrierColor: AppColors.ink.withValues(alpha: .35),
    isScrollControlled: true,
    // Por encima de la barra de navegación y del botón de escaneo.
    useRootNavigator: true,
    builder: (_) => _AirportSheet(title: title, selected: selected),
  );
}

class _AirportSheet extends StatelessWidget {
  const _AirportSheet({required this.title, required this.selected});
  final String title;
  final Airport selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.grabHandle,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Txt(title, style: AppText.title),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                itemCount: kAirports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder:
                    (context, i) => _AirportTile(
                      airport: kAirports[i],
                      selected: kAirports[i] == selected,
                      onTap: () => Navigator.of(context).pop(kAirports[i]),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AirportTile extends StatelessWidget {
  const _AirportTile({
    required this.airport,
    required this.selected,
    required this.onTap,
  });
  final Airport airport;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${airport.city}, ${airport.country}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.fareSelectedBg : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.primary : AppColors.line,
                spreadRadius: selected ? 1.5 : 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Txt(
                  airport.code,
                  style: AppText.s(
                    15,
                    w: FontWeight.w800,
                    color: AppColors.primary,
                    ls: .5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Txt(
                      airport.city,
                      style: AppText.s(15, w: FontWeight.w700, h: 1.26),
                    ),
                    Txt(
                      '${airport.name} · ${airport.country}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.s(
                        12.5,
                        w: FontWeight.w400,
                        color: AppColors.ink3,
                        h: 1.26,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const AppIcon('i-check', size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
