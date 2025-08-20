import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void handleError(dynamic error) {
  final message = _mapErrorToMessage(error);
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );
}

String _mapErrorToMessage(dynamic error) {
  final parts = error.toString().split(": ");
  return parts.length > 1 ? parts[1] : error.toString();
}

String toTitleCase(String text) {
  var splitText = text.split(' ');
  var capitalizedWords = splitText.map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).toList();

  return capitalizedWords.join(' ');
}

Widget loadingProgress(){
  return const Center(
    child: CircularProgressIndicator(),
  );
}