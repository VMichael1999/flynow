import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'flight_arc_painter.dart';
import 'search_results_bloc.dart';
import 'ticket_mappers.dart';

class SelectFlightPage extends StatefulWidget {
  const SelectFlightPage({super.key});

  @override
  State<SelectFlightPage> createState() => _SelectFlightPageState();
}

class _SelectFlightPageState extends State<SelectFlightPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arc = AnimationController(
    vsync: this,
    duration: AppDurations.flightArc,
  );
  double _pull = 0;
  bool _refreshing = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _restartArc();
  }

  void _restartArc() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _arc.value = 1;
    } else {
      _arc.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _arc.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (_refreshing) return false;
    if (n is ScrollUpdateNotification || n is OverscrollNotification) {
      final d = math.max(0.0, -n.metrics.pixels);
      if (d != _pull) setState(() => _pull = d);
    } else if (n is ScrollEndNotification) {
      if (_pull > 80) {
        _refresh();
      } else if (_pull != 0) {
        setState(() => _pull = 0);
      }
    }
    return false;
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _pull = 0;
    });
    final bloc = context.read<SearchResultsBloc>();
    final before = bloc.state.refreshes;
    bloc.add(const SearchResultsRefreshed());
    await bloc.stream.firstWhere((s) => s.refreshes != before);
    if (!mounted) return;
    setState(() => _refreshing = false);
    _restartArc();
    getIt<ToastService>().show(context.l10n.faresUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocBuilder<SearchResultsBloc, SearchResultsState>(
      builder: (context, state) {
        final q = state.query;
        final first = state.flights.isEmpty ? null : state.flights.first;
        return ScreenFrame(
          child: Stack(
            children: [
              Positioned.fill(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Hero(
                          arc: _arc,
                          duration:
                              first == null ? '' : Fmt.duration(first.duration),
                          date: Fmt.fullDate(q?.date ?? kDepartureDate),
                          fromCity: q?.origin.city ?? '',
                          fromCode: q?.origin.code ?? '',
                          toCity: q?.destination.city ?? '',
                          toCode: q?.destination.code ?? '',
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 22, bottom: 14),
                          child: SectionHeader(
                            title: l.flightDate,
                            action: l.calendar,
                          ),
                        ),
                        DayChipRow(
                          days: [
                            for (var i = 0; i < 7; i++)
                              () {
                                final d = kDepartureDate.add(Duration(days: i));
                                return DayItem(
                                  Fmt.weekdayShort(d, capital: true),
                                  d.day,
                                );
                              }(),
                          ],
                          selected: state.dayIndex,
                          onChanged:
                              (i) => context.read<SearchResultsBloc>().add(
                                SearchResultsDaySelected(i),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 28, bottom: 14),
                          child: SectionHeader(
                            title: l.airlinesCount(state.flights.length),
                            trailing: ChipB(icon: 'i-grid', label: l.economy),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            children: [
                              for (
                                var i = 0;
                                i < state.flights.length;
                                i++
                              ) ...[
                                if (i > 0) const SizedBox(height: 14),
                                FlightTicketCard.result(
                                  context,
                                  data: ticketFromFlight(state.flights[i], l),
                                  price: Money.whole(
                                    state.flights[i].farePrice,
                                  ),
                                  onTap:
                                      () => context.go(
                                        '/book/fare',
                                        extra: state.flights[i],
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _PullIndicator(
                label: l.refreshing,
                pull: _pull,
                refreshing: _refreshing,
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SkyAppBar(
                  title: l.selectFlightTitle,
                  leading: BackButtonGlass(() => context.go('/home')),
                  trailing: GlassCircleButton(
                    icon: 'i-filter',
                    label: l.filters,
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

class _Hero extends StatelessWidget {
  const _Hero({
    required this.arc,
    required this.duration,
    required this.date,
    required this.fromCity,
    required this.fromCode,
    required this.toCity,
    required this.toCode,
  });

  final Animation<double> arc;
  final String duration;
  final String date;
  final String fromCity;
  final String fromCode;
  final String toCity;
  final String toCode;

  @override
  Widget build(BuildContext context) {
    TextStyle small(double size, double o) => AppText.s(
      size,
      w: FontWeight.w400,
      color: AppColors.white.withValues(alpha: o),
    );
    Widget end(String city, String code, CrossAxisAlignment a) => Column(
      crossAxisAlignment: a,
      children: [
        Txt(city, style: small(12.5, .7)),
        Txt(
          code,
          style: AppText.s(30, w: FontWeight.w800, color: AppColors.white),
        ),
      ],
    );
    return Container(
      height: 340,
      decoration: BoxDecoration(
        gradient: AppGradients.selectHero,
        borderRadius: AppRadii.selectHero,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            top: 128,
            width: 400,
            height: 140,
            child: AnimatedBuilder(
              animation: arc,
              builder:
                  (_, __) => CustomPaint(
                    painter: FlightArcPainter(
                      Curves.easeInOutQuad.transform(arc.value),
                    ),
                  ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 206,
            child: Column(
              children: [
                Txt(duration, style: small(13, .75)),
                const SizedBox(height: 4),
                Txt(
                  date,
                  style: AppText.s(
                    17,
                    w: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                end(fromCity, fromCode, CrossAxisAlignment.start),
                end(toCity, toCode, CrossAxisAlignment.end),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo blanco que aparece al arrastrar hacia abajo y gira al recargar.
class _PullIndicator extends StatefulWidget {
  const _PullIndicator({
    required this.label,
    required this.pull,
    required this.refreshing,
  });
  final String label;
  final double pull;
  final bool refreshing;

  @override
  State<_PullIndicator> createState() => _PullIndicatorState();
}

class _PullIndicatorState extends State<_PullIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(_PullIndicator old) {
    super.didUpdateWidget(old);
    if (widget.refreshing && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.refreshing && _spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = widget.refreshing || widget.pull > 8;
    final dy = widget.refreshing ? 40.0 : math.min(70.0, widget.pull * .5);
    final angle = widget.refreshing ? 0.0 : widget.pull * 2 * math.pi / 180;
    return Positioned(
      left: 0,
      right: 0,
      top: 134,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            duration: AppDurations.quick,
            opacity: show ? 1 : 0,
            child: Transform.translate(
              offset: Offset(0, show ? dy : -30),
              child: Semantics(
                label: widget.label,
                child: RotationTransition(
                  turns:
                      widget.refreshing
                          ? _spin
                          : const AlwaysStoppedAnimation(0),
                  child: Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: AppShadows.pullIndicator,
                      ),
                      child: const SizedBox.square(
                        dimension: 22,
                        child: CustomPaint(painter: _RefreshGlyph()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshGlyph extends CustomPainter {
  const _RefreshGlyph();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primary;
    canvas.drawPath(
      Path()
        ..moveTo(20, 12)
        ..arcToPoint(
          const Offset(17.66, 6.34),
          radius: const Radius.circular(8),
          largeArc: true,
        ),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(20, 4)
        ..relativeLineTo(0, 5)
        ..relativeLineTo(-5, 0),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
