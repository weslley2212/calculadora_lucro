// lib/widgets/graficos_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/produto_viewmodel.dart';

class GraficosWidget extends StatefulWidget {
  const GraficosWidget({super.key});
  @override
  State<GraficosWidget> createState() => _GraficosWidgetState();
}

class _GraficosWidgetState extends State<GraficosWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ProdutoViewModel>();
    final dados  = vm.dadosGraficoBarras;
    final scheme = Theme.of(context).colorScheme;

    if (dados.isEmpty) return const SizedBox.shrink();

    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final coresPizza = [
      scheme.primary,
      Colors.orange.shade500,
      Colors.teal.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
      Colors.amber.shade500,
      Colors.indigo.shade400,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Dashboard',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),

        // ── Gráfico de Barras ──────────────────────────────────────────
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: scheme.outlineVariant.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lucro por Produto (Top ${dados.length})',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          // compatível com fl_chart 0.68
                          getTooltipColor: (_) => scheme.inverseSurface,
                          getTooltipItem: (group, gI, rod, rI) =>
                              BarTooltipItem(
                            '${dados[group.x].nome}\n${moeda.format(rod.toY)}',
                            TextStyle(
                                color: scheme.onInverseSurface,
                                fontSize: 11),
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: scheme.outlineVariant.withOpacity(0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: dados.asMap().entries.map((e) {
                        final lucro = e.value.lucro;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: lucro < 0 ? 0 : lucro,
                              color: lucro >= 0
                                  ? scheme.primary
                                  : scheme.error,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (v, m) => Text(
                              'R\$ ${v.toInt()}',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: scheme.onSurface.withOpacity(0.5)),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, m) {
                              final i = v.toInt();
                              if (i >= dados.length) {
                                return const SizedBox.shrink();
                              }
                              final nome = dados[i].nome;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  nome.length > 6
                                      ? nome.substring(0, 6)
                                      : nome,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: scheme.onSurface
                                          .withOpacity(0.6)),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Gráfico de Pizza ───────────────────────────────────────────
        if (dados.length > 1)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: scheme.outlineVariant.withOpacity(0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribuição dos Lucros',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (e, r) {
                                setState(() {
                                  if (!e.isInterestedForInteractions ||
                                      r == null ||
                                      r.touchedSection == null) {
                                    _touchedIndex = -1;
                                  } else {
                                    _touchedIndex = r
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  }
                                });
                              },
                            ),
                            sectionsSpace: 2,
                            centerSpaceRadius: 36,
                            sections: dados.asMap().entries.map((e) {
                              final isTouched = e.key == _touchedIndex;
                              final total = dados.fold(
                                  0.0,
                                  (s, p) =>
                                      s + (p.lucro > 0 ? p.lucro : 0));
                              final lucro =
                                  e.value.lucro > 0 ? e.value.lucro : 0;
                              return PieChartSectionData(
                                value: lucro.toDouble(),
                                color: coresPizza[
                                    e.key % coresPizza.length],
                                radius: isTouched ? 62 : 50,
                                title: total > 0
                                    ? '${(lucro / total * 100).toStringAsFixed(0)}%'
                                    : '',
                                titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: dados.asMap().entries.map((e) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: coresPizza[
                                          e.key % coresPizza.length],
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.value.nome,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: scheme.onSurface
                                              .withOpacity(0.8)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
