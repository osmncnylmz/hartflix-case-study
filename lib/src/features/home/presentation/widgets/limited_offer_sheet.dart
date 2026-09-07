import 'package:flutter/material.dart';

Future<void> showLimitedOfferSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const LimitedOfferSheet(),
  );
}

class LimitedOfferSheet extends StatelessWidget {
  const LimitedOfferSheet({super.key});

  static const _bgTop = Color(0xFF2B0000);
  static const _bgBottom = Color(0xFF5A0006);
  static const _chipRedA = Color(0xFF7A0006);
  static const _chipRedB = Color(0xFF9C0D12);
  static const _chipVioletA = Color(0xFF4B1EE5);
  static const _chipVioletB = Color(0xFF6A00FF);
  static const _ctaRed = Color(0xFFE61F2B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_bgTop, _bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 12,
        bottom: 18 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Sınırlı Teklif',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Jeton paketini seçerek bonus kazanın ve yeni bölümlerin kilidini açın!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              const _BonusRow(),

              const SizedBox(height: 18),

              LayoutBuilder(
                builder: (context, c) {
                  final gap = c.maxWidth < 360 ? 10.0 : 12.0;
                  return Row(
                    children: [
                      Expanded(
                        child: _PackCard(
                          badgeText: '+10%',
                          gradientA: _chipRedA,
                          gradientB: _chipRedB,
                          amountNow: '330',
                          amountOld: '200',
                          price: '₺99,99',
                          weeklyNote: 'Başına haftalık',
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: _PackCard(
                          badgeText: '+70%',
                          gradientA: _chipVioletA,
                          gradientB: _chipVioletB,
                          highlight: true,
                          amountNow: '3.375',
                          amountOld: '2.000',
                          price: '₺799,99',
                          weeklyNote: 'Başına haftalık',
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: _PackCard(
                          badgeText: '+35%',
                          gradientA: _chipRedA,
                          gradientB: _chipRedB,
                          amountNow: '1.350',
                          amountOld: '1.000',
                          price: '₺399,99',
                          weeklyNote: 'Başına haftalık',
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _ctaRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Tüm Jetonları Gör',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BonusRow extends StatelessWidget {
  const _BonusRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _Bonus(icon: Icons.auto_awesome, title: 'Premium\nHesap'),
          _Bonus(icon: Icons.favorite, title: 'Daha\nFazla Eşleşme'),
          _Bonus(icon: Icons.north, title: 'Öne\nÇıkarma'),
          _Bonus(icon: Icons.favorite_border, title: 'Daha\nFazla Beğeni'),
        ],
      ),
    );
  }
}

class _Bonus extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Bonus({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFF6699), Color(0xFFFF2E6E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 6),
        const Text('', style: TextStyle(height: 0)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _PackCard extends StatelessWidget {
  final String badgeText;
  final Color gradientA;
  final Color gradientB;
  final String amountNow;
  final String amountOld;
  final String price;
  final String weeklyNote;
  final bool highlight;

  const _PackCard({
    required this.badgeText,
    required this.gradientA,
    required this.gradientB,
    required this.amountNow,
    required this.amountOld,
    required this.price,
    required this.weeklyNote,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientA, gradientB],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              if (highlight)
                BoxShadow(
                  color: gradientB.withValues(alpha: .35),
                  blurRadius: 20,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: .18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  amountOld,
                  style: const TextStyle(
                    color: Colors.white70,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                amountNow,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 2),
              const Text('Jeton', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                weeklyNote,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        Positioned(
          top: -10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: .35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .12),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
