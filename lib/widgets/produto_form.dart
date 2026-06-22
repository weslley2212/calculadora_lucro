// lib/widgets/produto_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/produto.dart';
import '../viewmodels/produto_viewmodel.dart';

/// Formulário de cadastro de produto (inline na tela principal).
class ProdutoForm extends StatefulWidget {
  const ProdutoForm({super.key});

  @override
  State<ProdutoForm> createState() => _ProdutoFormState();
}

class _ProdutoFormState extends State<ProdutoForm> {
  final _formKey      = GlobalKey<FormState>();
  final _nomeCtrl     = TextEditingController();
  final _compraCtrl   = TextEditingController();
  final _vendaCtrl    = TextEditingController();
  bool _salvando      = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _compraCtrl.dispose();
    _vendaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final compra = double.parse(_compraCtrl.text.replaceAll(',', '.'));
    final venda  = double.parse(_vendaCtrl.text.replaceAll(',', '.'));

    await context.read<ProdutoViewModel>().adicionarProduto(
          nome: _nomeCtrl.text,
          valorCompra: compra,
          valorVenda: venda,
        );

    _nomeCtrl.clear();
    _compraCtrl.clear();
    _vendaCtrl.clear();
    setState(() => _salvando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Produto adicionado com sucesso!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.primaryContainer),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_box_rounded, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Novo Produto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          )),
                ],
              ),
              const SizedBox(height: 14),

              // Nome
              TextFormField(
                controller: _nomeCtrl,
                decoration: _inputDecor(context, 'Nome do Produto', Icons.label_rounded),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o nome do produto' : null,
              ),
              const SizedBox(height: 10),

              // Compra e Venda lado a lado
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _compraCtrl,
                      decoration: _inputDecor(context, 'Valor de Compra', Icons.arrow_downward_rounded,
                          cor: Colors.orange.shade600),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        final d = double.tryParse(v.replaceAll(',', '.'));
                        if (d == null || d <= 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _vendaCtrl,
                      decoration: _inputDecor(context, 'Valor de Venda', Icons.arrow_upward_rounded,
                          cor: Colors.blue.shade600),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Obrigatório';
                        final d = double.tryParse(v.replaceAll(',', '.'));
                        if (d == null || d <= 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Botão
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add_rounded),
                  label: Text(_salvando ? 'Salvando...' : 'Adicionar Produto'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(BuildContext context, String label, IconData icon, {Color? cor}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 18, color: cor ?? scheme.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}

// ─── Dialog de edição ────────────────────────────────────────────────────────

/// Dialog para editar um produto existente.
class EditarProdutoDialog extends StatefulWidget {
  final Produto produto;

  const EditarProdutoDialog({super.key, required this.produto});

  @override
  State<EditarProdutoDialog> createState() => _EditarProdutoDialogState();
}

class _EditarProdutoDialogState extends State<EditarProdutoDialog> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _compraCtrl;
  late final TextEditingController _vendaCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomeCtrl   = TextEditingController(text: widget.produto.nome);
    _compraCtrl = TextEditingController(
        text: widget.produto.valorCompra.toStringAsFixed(2).replaceAll('.', ','));
    _vendaCtrl  = TextEditingController(
        text: widget.produto.valorVenda.toStringAsFixed(2).replaceAll('.', ','));
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _compraCtrl.dispose();
    _vendaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final compra = double.parse(_compraCtrl.text.replaceAll(',', '.'));
    final venda  = double.parse(_vendaCtrl.text.replaceAll(',', '.'));

    await context.read<ProdutoViewModel>().editarProduto(
          widget.produto,
          nome: _nomeCtrl.text,
          valorCompra: compra,
          valorVenda: venda,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit_rounded),
          SizedBox(width: 8),
          Text('Editar Produto'),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: InputDecoration(
                labelText: 'Nome do Produto',
                prefixIcon: const Icon(Icons.label_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _compraCtrl,
              decoration: InputDecoration(
                labelText: 'Valor de Compra',
                prefixIcon: const Icon(Icons.arrow_downward_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]'))],
              validator: (v) {
                final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                return (d == null || d <= 0) ? 'Valor inválido' : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _vendaCtrl,
              decoration: InputDecoration(
                labelText: 'Valor de Venda',
                prefixIcon: const Icon(Icons.arrow_upward_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]'))],
              validator: (v) {
                final d = double.tryParse((v ?? '').replaceAll(',', '.'));
                return (d == null || d <= 0) ? 'Valor inválido' : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
