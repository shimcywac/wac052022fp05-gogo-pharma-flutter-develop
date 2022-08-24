class DeleteAccountModel {
  DeleteAccount? deleteAccount;

  DeleteAccountModel({this.deleteAccount});

  DeleteAccountModel.fromJson(Map<String, dynamic> json) {
    deleteAccount = json['deleteAccount'] != null
        ? DeleteAccount.fromJson(json['deleteAccount'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> deleteAccount = <String, dynamic>{};
    if (this.deleteAccount != null) {
      deleteAccount['deleteAccount'] = this.deleteAccount!.toJson();
    }
    return deleteAccount;
  }
}

class DeleteAccount {
  bool? deleteCustomer;

  DeleteAccount({this.deleteCustomer});

  DeleteAccount.fromJson(bool json) {
    deleteCustomer = json;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> deleteAccount = <String, dynamic>{};
    deleteAccount['deleteCustomer'] = deleteCustomer;
    return deleteAccount;
  }
}
