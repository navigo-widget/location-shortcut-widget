// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortcut.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationShortcutAdapter extends TypeAdapter<LocationShortcut> {
  @override
  final typeId = 0;

  @override
  LocationShortcut read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationShortcut(
      id: fields[0] as String,
      label: fields[1] as String,
      address: fields[2] as String,
      latitude: (fields[3] as num).toDouble(),
      longitude: (fields[4] as num).toDouble(),
      placeId: fields[5] as String,
      iconName: fields[6] as String,
      sortOrder: (fields[7] as num).toInt(),
      createdAt: fields[8] as DateTime,
      expiresAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationShortcut obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.placeId)
      ..writeByte(6)
      ..write(obj.iconName)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationShortcutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
