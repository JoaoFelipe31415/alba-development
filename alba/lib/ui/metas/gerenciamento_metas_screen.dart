import 'package:alba/config/dependencies.dart';
import 'package:alba/data/repositories/metas_repository.dart';
import 'package:alba/domain/dto/meta_dto.dart';
import 'package:alba/domain/validators/meta_validator.dart';
import 'package:alba/ui/design_system/constants/spaces.dart';
import 'package:alba/ui/design_system/theme/app_colors.dart';
import 'package:alba/ui/metas/criar_meta_screen.dart';
import 'package:alba/ui/metas/editar_meta_screen.dart';
import 'package:flutter/material.dart';

class GeraciamentoMetasScreen extends StatefulWidget {
  const GeraciamentoMetasScreen({super.key});

  @override
  State<GeraciamentoMetasScreen> createState() =>
      _GeraciamentoMetasScreenState();
}

class _GeraciamentoMetasScreenState extends State<GeraciamentoMetasScreen> {
  final metasRepository = injector.get<MetasRepository>();
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _navigateToCriarMeta() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CriarMetaScreen()))
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  void _navigateToEditarMeta(MetaDto meta) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => EditarMetaScreen(meta: meta)),
        )
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  void _excluirMeta(String metaId, MetaDto meta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.greyOne,
        title: Text(
          'Tem certeza?',
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: context.colors.textPrimaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.colors.focusColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await metasRepository.excluirMeta(metaId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meta excluída com sucesso!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: context.colors.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Excluir',
              style: TextStyle(color: context.colors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.backgroundColor,
        elevation: 0,
        title: Text(
          'Metas',
          style: TextStyle(
            color: context.colors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: Spaces.xl,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Spaces.l),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: context.colors.whiteColor),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Filtrar pelo título da meta',
                hintStyle: TextStyle(color: context.colors.textPrimaryColor),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textPrimaryColor,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: context.colors.textPrimaryColor,
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: context.colors.greyOne,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: Spaces.m,
                  horizontal: Spaces.l,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MetaDto>>(
              stream: searchQuery.isEmpty
                  ? metasRepository.obterMetasStream()
                  : metasRepository.buscarMetasStream(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar metas',
                      style: TextStyle(color: context.colors.errorColor),
                    ),
                  );
                }

                final metas = snapshot.data ?? [];

                if (metas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 64,
                          color: context.colors.textPrimaryColor,
                        ),
                        const SizedBox(height: Spaces.l),
                        Text(
                          'Nenhuma meta encontrada',
                          style: TextStyle(
                            color: context.colors.textPrimaryColor,
                            fontSize: Spaces.l,
                          ),
                        ),
                        const SizedBox(height: Spaces.m),
                        Text(
                          'Crie sua primeira meta clicando em Criar Meta',
                          style: TextStyle(
                            color: context.colors.greyThree,
                            fontSize: Spaces.m,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(Spaces.l),
                  itemCount: metas.length,
                  itemBuilder: (context, index) {
                    final meta = metas[index];
                    final diasRestantes = meta.prazo
                        .difference(DateTime.now())
                        .inDays;
                    final progresso = diasRestantes > 0 ? diasRestantes : 0;

                    return Card(
                      color: context.colors.greyOne,
                      margin: const EdgeInsets.only(bottom: Spaces.l),
                      child: Padding(
                        padding: const EdgeInsets.all(Spaces.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meta.tituloMeta,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: context.colors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Spaces.l,
                                        ),
                                      ),
                                      const SizedBox(height: Spaces.s),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spaces.s,
                                          vertical: Spaces.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: meta.tag == 'negocio'
                                              ? context.colors.focusColor
                                              : context.colors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          meta.tag == 'negocio'
                                              ? 'Negócio'
                                              : 'Faculdade',
                                          style: TextStyle(
                                            color: context.colors.whiteColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: context.colors.focusColor,
                                      ),
                                      onPressed: () {
                                        _navigateToEditarMeta(meta);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: context.colors.errorColor,
                                      ),
                                      onPressed: () =>
                                          _excluirMeta(meta.id!, meta),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: Spaces.l),
                            Text(
                              'Prazo: ${MetaValidator.formatDate(meta.prazo)}',
                              style: TextStyle(
                                color: context.colors.textPrimaryColor,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: Spaces.s),
                            LinearProgressIndicator(
                              value: progresso > 0 ? 1.0 : 0.0,
                              backgroundColor: context.colors.greyTwo,
                              valueColor: AlwaysStoppedAnimation(
                                diasRestantes > 7
                                    ? context.colors.successColor
                                    : diasRestantes > 0
                                    ? context.colors.alert
                                    : context.colors.errorColor,
                              ),
                            ),
                            const SizedBox(height: Spaces.s),
                            Text(
                              diasRestantes > 0
                                  ? '$diasRestantes dias restantes'
                                  : 'Prazo expirado',
                              style: TextStyle(
                                color: diasRestantes > 0
                                    ? context.colors.successColor
                                    : context.colors.errorColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.colors.primaryColor,
        onPressed: _navigateToCriarMeta,
        child: Icon(Icons.add, color: context.colors.whiteColor),
      ),
    );
  }
}

extension on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? const AppColors();
}
