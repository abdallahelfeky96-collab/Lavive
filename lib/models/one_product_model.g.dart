// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      status: fields[0] as bool?,
      code: fields[1] as int?,
      msg: fields[2] as String?,
      data: fields[3] as Data?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.status)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.msg)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataAdapter extends TypeAdapter<Data> {
  @override
  final int typeId = 1;

  @override
  Data read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Data(
      title: fields[0] as String?,
      id: fields[10] as int?,
      photo: fields[1] as String?,
      price: fields[2] as String?,
      realPrice: fields[3] as String?,
      rate: fields[4] as int?,
      code: fields[5] as String?,
      amount: fields[6] as int?,
      description: fields[7] as String?,
      subCategory: fields[8] as SubCategory?,
      quantity: fields[9] as double?,
      myTitle: fields[11] as String?,
      myDescription: fields[12] as String?,
      packaging: fields[13] as String?,
      isPackaging: fields[14] as int?,
      unit: fields[15] as Unit?,
    );
  }

  @override
  void write(BinaryWriter writer, Data obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.photo)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.realPrice)
      ..writeByte(4)
      ..write(obj.rate)
      ..writeByte(5)
      ..write(obj.code)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.subCategory)
      ..writeByte(9)
      ..write(obj.quantity)
      ..writeByte(10)
      ..write(obj.id)
      ..writeByte(11)
      ..write(obj.myTitle)
      ..writeByte(12)
      ..write(obj.myDescription)
      ..writeByte(13)
      ..write(obj.packaging)
      ..writeByte(14)
      ..write(obj.isPackaging)
      ..writeByte(15)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubCategoryAdapter extends TypeAdapter<SubCategory> {
  @override
  final int typeId = 2;

  @override
  SubCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubCategory(
      id: fields[0] as int?,
      title: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubCategory obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitAdapter extends TypeAdapter<Unit> {
  @override
  final int typeId = 3;

  @override
  Unit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Unit(
      id: fields[0] as int?,
      title: fields[1] as String?,
      titleEn: fields[2] as String?,
      titleAr: fields[3] as String?,
      myTitle: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Unit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.titleEn)
      ..writeByte(3)
      ..write(obj.titleAr)
      ..writeByte(4)
      ..write(obj.myTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
