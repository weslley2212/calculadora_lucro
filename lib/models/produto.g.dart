// lib/models/produto.g.dart
// GENERATED CODE - Adaptado manualmente para compatibilidade com FlutLab

part of 'produto.dart';

class ProdutoAdapter extends TypeAdapter<Produto> {
  @override
  final int typeId = 0;

  @override
  Produto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Produto(
      id: fields[0] as String,
      nome: fields[1] as String,
      valorCompra: fields[2] as double,
      valorVenda: fields[3] as double,
      dataCadastro: fields[5] as DateTime,
    )..lucro = fields[4] as double;
  }

  @override
  void write(BinaryWriter writer, Produto obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.valorCompra)
      ..writeByte(3)
      ..write(obj.valorVenda)
      ..writeByte(4)
      ..write(obj.lucro)
      ..writeByte(5)
      ..write(obj.dataCadastro);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdutoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
