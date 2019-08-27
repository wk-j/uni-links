import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

final auth = "https://github.com/login/oauth/authorize";
final tokenUrl = "https://github.com/login/oauth/access_token";
final user = "https://api.github.com/user";
const String clientId = "9f18bf43ed3bce16e685";
final secret = "78331982064908b8a16725e44843e23481fbae46";
final redirectUrl = "https://localhost/auth";

class GitHubLoginRequest {
  String clientId;
  String clientSecret;
  String code;

  GitHubLoginRequest({this.clientId, this.clientSecret, this.code});

  dynamic toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "code": code,
      };
}

class GitHubLoginResponse {
  String accessToken;
  String tokenType;
  String scope;

  GitHubLoginResponse({this.accessToken, this.tokenType, this.scope});

  factory GitHubLoginResponse.fromJson(Map<String, dynamic> json) =>
      GitHubLoginResponse(
        accessToken: json["access_token"],
        tokenType: json["token_type"],
        scope: json["scope"],
      );
}

/// WIDGET

class Foo extends StatefulWidget {
  @override
  State createState() => new _FooState();
}

// STATE
class _FooState extends State<Foo> {
  StreamSubscription _subs;

  @override
  void initState() {
    _initDeepLinkListener();
    super.initState();
  }

  @override
  void dispose() {
    _disposeDeepLinkListener();
    super.dispose();
  }

  void _disposeDeepLinkListener() {
    if (_subs != null) {
      _subs.cancel();
      _subs = null;
    }
  }

  void _initDeepLinkListener() async {
    _subs = getLinksStream().listen((String link) {
      _checkDeepLink(link);
    }, cancelOnError: true);
  }

  Future<GitHubLoginResponse> loginWithGitHub(String code) async {
    final response = await http.post(
      "https://github.com/login/oauth/access_token",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode(GitHubLoginRequest(
        clientId: clientId,
        clientSecret: secret,
        code: code,
      )),
    );

    GitHubLoginResponse loginResponse =
        GitHubLoginResponse.fromJson(json.decode(response.body));

    return loginResponse;
  }

  void _checkDeepLink(String link) {
    if (link != null) {
      debugPrint("link == $link");
      var code = link.substring(link.indexOf(RegExp("code=")) + 5);
      loginWithGitHub(code).then((github) {
        print("LOGGED IN AS: " + github.accessToken);
      }).catchError((e) {
        print("LOGIN ERROR: " + e.toString());
      });
    }
  }

  void onClickGitHubLoginButton() async {
    const String url = "https://github.com/login/oauth/authorize"
        "?client_id=$clientId"
        "&scope=public_repo%20read:user%20user:email";

    debugPrint("login url == $url");

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      print("CANNOT LAUNCH THIS URL!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: RaisedButton(
          onPressed: () {
            onClickGitHubLoginButton();
          },
          child: Text(
            "Login",
          ),
        ),
      ),
    );
  }
}
