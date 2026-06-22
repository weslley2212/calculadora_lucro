// lib/widgets/resumo_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumoCard extends StatelessWidget {
  final String titulo;
  final double valor;
  final IconData icone;
  final Color cor;

  const ResumoCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final moeda  = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icone, color: cor, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(titulo,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          )),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(moeda.format(valor),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
          ],
        ),
      ),
    );
  }
}
