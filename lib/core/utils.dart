import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

String getPlainTextFromDeltaJSON(String? deltaJsonString) {
  if (deltaJsonString == null) return 'No description';

  try {
    final deltaList = jsonDecode(deltaJsonString);
    final delta = Delta.fromJson(deltaList);
    final document = quill.Document.fromDelta(delta);
    return document.toPlainText().trim();
  } catch (e) {
    return 'Invalid content';
  }
}

quill.QuillController deltaToController(String? deltaJsonString) {
  if (deltaJsonString == null) {
    return quill.QuillController.basic();
  }
  try {
    final deltaList = jsonDecode(deltaJsonString);
    final delta = Delta.fromJson(deltaList);
    final document = quill.Document.fromDelta(delta);
    return quill.QuillController(
      document: document,
      selection: TextSelection.collapsed(offset: 0),
    );
  } catch (e) {
    return quill.QuillController.basic();
  }
}
