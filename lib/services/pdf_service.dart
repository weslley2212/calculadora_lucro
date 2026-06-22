// lib/services/pdf_service.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/produto.dart';

/// Serviço responsável pela geração e compartilhamento do relatório PDF.
class PdfService {
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy HH:mm');
  final _dataCurta = DateFormat('dd/MM/yyyy');

  Future<void> gerarECompartilhar(List<Produto> produtos) async {
    final pdf = pw.Document();

    // Totais
    final totalInvestido = produtos.fold(0.0, (s, p) => s + p.valorCompra);
    final totalVendido = produtos.fold(0.0, (s, p) => s + p.valorVenda);
    final lucroTotal = produtos.fold(0.0, (s, p) => s + p.lucro);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Calculadora de Lucro',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800,
                  ),
                ),
                pw.Text(
                  'Relatório Gerado: ${_data.format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.indigo300, thickness: 2),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (context) => [
          // Resumo financeiro
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.indigo50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.indigo200),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildResumoItem('Total Investido', _moeda.format(totalInvestido), PdfColors.orange700),
                _buildResumoItem('Total Vendido', _moeda.format(totalVendido), PdfColors.blue700),
                _buildResumoItem('Lucro Total', _moeda.format(lucroTotal), PdfColors.green700),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Título da tabela
          pw.Text(
            'Lista de Produtos (${produtos.length} itens)',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo800),
          ),
          pw.SizedBox(height: 10),

          // Tabela de produtos
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              // Cabeçalho
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.indigo700),
                children: [
                  _cellHeader('Produto'),
                  _cellHeader('Data'),
                  _cellHeader('Compra'),
                  _cellHeader('Venda'),
                  _cellHeader('Lucro'),
                ],
              ),
              // Linhas
              ...produtos.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: [
                    _cell(p.nome),
                    _cell(_dataCurta.format(p.dataCadastro)),
                    _cell(_moeda.format(p.valorCompra)),
                    _cell(_moeda.format(p.valorVenda)),
                    _cell(
                      _moeda.format(p.lucro),
                      color: p.lucro >= 0 ? PdfColors.green700 : PdfColors.red700,
                      bold: true,
                    ),
                  ],
                );
              }),
              // Totais
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.indigo100),
                children: [
                  _cell('TOTAIS', bold: true),
                  _cell(''),
                  _cell(_moeda.format(totalInvestido), bold: true),
                  _cell(_moeda.format(totalVendido), bold: true),
                  _cell(_moeda.format(lucroTotal), bold: true, color: PdfColors.green800),
                ],
              ),
            ],
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}  •  Calculadora de Lucro',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'relatorio_lucro_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
    );
  }

  pw.Widget _buildResumoItem(String label, String valor, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(valor, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }

  pw.Widget _cellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
      ),
    );
  }

  pw.Widget _cell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }
}
