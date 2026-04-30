import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/repository/login_repository.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/payments/models/bank_account.dart';
import 'package:smacredit/src/payments/models/currencyModel.dart';
import 'package:smacredit/src/payments/models/default_link.dart';
import 'package:smacredit/src/payments/models/document_type.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/payments/models/payout_model.dart';
import 'package:smacredit/src/payments/models/payout_response.dart';
import 'package:smacredit/src/payments/models/short_link.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';
import 'package:smacredit/src/payments/repository/payments_repository.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class PaymentController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;
  bool loading = false;
  List<CurrencyModel> currencies = [];
  List<PaymentLinkModel> paymentLinks = [];
  List<TransactionModel> transactions = [];
  List<PayoutModel> payouts = [];
  List<DocumentTypeDetail> documentTypes = [];

  ShortLinkModel? shortLinkModel;
  DefaultLinkModel? defaultLinkModel;
  List<BankAccount> banks = [];
  PaymentController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  Future<PaymentLinkModel?> createPaymentLinkWithFile(
    Map map,
    File? files,
  ) async {
    setState(() {
      loading = true;
    });

    try {
      PaymentLinkModel? response = await create_payment_link_with_file(
        map,
        files,
      );

      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<bool?> deletePaymentLink(int id) async {
    setState(() {
      loading = true;
    });

    try {
      bool? response = await delete_payment_link(id);

      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<bool?> uploadDocument(Map map, File files) async {
    setState(() {
      loading = true;
    });

    try {
      bool? response = await upload_document(map, files);
      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<DefaultLinkModel?> makeDefaultLink(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      DefaultLinkModel? response = await make_default_link(map);
      setState(() {
        loading = false;
        defaultLinkModel = response;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<ShortLinkModel?> generateShotLink(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      ShortLinkModel? response = await generate_short_link(map);
      setState(() {
        loading = false;
        shortLinkModel = response;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  Future<ApiResponseModel?> payoutRequest(Map map) async {
    setState(() {
      loading = true;
    });

    try {
      ApiResponseModel? response = await payout_request(map);
      setState(() {
        loading = false;
      });
      return response;
    } catch (e) {
      setState(() {
        loading = false;
      });
      return null;
    }
  }

  void updateAccount(Map map) {
    setState(() {
      loading = true;
    });
    update_account(map).then((value) async {
      if (value != null) {
        currentuser.value.copyWith(user: value);

        setState(() {
          loading = false;
        });

        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "Account updated successfully",
        );

        // Navigator.pop(scaffoldKey.currentContext!);
      } else {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void createBankAccount(Map map) {
    setState(() {
      loading = true;
    });
    create_bank(map).then((value) async {
      if (value != null) {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "Bank account created successfully",
        );

        Navigator.pop(scaffoldKey.currentContext!);
      } else {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void updateBankAccount(Map map) {
    setState(() {
      loading = true;
    });
    update_bank(map).then((value) async {
      if (value != null) {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "Bank account updated successfully",
        );
        // Navigator.pop(scaffoldKey.currentContext!);
        Navigator.pop(scaffoldKey.currentContext!);
      } else {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  void updateProfileBank(Map map) {
    setState(() {
      loading = true;
    });
    update_profile_bank(map).then((value) async {
      if (value != null) {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showSuccessSnakeBar(
          scaffoldKey.currentContext!,
          "Bank account updated successfully",
        );

        // Navigator.pop(scaffoldKey.currentContext!);
      } else {
        setState(() {
          loading = false;
        });

        CustomMessageHandler().showErrorSnakeBar(
          scaffoldKey.currentContext!,
          "Something went wrong.Try again",
        );
      }
    });
  }

  Future<void> listenForCurrencies() async {
    setState(() {
      loading = true;
    });
    currencies.clear();
    final Stream<CurrencyModel> stream = await get_currencies();

    stream.listen(
      (CurrencyModel employerModel) {
        setState(() => currencies.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForPayouts() async {
    setState(() {
      loading = true;
    });
    payouts.clear();
    final Stream<PayoutModel> stream = await get_payouts();

    stream.listen(
      (PayoutModel employerModel) {
        setState(() => payouts.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForDocumentTypes() async {
    setState(() {
      loading = true;
    });
    documentTypes.clear();
    final Stream<DocumentTypeDetail> stream = await get_document_types();

    stream.listen(
      (DocumentTypeDetail employerModel) {
        setState(() => documentTypes.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }
  void getDefaultLink() {
    setState(() {
      loading = true;
    });
    get_default_link({}).then((value) async {
      if (value != null) {
        setState(() {
          defaultLinkModel = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });

      }
    });
  }
  Future<void> listenForBanks() async {
    setState(() {
      loading = true;
    });
    banks.clear();
    final Stream<BankAccount> stream = await get_banks();

    stream.listen(
      (BankAccount employerModel) {
        setState(() => banks.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForPaymentLinks() async {
    setState(() {
      loading = true;
    });
    paymentLinks.clear();
    final Stream<PaymentLinkModel> stream = await get_payment_links();

    stream.listen(
      (PaymentLinkModel employerModel) {
        setState(() => paymentLinks.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        sortListByDateDesc(paymentLinks, (link) => link.createdAt);
        setState(() {
          loading = false;
        });
      },
    );
  }

  Future<void> listenForTransactions() async {
    setState(() {
      loading = true;
    });
    transactions.clear();
    final Stream<TransactionModel> stream = await get_transactions();

    stream.listen(
      (TransactionModel employerModel) {
        setState(() => transactions.add(employerModel));
      },
      onError: (a) {
        setState(() {
          loading = false;
        });
        print(a);
      },
      onDone: () {
        sortListByDateDesc(transactions, (link) => link.createdAt);
        setState(() {
          loading = false;
        });
      },
    );
  }

  void sortListByDateDesc<T>(List<T> list, DateTime Function(T item) getDate) {
    // The sort function requires a comparison function that returns:
    // - A negative integer if the first item should come before the second.
    // - A positive integer if the first item should come after the second.
    // - 0 if they are equal.

    // For DESCENDING order (newest first), we compare the second item's date
    // to the first item's date (itemB.compareTo(itemA)).
    list.sort((itemA, itemB) {
      DateTime dateA = getDate(itemA);
      DateTime dateB = getDate(itemB);

      // Use compareTo for safe DateTime comparison
      return dateB.compareTo(dateA);
    });
  }
}
