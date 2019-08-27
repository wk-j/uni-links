main() {
  var url = "https://localhost/auth?code=dd964b45a20e118160ca";
  var code = url.substring(url.indexOf(RegExp("code=")) + 5);
  print(code);
}
