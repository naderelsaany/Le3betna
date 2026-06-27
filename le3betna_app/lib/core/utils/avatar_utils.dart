import 'package:flutter/material.dart';
import 'dart:convert';

class AvatarUtils {
  static ImageProvider? getImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    
    if (url.startsWith('data:image')) {
      // It's a base64 encoded image
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    } else if (url.startsWith('http')) {
      // It's a normal URL
      return NetworkImage(url);
    }
    
    return null;
  }
}
