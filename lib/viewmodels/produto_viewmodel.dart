// lib/viewmodels/produto_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/produto.dart';
import '../services/hive_service.dart';

/// Enum para os filtros de ordenação disponíveis.
enum FiltroOrdem { todos, maiorLucro, menorLucro, maisRecente, maisAntigo }

/// ViewModel principal — gerencia estado e lógica de negócio via Provider.
class ProdutoViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  final _uuid = const Uuid();

  ProdutoViewModel(this._hiveService) {
    _carregarProdutos();
  }

  // ─── Estado interno ───────────────────────────────────────────────────────
  List<Produto> _todos = [];
  String _busca = '';
  FiltroOrdem _filtro = FiltroOrdem.todos;
  bool _carregando = false;

  // ─── Getters públicos ─────────────────────────────────────────────────────

  bool get carregando => _carregando;
  FiltroOrdem get filtro => _filtro;
  String get busca => _busca;

  /// Lista filtrada + ordenada para exibição.
  List<Produto> get produtos {
    var lista = _todos.where((p) {
      return p.nome.toLowerCase().contains(_busca.toLowerCase());
    }).toList();

    switch (_filtro) {
      case FiltroOrdem.maiorLucro:
        lista.sort((a, b) => b.lucro.compareTo(a.lucro));
        break;
      case FiltroOrdem.menorLucro:
        lista.sort((a, b) => a.lucro.compareTo(b.lucro));
        break;
      case FiltroOrdem.maisRecente:
        lista.sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
        break;
      case FiltroOrdem.maisAntigo:
        lista.sort((a, b) => a.dataCadastro.compareTo(b.dataCadastro));
        break;
      case FiltroOrdem.todos:
        lista.sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
        break;
    }
    return lista;
  }

  // ─── Totais gerais ────────────────────────────────────────────────────────

  double get totalInvestido => _todos.fold(0.0, (s, p) => s + p.valorCompra);
  double get totalVendido   => _todos.fold(0.0, (s, p) => s + p.valorVenda);
  double get lucroTotal     => _todos.fold(0.0, (s, p) => s + p.lucro);
  int    get totalProdutos  => _todos.length;

  // ─── Dados por mês (para o calendário) ───────────────────────────────────

  /// Retorna todos os meses distintos com registros, ordenados do mais recente.
  List<DateTime> get mesesComRegistros {
    final meses = <String, DateTime>{};
    for (final p in _todos) {
      final key = p.mesAno;
      if (!meses.containsKey(key)) {
        meses[key] = DateTime(p.dataCadastro.year, p.dataCadastro.month);
      }
    }
    final lista = meses.values.toList();
    lista.sort((a, b) => b.compareTo(a));
    return lista;
  }

  /// Retorna produtos de um mês específico.
  List<Produto> produtosDeMes(DateTime mes) {
    return _todos.where((p) =>
      p.dataCadastro.year == mes.year &&
      p.dataCadastro.month == mes.month
    ).toList();
  }

  /// Total investido em um mês.
  double investidoNoMes(DateTime mes) =>
      produtosDeMes(mes).fold(0.0, (s, p) => s + p.valorCompra);

  /// Total vendido em um mês.
  double vendidoNoMes(DateTime mes) =>
      produtosDeMes(mes).fold(0.0, (s, p) => s + p.valorVenda);

  /// Lucro total em um mês.
  double lucroNoMes(DateTime mes) =>
      produtosDeMes(mes).fold(0.0, (s, p) => s + p.lucro);

  /// Dados para gráfico de barras (top 7 produtos por lucro).
  List<Produto> get dadosGraficoBarras {
    final lista = List<Produto>.from(_todos);
    lista.sort((a, b) => b.lucro.compareTo(a.lucro));
    return lista.take(7).toList();
  }

  // ─── Ações ────────────────────────────────────────────────────────────────

  /// Filtra os produtos pelo nome.
  void pesquisar(String texto) {
    _busca = texto;
    notifyListeners();
  }

  /// Altera o filtro de ordenação.
  void alterarFiltro(FiltroOrdem f) {
    _filtro = f;
    notifyListeners();
  }

  /// Adiciona um novo produto.
  Future<void> adicionarProduto({
    required String nome,
    required double valorCompra,
    required double valorVenda,
  }) async {
    final produto = Produto(
      id: _uuid.v4(),
      nome: nome.trim(),
      valorCompra: valorCompra,
      valorVenda: valorVenda,
      dataCadastro: DateTime.now(),
    );
    await _hiveService.salvar(produto);
    _todos.add(produto);
    notifyListeners();
  }

  /// Edita um produto existente.
  Future<void> editarProduto(
    Produto produto, {
    required String nome,
    required double valorCompra,
    required double valorVenda,
  }) async {
    produto.nome = nome.trim();
    produto.valorCompra = valorCompra;
    produto.valorVenda = valorVenda;
    produto.recalcularLucro();
    await _hiveService.atualizar(produto);
    notifyListeners();
  }

  /// Exclui um produto.
  Future<void> excluirProduto(String id) async {
    await _hiveService.excluir(id);
    _todos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ─── Inicialização ────────────────────────────────────────────────────────

  Future<void> _carregarProdutos() async {
    _carregando = true;
    notifyListeners();
    _todos = _hiveService.getTodos();
    _carregando = false;
    notifyListeners();
  }
}
