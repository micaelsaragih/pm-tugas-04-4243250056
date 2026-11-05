import 'package:pm_tugas_04_4243250056/kendaraan.dart';
import 'package:pm_tugas_04_4243250056/parkiran.dart';

Future<void> main() async {
  print('Sistem Parkir Kampus FMIPA — Micael Zecsen Saragih (4243250056)');
  final parkiran = Parkiran(3);
  final listener = parkiran.kejadian.listen(print);
  final waktuMasuk = DateTime(2026, 11, 1, 8);
  final waktuKeluar = DateTime(2026, 11, 1, 10, 30);

  // List<Kendaraan> menunjukkan polimorfisme berbagai subclass.
  final List<Kendaraan> kendaraan = [
    Motor('BK 1234 AB'),
    Mobil('BK 88 UN'),
    MobilMember('BK 7 MIPA'),
  ];

  for (final item in kendaraan) {
    await parkiran.masuk(item, waktu: waktuMasuk);
  }

  try {
    await parkiran.masuk(Truk('BK 100 TR'));
  } on ParkirPenuh catch (e) {
    print(e);
  }

  for (final item in kendaraan) {
    await parkiran.keluar(item.plat, waktu: waktuKeluar);
  }
  print('Pendapatan: Rp${parkiran.pendapatan}');
  print('Sisa slot: ${parkiran.sisa}');
  await parkiran.tutup();
  await listener.cancel();
}
