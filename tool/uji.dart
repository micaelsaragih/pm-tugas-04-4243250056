import 'package:pm_tugas_04_4243250056/kendaraan.dart';
import 'package:pm_tugas_04_4243250056/parkiran.dart';

Future<void> main() async {
  final waktu = DateTime(2026, 11, 1, 8);
  final motor = Motor('BK 1');
  final mobil = Mobil('BK 2');
  final member = MobilMember('BK 3');
  final truk = Truk('BK 4');
  final parkiran = Parkiran(3, jedaPalang: Duration.zero);
  final log = <String>[];
  final sub = parkiran.kejadian.listen(log.add);

  for (final item in [motor, mobil, member]) {
    await parkiran.masuk(item, waktu: waktu);
  }
  assert(parkiran.sisa == 0);
  var penuh = false;
  try {
    await parkiran.masuk(truk, waktu: waktu);
  } on ParkirPenuh {
    penuh = true;
  }
  assert(penuh);
  assert(await parkiran.keluar('BK 1', waktu: waktu.add(const Duration(hours: 3))) == 6000);
  assert(await parkiran.keluar('BK 2', waktu: waktu.add(const Duration(hours: 3))) == 15000);
  assert(await parkiran.keluar('BK 3', waktu: waktu.add(const Duration(hours: 3))) == 7500);
  assert(parkiran.pendapatan == 28500 && parkiran.sisa == 3);

  await parkiran.masuk(truk, waktu: waktu);
  assert(await parkiran.keluar('BK 4', waktu: waktu) == 8000);
  await parkiran.tutup();
  assert(log.length == 8);
  await sub.cancel();
  print('Pengujian Sistem Parkir Kampus: LULUS (jalankan dengan --enable-asserts)');
}
