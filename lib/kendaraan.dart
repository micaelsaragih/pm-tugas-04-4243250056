abstract class Kendaraan {
  final String plat;
  DateTime? _waktuMasuk;

  Kendaraan(this.plat);

  String get jenis;
  int get tarifPerJam;
  DateTime? get waktuMasuk => _waktuMasuk;

  void catatMasuk(DateTime waktu) {
    if (_waktuMasuk != null) throw StateError('Kendaraan sudah masuk');
    _waktuMasuk = waktu;
  }

  void catatKeluar() => _waktuMasuk = null;

  int biaya(DateTime keluar) {
    final masuk = _waktuMasuk;
    if (masuk == null) throw StateError('Kendaraan belum masuk parkiran');
    if (keluar.isBefore(masuk)) {
      throw ArgumentError('Waktu keluar tidak boleh sebelum waktu masuk');
    }
    final menit = keluar.difference(masuk).inMinutes;
    final jam = (menit / 60).ceil();
    return (jam < 1 ? 1 : jam) * tarifPerJam;
  }
}

class Motor extends Kendaraan {
  Motor(super.plat);
  @override
  String get jenis => 'Motor';
  @override
  int get tarifPerJam => 2000;
}

class Mobil extends Kendaraan {
  Mobil(super.plat);
  @override
  String get jenis => 'Mobil';
  @override
  int get tarifPerJam => 5000;
}

class Truk extends Kendaraan {
  Truk(super.plat);
  @override
  String get jenis => 'Truk';
  @override
  int get tarifPerJam => 8000;
}

mixin Berlangganan on Kendaraan {
  @override
  int biaya(DateTime keluar) => (super.biaya(keluar) / 2).ceil();
}

class MobilMember extends Mobil with Berlangganan {
  MobilMember(super.plat);
  @override
  String get jenis => 'Mobil (member)';
}
