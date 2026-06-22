// lib/views/calendario_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/produto_viewmodel.dart';

class CalendarioView extends StatefulWidget {
  const CalendarioView({super.key});
  @override
  State<CalendarioView> createState() => _CalendarioViewState();
}

class _CalendarioViewState extends State<CalendarioView> {
  DateTime? _mesSelecionado;

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ProdutoViewModel>();
    final meses  = vm.mesesComRegistros;
    final scheme = Theme.of(context).colorScheme;
    final moeda  = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Calendário Mensal'), centerTitle: true),
      body: meses.isEmpty
          ? _vazio(context)
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Selecione um mês',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final mes = meses[i];
                        final selecionado = _mesSelecionado != null &&
                            _mesSelecionado!.year == mes.year &&
                            _mesSelecionado!.month == mes.month;
                        final lucro    = vm.lucroNoMes(mes);
                        final corLucro = lucro >= 0 ? Colors.green.shade600 : Colors.red.shade600;

                        return GestureDetector(
                          onTap: () => setState(() {
                            _mesSelecionado = selecionado ? null : mes;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selecionado ? scheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.calendar_month_rounded,
                                        color: selecionado ? scheme.primary : scheme.onSurfaceVariant,
                                        size: 18),
                                    Text('${vm.produtosDeMes(mes).length} itens',
                                        style: TextStyle(fontSize: 10, color: scheme.onSurface.withValues(alpha: 0.5))),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_nomeAbreviado(mes),
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: selecionado ? scheme.primary : scheme.onSurface,
                                            )),
                                    Text(mes.year.toString(),
                                        style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.5))),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: corLucro.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(moeda.format(lucro),
                                      style: TextStyle(color: corLucro, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: meses.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                  ),
                ),
                if (_mesSelecionado != null)
                  SliverToBoxAdapter(child: _detalhesMes(context, vm, _mesSelecionado!, moeda)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  Widget _detalhesMes(BuildContext context, ProdutoViewModel vm, DateTime mes, NumberFormat moeda) {
    final produtos  = vm.produtosDeMes(mes);
    final investido = vm.investidoNoMes(mes);
    final vendido   = vm.vendidoNoMes(mes);
    final lucro     = vm.lucroNoMes(mes);
    final scheme    = Theme.of(context).colorScheme;
    final dataFmt   = DateFormat('dd/MM/yyyy');
    final corLucro  = lucro >= 0 ? Colors.green.shade600 : Colors.red.shade600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              Text(_nomeCompleto(mes),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniCard(context, 'Investido', moeda.format(investido), Colors.orange.shade600, Icons.arrow_downward_rounded),
              const SizedBox(width: 8),
              _miniCard(context, 'Vendido', moeda.format(vendido), Colors.blue.shade600, Icons.arrow_upward_rounded),
              const SizedBox(width: 8),
              _miniCard(context, 'Lucro', moeda.format(lucro), corLucro,
                  lucro >= 0 ? Icons.trending_up : Icons.trending_down),
            ],
          ),
          const SizedBox(height: 16),
          Text('${produtos.length} produto(s) neste mês',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  )),
          const SizedBox(height: 8),
          ...produtos.map((p) {
            final pl = p.lucro >= 0 ? Colors.green.shade600 : Colors.red.shade600;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(dataFmt.format(p.dataCadastro),
                            style: TextStyle(fontSize: 11, color: scheme.onSurface.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(moeda.format(p.valorVenda),
                          style: TextStyle(color: Colors.blue.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(moeda.format(p.lucro),
                          style: TextStyle(color: pl, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _miniCard(BuildContext ctx, String label, String valor, Color cor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cor, size: 16),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: cor.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
            Text(valor, style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _vazio(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: scheme.outlineVariant),
          const SizedBox(height: 16),
          Text('Nenhum registro ainda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 8),
          Text('Adicione produtos para ver o calendário',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  String _nomeAbreviado(DateTime mes) {
    const meses = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
    return meses[mes.month - 1];
  }

  String _nomeCompleto(DateTime mes) {
    const meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho',
        'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
    return '${meses[mes.month - 1]} de ${mes.year}';
  }
}
