import 'dart:async';
import 'kendaraan.dart';

class ParkirPenuh implements Exception {
  final String pesan;
  ParkirPenuh([this.pesan = 'Parkiran penuh']);
  @override
  String toString() => 'Ditolak: $pesan';
}

class ParkirGagal implements Exception {
  final String pesan;
  ParkirGagal(this.pesan);
  @override
  String toString() => 'Ditolak: $pesan';
}

class Parkiran {
  final int kapasitas;
  final Duration jedaPalang;
  final List<Kendaraan> _terparkir = [];
  final StreamController<String> _kejadian = StreamController<String>.broadcast();
  int _pendapatan = 0;
  // Antrian internal menjaga urutan transaksi dan mencegah kapasitas terlampaui
  // ketika beberapa pemanggilan Future dilakukan hampir bersamaan.
  Future<void> _antrian = Future<void>.value();

  Parkiran(this.kapasitas,
      {this.jedaPalang = const Duration(milliseconds: 200)}) {
    if (kapasitas <= 0) throw ArgumentError('Kapasitas harus positif');
  }

  Stream<String> get kejadian => _kejadian.stream;
  int get sisa => kapasitas - _terparkir.length;
  int get pendapatan => _pendapatan;
  List<Kendaraan> get kendaraanAktif => List.unmodifiable(_terparkir);

  Future<T> _berurutan<T>(Future<T> Function() operasi) {
    final hasil = _antrian.then((_) => operasi());
    _antrian = hasil.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return hasil;
  }

  Future<void> masuk(Kendaraan kendaraan, {DateTime? waktu}) =>
      _berurutan(() async {
        await Future<void>.delayed(jedaPalang);
        if (sisa == 0) throw ParkirPenuh();
        if (_terparkir.any((k) => k.plat == kendaraan.plat)) {
          throw ParkirGagal('plat ${kendaraan.plat} sudah terparkir');
        }
        if (kendaraan.waktuMasuk != null) {
          throw ParkirGagal('objek kendaraan sudah memiliki waktu masuk');
        }
        kendaraan.catatMasuk(waktu ?? DateTime.now());
        _terparkir.add(kendaraan);
        _kejadian.add('MASUK ${kendaraan.jenis} ${kendaraan.plat} (sisa $sisa)');
      });

  Future<int> keluar(String plat, {DateTime? waktu}) =>
      _berurutan(() async {
        await Future<void>.delayed(jedaPalang);
        final indeks = _terparkir.indexWhere((k) => k.plat == plat);
        if (indeks == -1) throw ParkirGagal('plat $plat tidak ditemukan');
        final kendaraan = _terparkir[indeks];
        final tarif = kendaraan.biaya(waktu ?? DateTime.now());
        _terparkir.removeAt(indeks);
        kendaraan.catatKeluar();
        _pendapatan += tarif;
        _kejadian.add('KELUAR ${kendaraan.jenis} ${kendaraan.plat} bayar Rp$tarif');
        return tarif;
      });

  Future<void> tutup() async {
    await _antrian;
    await _kejadian.close();
  }
}
