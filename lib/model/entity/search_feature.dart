import 'package:flutter/material.dart';

class SearchFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final String route;
  final bool isEnabled;
  final Map<String, dynamic>? parameters;

  const SearchFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.route,
    this.isEnabled = true,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCode': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'category': category,
      'route': route,
      'isEnabled': isEnabled,
      'parameters': parameters,
    };
  }

  factory SearchFeature.fromJson(Map<String, dynamic> json) {
    return SearchFeature(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: _getIconDataFromJson(json),
      category: json['category'],
      route: json['route'],
      isEnabled: json['isEnabled'] ?? true,
      parameters: json['parameters'],
    );
  }

  // Predefined map of common Material Icons for tree-shaking
  static const Map<int, IconData> _iconMap = {
    0xe3c9: Icons.home,
    0xe3ca: Icons.search,
    0xe3cb: Icons.person,
    0xe3cc: Icons.settings,
    0xe3cd: Icons.notifications,
    0xe3ce: Icons.menu,
    0xe3cf: Icons.close,
    0xe3d0: Icons.arrow_back,
    0xe3d1: Icons.arrow_forward,
    0xe3d2: Icons.add,
    0xe3d3: Icons.edit,
    0xe3d4: Icons.delete,
    0xe3d5: Icons.favorite,
    0xe3d6: Icons.favorite_border,
    0xe3d7: Icons.star,
    0xe3d8: Icons.star_border,
    0xe3d9: Icons.check,
    0xe3da: Icons.check_circle,
    0xe3db: Icons.error,
    0xe3dc: Icons.warning,
    0xe3dd: Icons.info,
    0xe3de: Icons.help,
    0xe3df: Icons.visibility,
    0xe3e0: Icons.visibility_off,
    0xe3e1: Icons.lock,
    0xe3e2: Icons.lock_open,
    0xe3e3: Icons.email,
    0xe3e4: Icons.phone,
    0xe3e5: Icons.location_on,
    0xe3e6: Icons.calendar_today,
    0xe3e7: Icons.access_time,
    0xe3e8: Icons.camera_alt,
    0xe3e9: Icons.image,
    0xe3ea: Icons.file_download,
    0xe3eb: Icons.file_upload,
    0xe3ec: Icons.print,
    0xe3ed: Icons.share,
    0xe3ee: Icons.copy,
    0xe3ef: Icons.paste,
    0xe3f0: Icons.cut,
    0xe3f1: Icons.undo,
    0xe3f2: Icons.redo,
    0xe3f3: Icons.refresh,
    0xe3f4: Icons.more_vert,
    0xe3f5: Icons.more_horiz,
    0xe3f6: Icons.expand_more,
    0xe3f7: Icons.expand_less,
    0xe3f8: Icons.keyboard_arrow_down,
    0xe3f9: Icons.keyboard_arrow_up,
    0xe3fa: Icons.keyboard_arrow_left,
    0xe3fb: Icons.keyboard_arrow_right,
  };

  static IconData _getIconDataFromJson(Map<String, dynamic> json) {
    final codePoint = json['iconCode'] as int?;
    final fontFamily = json['fontFamily'] as String?;
    final fontPackage = json['fontPackage'] as String?;
    
    if (codePoint == null) {
      return Icons.help_outline;
    }
    
    // Try to get from predefined map first (all icons in map are const)
    if (_iconMap.containsKey(codePoint)) {
      return _iconMap[codePoint]!;
    }
    
    // For icons not in predefined map, return a fallback constant icon
    // This ensures tree-shaking compatibility
    return Icons.help_outline;
  }
}

