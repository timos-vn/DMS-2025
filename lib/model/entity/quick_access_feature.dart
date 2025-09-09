import 'package:flutter/material.dart';

class QuickAccessFeature {
  final String id;
  final String title;
  final IconData icon;
  final String route;
  final bool isEnabled;
  final int order;
  final Map<String, dynamic>? parameters;

  const QuickAccessFeature({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    this.isEnabled = true,
    this.order = 0,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCode': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
      'route': route,
      'isEnabled': isEnabled,
      'order': order,
      'parameters': parameters,
    };
  }

  factory QuickAccessFeature.fromJson(Map<String, dynamic> json) {
    return QuickAccessFeature(
      id: json['id'],
      title: json['title'],
      icon: _getIconDataFromJson(json),
      route: json['route'],
      isEnabled: json['isEnabled'] ?? true,
      order: json['order'] ?? 0,
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
    // Additional icons for better coverage
    0xe3fc: Icons.inventory,
    0xe3fd: Icons.inventory_2,
    0xe3fe: Icons.point_of_sale,
    0xe3ff: Icons.local_shipping,
    0xe400: Icons.delivery_dining,
    0xe401: Icons.assignment_return,
    0xe402: Icons.description,
    0xe403: Icons.people,
    0xe404: Icons.app_registration,
    0xe405: Icons.event_busy,
    0xe406: Icons.schedule,
  };

  static IconData _getIconData(int codePoint) {
    return _iconMap[codePoint] ?? Icons.help_outline;
  }

  static IconData _getIconDataFromJson(Map<String, dynamic> json) {
    final codePoint = json['iconCode'] as int?;
    final fontFamily = json['fontFamily'] as String?;
    final fontPackage = json['fontPackage'] as String?;
    
    if (codePoint == null) {
      return Icons.help_outline;
    }
    
    // Try to get from predefined map first
    if (_iconMap.containsKey(codePoint)) {
      return _iconMap[codePoint]!;
    }
    
    // Create IconData with the saved properties
    return IconData(
      codePoint,
      fontFamily: fontFamily,
      fontPackage: fontPackage,
    );
  }

  QuickAccessFeature copyWith({
    String? id,
    String? title,
    IconData? icon,
    String? route,
    bool? isEnabled,
    int? order,
    Map<String, dynamic>? parameters,
  }) {
    return QuickAccessFeature(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
      parameters: parameters ?? this.parameters,
    );
  }
}

