import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class SearUmaNavBar extends StatelessWidget {
  final VoidCallback onInicioTap;
  final VoidCallback onCaracteristicasTap;
  final VoidCallback onAcercaDeTap;

  const SearUmaNavBar({
    super.key,
    required this.onInicioTap,
    required this.onCaracteristicasTap,
    required this.onAcercaDeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
  color: AppColors.forestGreen,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: Image.asset(
    'assets/images/logo.png',
    width: 36,
    height: 36,
    fit: BoxFit.cover,
  ),
),
              
              const SizedBox(width: 10),
              const Text(
                'SearUma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
               color: AppColors.warmWhite,
                ),
              ),
            ],
          ),
          // En pantallas angostas ocultamos los links de texto para no saturar
          if (MediaQuery.of(context).size.width > 700)
            Row(
              children: [
                GestureDetector(onTap: onInicioTap, child: const _NavLink('Inicio')),
                const SizedBox(width: 28),
                GestureDetector(onTap: onCaracteristicasTap, child: const _NavLink('Características')),
                const SizedBox(width: 28),
                GestureDetector(onTap: onAcercaDeTap, child: const _NavLink('Acerca de')),
              ],
            ),
          ElevatedButton(
            onPressed: () => context.go('/search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBrown,
              foregroundColor: AppColors.warmWhite,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Explorar →'),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String text;
  const _NavLink(this.text);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.lightGreen,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}