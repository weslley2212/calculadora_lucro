// lib/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/produto.dart';

/// Serviço responsável por toda interação com o banco de dados local Hive.
class HiveService {
  static const String _boxName = 'produtos';
  late Box<Produto> _box;

  /// Inicializa o Hive e abre a box de produtos.
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ProdutoAdapter());
    _box = await Hive.openBox<Produto>(_boxName);
  }

  /// Retorna todos os produtos salvos.
  List<Produto> getTodos() {
    return _box.values.toList();
  }

  /// Salva um novo produto.
  Future<void> salvar(Produto produto) async {
    await _box.put(produto.id, produto);
  }

  /// Atualiza um produto existente.
  Future<void> atualizar(Produto produto) async {
    produto.recalcularLucro();
    await produto.save();
  }

  /// Exclui um produto pelo ID.
  Future<void> excluir(String id) async {
    await _box.delete(id);
  }

  /// Fecha a box ao encerrar o app.
  Future<void> fechar() async {
    await _box.close();
  }
}
