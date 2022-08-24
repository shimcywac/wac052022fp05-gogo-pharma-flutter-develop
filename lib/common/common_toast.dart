import 'package:fluttertoast/fluttertoast.dart';

// common toast
void showToast([
  msg,
]) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    fontSize: 14.0,
  );
}
