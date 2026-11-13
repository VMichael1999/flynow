import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/illustrations.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'profile_bloc.dart';

/// Perfil: datos, estadísticas y preferencias.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bloc = context.read<ProfileBloc>();
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, s) {
        final d = s.data;
        return ScreenFrame(
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 150, 22, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeader(
                        photo: const ProfilePhoto(),
                        name: d.name,
                        email: d.email,
                        homeLine: l.flyFrom(d.homeCity, d.homeCode),
                        editLabel: l.editProfile,
                      ),
                      const SizedBox(height: 20),
                      StatsRow(
                        stats: [
                          ('${d.tripsDone}', l.statTrips),
                          ('${d.cities}', l.statCities),
                          ('${s.upcoming}', l.statUpcoming),
                        ],
                      ),
                      SettingsGroup(
                        label: l.groupAccount,
                        children: [
                          SettingsTile(icon: 'i-user', title: l.personalData),
                          SettingsTile(
                            icon: 'i-users',
                            title: l.savedPassengers,
                            value: '${d.savedPassengers}',
                          ),
                          SettingsTile(
                            icon: 'i-card',
                            title: l.paymentMethods,
                            value: d.paymentMethods,
                          ),
                          SettingsTile(
                            icon: 'i-doc',
                            title: l.travelDocs,
                            value: d.documents,
                          ),
                        ],
                      ),
                      SettingsGroup(
                        label: l.groupPrefs,
                        children: [
                          SettingsTile(
                            icon: 'i-bell',
                            title: l.flightAlerts,
                            switchValue: s.flightAlerts,
                            onChanged:
                                (_) => bloc.add(const FlightAlertsToggled()),
                          ),
                          SettingsTile(
                            icon: 'i-seat',
                            title: l.seatPref,
                            value: d.seatPreference,
                          ),
                          SettingsTile(
                            icon: 'i-coin',
                            title: l.currency,
                            value: d.currency,
                          ),
                        ],
                      ),
                      SettingsGroup(
                        label: l.groupHelp,
                        children: [
                          SettingsTile(icon: 'i-help', title: l.helpCenter),
                          SettingsTile(icon: 'i-shield', title: l.privacy),
                        ],
                      ),
                      const SizedBox(height: 22),
                      LogoutButton(
                        label: l.logout,
                        onTap: () => context.go('/login'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Txt(
                          l.versionLabel,
                          textAlign: TextAlign.center,
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
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SkyAppBar(
                  title: l.navProfile,
                  leading: const BrandMark(),
                  trailing: GlassCircleButton(
                    icon: 'i-settings',
                    label: l.settings,
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
