// lib/models/produto.dart
import 'package:hive/hive.dart';

part 'produto.g.dart';

@HiveType(typeId: 0)
class Produto extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nome;

  @HiveField(2)
  late double valorCompra;

  @HiveField(3)
  late double valorVenda;

  @HiveField(4)
  late double lucro;

  @HiveField(5)
  late DateTime dataCadastro;

  Produto({
    required this.id,
    required this.nome,
    required this.valorCompra,
    required this.valorVenda,
    required this.dataCadastro,
  }) : lucro = valorVenda - valorCompra;

  /// Recalcula o lucro com base nos valores atuais
  void recalcularLucro() {
    lucro = valorVenda - valorCompra;
  }

  /// Retorna string formatada do mês/ano para agrupamento no calendário
  String get mesAno {
    return '${dataCadastro.year}-${dataCadastro.month.toString().padLeft(2, '0')}';
  }
}
