import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/styles/sinflix_theme.dart';
import '../../../../shared/widgets/sinflix_fields.dart'
    show SinflixField, SocialButton;

import '../bloc/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _ob1 = true, _ob2 = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              decoration: BoxDecoration(
                color: SinflixTheme.cardDark,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state.status == 'authenticated') context.go('/home');
                  if (state.status == 'failure') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message ?? 'Hata')),
                    );
                  }
                },
                builder: (context, state) {
                  final loading = state.status == 'loading';
                  return SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Başlık
                          Text(
                            'Hoşgeldiniz 🎉',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Yeni bir hesap oluştur ve hemen başla!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Ad Soyad
                          SinflixField(
                            controller: _name,
                            hint: 'Ad Soyad',
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                (v != null && v.isNotEmpty) ? null : 'Zorunlu',
                          ),
                          const SizedBox(height: 16),

                          // E-posta
                          SinflixField(
                            controller: _email,
                            hint: 'E-Posta',
                            icon: Icons.mail_outline_rounded,
                            type: TextInputType.emailAddress,
                            validator: (v) => (v != null && v.contains('@'))
                                ? null
                                : 'Geçersiz e-posta',
                          ),
                          const SizedBox(height: 16),

                          // Şifre
                          SinflixField(
                            controller: _pass,
                            hint: 'Şifre',
                            icon: Icons.lock_outline_rounded,
                            obscure: _ob1,
                            onToggle: () => setState(() => _ob1 = !_ob1),
                            validator: (v) => (v != null && v.length >= 6)
                                ? null
                                : 'Min 6 karakter',
                          ),
                          const SizedBox(height: 16),

                          // Şifre tekrar
                          SinflixField(
                            controller: _pass2,
                            hint: 'Şifre Tekrar',
                            icon: Icons.lock_outline_rounded,
                            obscure: _ob2,
                            onToggle: () => setState(() => _ob2 = !_ob2),
                            validator: (v) => (v == _pass.text)
                                ? null
                                : 'Şifreler eşleşmiyor',
                          ),
                          const SizedBox(height: 18),

                          // Kullanıcı sözleşmesi
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: 'Kullanıcı sözleşmesini ',
                                style: const TextStyle(color: Colors.white70),
                                children: const [
                                  TextSpan(
                                    text: 'okudum ve kabul ediyorum.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // CTA
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: loading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().register(
                                          _name.text.trim(),
                                          _email.text.trim(),
                                          _pass.text,
                                        );
                                      }
                                    },
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : const Text(
                                      'Şimdi Kaydol',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sosyal giriş
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialButton(
                                icon: Icons.g_mobiledata,
                                onTap: () {},
                              ),
                              const SizedBox(width: 18),
                              SocialButton(icon: Icons.apple, onTap: () {}),
                              const SizedBox(width: 18),
                              SocialButton(icon: Icons.facebook, onTap: () {}),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Login linki
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Zaten hesabın var mı?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
