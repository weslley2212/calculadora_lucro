// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../services/pdf_service.dart';
import '../viewmodels/produto_viewmodel.dart';
import '../widgets/graficos_widget.dart';
import '../widgets/produto_card.dart';
import '../widgets/produto_form.dart';
import '../widgets/resumo_card.dart';
import 'calendario_view.dart';

/// Tela principal do aplicativo.
class HomeView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const HomeView({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final TabController _tabController;
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;
  final _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportarPDF(List<Produto> produtos) async {
    if (produtos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nenhum produto para exportar!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    try {
      await _pdfService.gerarECompartilhar(produtos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmarExcluir(BuildContext context, Produto produto) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Excluir produto'),
          ],
        ),
        content: Text('Tem certeza que deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ProdutoViewModel>().excluirProduto(produto.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _abrirEditar(BuildContext context, Produto produto) {
    showDialog(
      context: context,
      builder: (ctx) => EditarProdutoDialog(produto: produto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ProdutoViewModel>();
    final scheme = Theme.of(context).colorScheme;
    final moeda  = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar produto...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.5)),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: vm.pesquisar,
              )
            : const Text('Calculadora de Lucro'),
        centerTitle: true,
        actions: [
          // Modo claro/escuro
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            tooltip: 'Alternar tema',
            onPressed: widget.onToggleTheme,
          ),
          // Busca
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  vm.pesquisar('');
                }
              });
            },
          ),
          // Calendário
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Calendário Mensal',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalendarioView()),
            ),
          ),
          // Exportar PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Exportar PDF',
            onPressed: () => _exportarPDF(vm.produtos),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list_rounded), text: 'Produtos'),
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Gráficos'),
            Tab(icon: Icon(Icons.tune_rounded), text: 'Filtros'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── ABA 1: PRODUTOS ──────────────────────────────────────────────
          _buildAbaProdutos(context, vm, scheme, moeda),

          // ── ABA 2: GRÁFICOS ──────────────────────────────────────────────
          vm.produtos.isEmpty
              ? _buildVazio(context)
              : const SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: GraficosWidget(),
                  ),
                ),

          // ── ABA 3: FILTROS ────────────────────────────────────────────────
          _buildAbaFiltros(context, vm),
        ],
      ),
    );
  }

  Widget _buildAbaProdutos(
      BuildContext context, ProdutoViewModel vm, ColorScheme scheme, NumberFormat moeda) {
    return CustomScrollView(
      slivers: [
        // ─ Resumo financeiro ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: scheme.surfaceVariant.withOpacity(0.3),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Resumo Financeiro',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                    Text('${vm.totalProdutos} produto(s)',
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurface.withOpacity(0.5))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ResumoCard(
                        titulo: 'Total Investido',
                        valor: vm.totalInvestido,
                        icone: Icons.arrow_downward_rounded,
                        cor: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResumoCard(
                        titulo: 'Total Vendido',
                        valor: vm.totalVendido,
                        icone: Icons.arrow_upward_rounded,
                        cor: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ResumoCard(
                        titulo: 'Lucro Total',
                        valor: vm.lucroTotal,
                        icone: vm.lucroTotal >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        cor: vm.lucroTotal >= 0
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ─ Formulário de cadastro ─────────────────────────────────────────
        const SliverToBoxAdapter(child: ProdutoForm()),

        // ─ Título da lista ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.inventory_2_rounded, size: 16, color: scheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(
                  vm.produtos.isEmpty
                      ? 'Nenhum produto cadastrado'
                      : '${vm.produtos.length} produto(s)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),

        // ─ Lista de produtos ──────────────────────────────────────────────
        vm.carregando
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
            : vm.produtos.isEmpty
                ? SliverFillRemaining(child: _buildVazio(context))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => ProdutoCard(
                        produto: vm.produtos[i],
                        onEditar: () => _abrirEditar(context, vm.produtos[i]),
                        onExcluir: () => _confirmarExcluir(context, vm.produtos[i]),
                      ),
                      childCount: vm.produtos.length,
                    ),
                  ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildAbaFiltros(BuildContext context, ProdutoViewModel vm) {
    final scheme = Theme.of(context).colorScheme;

    final opcoes = [
      (FiltroOrdem.todos,       'Todos',         Icons.apps_rounded),
      (FiltroOrdem.maiorLucro,  'Maior Lucro',   Icons.trending_up_rounded),
      (FiltroOrdem.menorLucro,  'Menor Lucro',   Icons.trending_down_rounded),
      (FiltroOrdem.maisRecente, 'Mais Recente',  Icons.schedule_rounded),
      (FiltroOrdem.maisAntigo,  'Mais Antigo',   Icons.history_rounded),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Ordenar lista por',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...opcoes.map((o) {
          final selecionado = vm.filtro == o.$1;
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: selecionado ? scheme.primary : scheme.outlineVariant.withOpacity(0.5),
                width: selecionado ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selecionado ? scheme.primaryContainer : scheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(o.$3,
                    color: selecionado ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                    size: 20),
              ),
              title: Text(o.$2,
                  style: TextStyle(
                      fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
                      color: selecionado ? scheme.primary : null)),
              trailing: selecionado
                  ? Icon(Icons.check_circle_rounded, color: scheme.primary)
                  : null,
              onTap: () => vm.alterarFiltro(o.$1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVazio(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Nenhum produto ainda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.5),
                  )),
          const SizedBox(height: 8),
          Text('Use o formulário acima para adicionar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withOpacity(0.4),
                  )),
        ],
      ),
    );
  }
}
