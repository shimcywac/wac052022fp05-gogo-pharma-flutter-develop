import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import '../providers/app_data_provider.dart';

class UriLinkService {
  UriLinkService._privateConstructor();

  static final UriLinkService _instance = UriLinkService._privateConstructor();

  static UriLinkService get instance => _instance;

  Uri? _initialURI;
  Uri? _currentURI;
  StreamSubscription? _streamSubscription;
  bool _initialURILinkHandled = false;
  String path = 'services/uri_link_services';

  Future<void> initURIHandler(BuildContext context, bool mounted) async {
    if (!_initialURILinkHandled) {
      _initialURILinkHandled = true;
      'Invoked _initURIHandler'.log(name: path);
      try {
        final initialURI = await getInitialUri();
        if (initialURI != null) {
          if (!mounted) {
            return;
          }
          _initialURI = initialURI;
          navToProvider(context, _initialURI?.path ?? '');
        } else {
          'Null Initial URI received'.log(name: path);
        }
      } on PlatformException {
        'Failed to receive initial uri'.log(name: path);
      } on FormatException catch (err) {
        if (!mounted) {
          return;
        }
        'Malformed Initial URI received'.log(name: path);
      }
    }
  }

  /// Handle incoming links - the ones that the app will receive from the OS
  /// while already started.
  void incomingLinkHandler(BuildContext context, bool mounted) {
    if (!kIsWeb) {
      _streamSubscription = uriLinkStream.listen((Uri? uri) {
        if (!mounted) {
          return;
        }
        'Received URI: $uri'.log(name: path);
        _currentURI = uri;
        navToProvider(context, _currentURI?.path ?? '');
      }, onError: (Object err) {
        if (!mounted) {
          return;
        }
        'Error occurred: $err'.log(name: path);
        _currentURI = null;
      });
    }
  }

  void navToProvider(BuildContext context, String url) {
    Future.delayed(const Duration(milliseconds: 500)).then((value) => context
        .read<AppDataProvider>()
        .navByDeepLink(context: context, url: url));
  }

  void dispose() {
    _streamSubscription?.cancel();
  }
}
