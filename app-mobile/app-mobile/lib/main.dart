import 'package:flutter/material.dart';

import 'package:flash_splash/app.dart';
import 'package:flash_splash/core/api/api_client.dart';

void main() {
  APIClient.aoSessaoExpirar = voltarAoLogin;
  runApp(const FlashSplashApp());
}
