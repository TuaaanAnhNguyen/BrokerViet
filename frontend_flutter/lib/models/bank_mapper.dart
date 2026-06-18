// lib/models/bank_mapper.dart

import 'package:vietqr_gen/vietqr_generator.dart';

class BankMapper {
  static Bank fromString(String bankCode) {
    switch (bankCode.toLowerCase().trim()) {
      case 'mbbank':
        return Bank.mbBank;
      case 'vcb':
      case 'vietcombank':
        return Bank.vietcombank;
      case 'techcombank':
      case 'tcb':
        return Bank.techcombank;
      case 'icb':
      case 'vietinbank':
        return Bank.vietinbank;
      case 'bidv':
        return Bank.bidv;
      case 'acb':
        return Bank.acb;
      default:
        return Bank.mbBank;
    }
  }
}