import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../core/theme/illustrations.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/l10n_x.dart';
import '../../../core/widgets/widgets.dart';
import 'login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // La imagen de cabecera se decodifica antes de pintar la pantalla.
    precacheImage(const AssetImage(LoginHero.asset), context);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (a, b) => b.status == LoginStatus.success,
      listener: (context, state) => context.go('/home'),
      builder: (context, state) {
        final bloc = context.read<LoginBloc>();
        return ScreenFrame(
          lightIcons: false,
          background: AppColors.white,
          child: Stack(
            children: [
              const Positioned(left: 0, right: 0, top: 0, child: LoginHero()),
              Positioned(
                left: 0,
                right: 0,
                top: 296,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 12, 26, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.grabHandle,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Txt(
                          l.loginTitle,
                          style: AppText.s(25, w: FontWeight.w800, ls: -.25),
                        ),
                        const SizedBox(height: 6),
                        Txt(
                          l.loginSubtitle,
                          style: AppText.s(
                            13.5,
                            w: FontWeight.w400,
                            color: AppColors.ink2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _Field(
                          icon: 'i-mail',
                          hint: l.emailHint,
                          controller: _email,
                          keyboard: TextInputType.emailAddress,
                        ),
                        _Field(
                          icon: 'i-lock',
                          hint: l.passwordHint,
                          controller: _password,
                          obscure: state.obscure,
                          trailing: GestureDetector(
                            onTap:
                                () =>
                                    bloc.add(const PasswordVisibilityToggled()),
                            behavior: HitTestBehavior.opaque,
                            child: Semantics(
                              button: true,
                              label:
                                  state.obscure
                                      ? l.showPassword
                                      : l.hidePassword,
                              excludeSemantics: true,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: AppIcon(
                                  state.obscure ? 'i-eye-off' : 'i-eye',
                                  size: 19,
                                  color: AppColors.fieldIcon,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              ConsentCheckbox(
                                checked: state.remember,
                                label: l.rememberMe,
                                onChanged:
                                    (_) => bloc.add(const RememberMeToggled()),
                              ),
                              const SizedBox(width: 10),
                              Txt(
                                l.rememberMe,
                                style: AppText.s(
                                  13,
                                  w: FontWeight.w400,
                                  color: AppColors.ink2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Txt(
                                l.forgotPassword,
                                style: AppText.s(
                                  13,
                                  w: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GradientPillButton(
                          label: l.signIn,
                          fullWidth: true,
                          onTap:
                              () => bloc.add(
                                SignInPressed(_email.text, _password.text),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 16),
                          child: Row(
                            children: [
                              const Expanded(child: Hairline()),
                              const SizedBox(width: 12),
                              Txt(
                                l.orContinueWith,
                                style: AppText.s(
                                  12.5,
                                  w: FontWeight.w400,
                                  color: AppColors.placeholder,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: Hairline()),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _Social(
                                label: l.google,
                                mark: _GoogleMark(),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _Social(
                                label: l.apple,
                                mark: _AppleMark(),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 22),
                          child: Text.rich(
                            TextSpan(
                              text: l.noAccount,
                              children: [
                                TextSpan(
                                  text: l.createAccount,
                                  style: AppText.s(
                                    13.5,
                                    w: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            style: AppText.s(
                              13.5,
                              w: FontWeight.w400,
                              color: AppColors.ink2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              BlurOverlay(
                visible: state.status == LoginStatus.loading,
                title: l.signingIn,
                detail: l.preparingTickets,
                loader: const PlaneOrbitLoader(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.icon,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.trailing,
    this.keyboard,
  });
  final String icon;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final Widget? trailing;
  final TextInputType? keyboard;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18 - 1.5),
      decoration: BoxDecoration(
        color: focused ? AppColors.white : AppColors.field,
        borderRadius: AppRadii.field,
        border: Border.all(
          color: focused ? AppColors.loginFocus : AppColors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          AppIcon(widget.icon, size: 19, color: AppColors.fieldIcon),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              obscureText: widget.obscure,
              keyboardType: widget.keyboard,
              cursorColor: AppColors.primary,
              style: AppText.s(15, w: FontWeight.w500, h: 1.26),
              decoration: InputDecoration.collapsed(
                hintText: widget.hint,
                hintStyle: AppText.s(
                  15,
                  w: FontWeight.w500,
                  color: AppColors.placeholder,
                  h: 1.26,
                ),
              ),
            ),
          ),
          if (widget.trailing != null)
            Transform.translate(
              offset: const Offset(6, 0),
              child: widget.trailing,
            ),
        ],
      ),
    );
  }
}

class _Social extends StatelessWidget {
  const _Social({required this.label, required this.mark});
  final String label;
  final Widget mark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.field,
        border: Border.all(color: AppColors.socialBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mark,
          const SizedBox(width: 10),
          Txt(label, style: AppText.s(15, w: FontWeight.w700, h: 1.26)),
        ],
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/google_logo.png',
    width: 22,
    height: 22,
    excludeFromSemantics: true,
  );
}

class _AppleMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/apple_logo.png',
    width: 22,
    height: 22,
    excludeFromSemantics: true,
  );
}
