import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

var auth = "https://github.com/login/oauth/authorize";
var tokenUrl = "https://github.com/login/oauth/access_token";
var user = "https://api.github.com/user";
var clientId = "9f18bf43ed3bce16e685";
var secret = "78331982064908b8a16725e44843e23481fbae46";
var redirectUrl = "https://localhost/auth";

class Foo extends StatefulWidget {
  @override
  State createState() => new _FooState();
}

class _FooState extends State<Foo> {
  AuthorizationCodeGrant _grant;
  StreamSubscription _subs;

  @override
  void initState() {
    _grant = new AuthorizationCodeGrant(
      clientId,
      Uri.parse(auth),
      Uri.parse(tokenUrl),
      secret: secret,
    );

    _initDeepLinkListener();
  }

  void _initDeepLinkListener() async {
    _subs = getLinksStream().listen((String link) {
      _checkDeepLink(link);
    }, cancelOnError: true);
  }

  void _checkDeepLink(String link) {
    debugPrint("--- link -- $link");

    if (link.contains("code=")) {
      var uri = Uri.parse(link);
      _grant.handleAuthorizationResponse(uri.queryParameters).then((client) {
        var token = client.credentials.accessToken;
        debugPrint("--- token -- $token");
      });
    }
  }

  void _onClick() {
    var url = Uri.parse(redirectUrl);
    var oauthUrl = _grant.getAuthorizationUrl(url);
    debugPrint("ouath-url - $oauthUrl");
    launch(
      oauthUrl.toString(),
      forceSafariVC: false,
      forceWebView: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: RaisedButton(
          onPressed: () {
            _onClick();
          },
          child: Text(
            "Login",
          ),
        ),
      ),
    );
  }
}
