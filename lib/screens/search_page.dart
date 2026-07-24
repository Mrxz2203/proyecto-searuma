import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';
import '../widgets/character_tile.dart';
import '../theme/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().loadCharacters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _SearchBar(controller: _searchController),
            ),
            Expanded(
              child: Consumer<CharacterProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.forestGreen),
                    );
                  }
                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.softOrange, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Error al cargar personajes',
                            style: const TextStyle(color: AppColors.leatherBrown, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.loadCharacters(),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen),
                            child: const Text('Reintentar', style: TextStyle(color: AppColors.warmWhite)),
                          ),
                        ],
                      ),
                    );
                  }
                  if (provider.paginatedCharacters.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron personajes.', style: TextStyle(color: AppColors.leatherBrown)),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: provider.paginatedCharacters.length,
                      itemBuilder: (context, index) {
                        return CharacterTile(character: provider.paginatedCharacters[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            Consumer<CharacterProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading || provider.error != null) return const SizedBox.shrink();
                return _PaginationBar(provider: provider);
              },
            ),
          ],
        ),
      ),
    );
  }
}
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.forestGreen,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _InicioButton(onTap: () => context.go('/')),
          const Spacer(),
          const Text(
            'SearUma',
            style: TextStyle(color: AppColors.warmWhite, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Spacer(),
          const SizedBox(width: 70), // balancea visualmente el "Inicio" de la izquierda
        ],
      ),
    );
  }
}

class _InicioButton extends StatefulWidget {
  final VoidCallback onTap;
  const _InicioButton({required this.onTap});

  @override
  State<_InicioButton> createState() => _InicioButtonState();
}

class _InicioButtonState extends State<_InicioButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.warmWhite.withValues(alpha: _hovering ? 0.25 : 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warmWhite.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_back, color: AppColors.warmWhite, size: 18),
              SizedBox(width: 8),
              Text('Inicio', style: TextStyle(color: AppColors.warmWhite, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (value) => context.read<CharacterProvider>().updateSearchQuery(value),
      decoration: InputDecoration(
        hintText: 'Buscar Uma Musume...',
        prefixIcon: const Icon(Icons.search, color: AppColors.oliveGreen),
        filled: true,
        fillColor: AppColors.warmWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final CharacterProvider provider;
  const _PaginationBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: provider.currentPage > 1 ? provider.previousPage : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Anterior'),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkBrown),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Página ${provider.currentPage} de ${provider.totalPages}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkBrown),
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: provider.currentPage < provider.totalPages ? provider.nextPage : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Siguiente'),
            style: TextButton.styleFrom(foregroundColor: AppColors.darkBrown),
          ),
        ],
      ),
    );
  }
}