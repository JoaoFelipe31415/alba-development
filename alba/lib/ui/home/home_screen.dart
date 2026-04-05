import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/login/login_screen.dart';
import 'package:alba/ui/metas/criar_meta_screen.dart';
import 'package:alba/ui/metas/editar_meta_screen.dart';
import 'package:alba/ui/metas/gerenciamento_metas_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authRepository = injector.get<AuthRepository>();
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const InicioScreen(),
    const GeraciamentoMetasScreen(),
    const _ProximamentScreen(), // Progresso
    const _ProximamentScreen(), // On-Demand
    const _ProximamentScreen(), // Menu
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: context.colors.greyOne,
        selectedItemColor: context.colors.primaryColor,
        unselectedItemColor: context.colors.textPrimaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Metas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'On-Demand',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final authRepository = injector.get<AuthRepository>();
  final metasRepository = injector.get<MetasRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        title: Text(
          'Gerenciamento de Metas',
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          PopupMenuButton(
            color: context.colors.greyOne,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  'Sair',
                  style: TextStyle(color: context.colors.errorColor),
                ),
                onTap: () {
                  authRepository.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
            child: Icon(Icons.more_vert, color: context.colors.whiteColor),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CriarMetaScreen(),
                ),
              )
              .then((_) {
                if (mounted) {
                  setState(() {});
                }
              });
        },
        backgroundColor: context.colors.primaryColor,
        child: Icon(Icons.add, color: context.colors.whiteColor, size: 32),
      ),
      body: StreamBuilder<List<MetaDto>>(
        stream: metasRepository.obterMetasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: context.colors.primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar metas',
                style: TextStyle(color: context.colors.errorColor),
              ),
            );
          }

          final todasAsMetas = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção Minhas Metas
                Text(
                  'Minhas Metas',
                  style: TextStyle(
                    color: context.colors.whiteColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Lista de metas
                if (todasAsMetas.isNotEmpty)
                  ...todasAsMetas.map((meta) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditarMetaScreen(meta: meta),
                              ),
                            )
                            .then((_) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E3A8A), // Azul escuro
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Ícone círculo à esquerda
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.colors.whiteColor.withAlpha(
                                    (255 * 0.4).toInt(),
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Título no centro
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meta.tituloMeta,
                                    style: TextStyle(
                                      color: context.colors.whiteColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Tag embaixo do título
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCorTag(meta.tag),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getNomeTag(meta.tag),
                                      style: TextStyle(
                                        color: context.colors.backgroundColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Ícones à direita (delete e edit)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: context.colors.greyOne,
                                        title: Text(
                                          'Deletar meta?',
                                          style: TextStyle(
                                            color: context.colors.whiteColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          'Tem certeza que deseja deletar esta meta?',
                                          style: TextStyle(
                                            color:
                                                context.colors.textPrimaryColor,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                color:
                                                    context.colors.focusColor,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                await metasRepository
                                                    .excluirMeta(meta.id!);
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        e.toString(),
                                                      ),
                                                      backgroundColor: context
                                                          .colors
                                                          .errorColor,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: Text(
                                              'Deletar',
                                              style: TextStyle(
                                                color:
                                                    context.colors.errorColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.green,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Icon(
                                  Icons.edit,
                                  color: Color(0xFF84F41E),
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getNomeTag(String tag) {
    return tag.toLowerCase() == 'negocio' ? 'Negócio' : 'Faculdade';
  }

  Color _getCorTag(String tag) {
    if (tag.toLowerCase() == 'negocio') {
      return Color(0xFF10B981); // Verde
    } else {
      return Color(0xFF3B82F6); // Azul
    }
  }
}

class _ProximamentScreen extends StatelessWidget {
  const _ProximamentScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: context.colors.textPrimaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Em breve',
            style: TextStyle(
              color: context.colors.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta funcionalidade em breve estará disponível',
            style: TextStyle(color: context.colors.textPrimaryColor),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
