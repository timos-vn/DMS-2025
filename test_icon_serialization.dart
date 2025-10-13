// Simple test to verify icon serialization works correctly
// This file can be imported and used for testing

import 'package:flutter/material.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Test data to verify icon serialization
final testIconData = [
  // Material Icons
  Icons.home,
  Icons.search,
  Icons.person,
  Icons.settings,
  
  // Enefty Icons
  EneftyIcons.bag_2_outline,
  EneftyIcons.location_outline,
  EneftyIcons.personalcard_outline,
  EneftyIcons.shop_add_outline,
  
  // MDI Icons
  MdiIcons.history,
  MdiIcons.chartBar,
  MdiIcons.calendarCheckOutline,
  MdiIcons.chartLine,
];

// Function to test icon serialization
void testIconSerialization() {
  print('Testing icon serialization...');
  
  for (final icon in testIconData) {
    print('Icon: ${icon.runtimeType}');
    print('  CodePoint: ${icon.codePoint}');
    print('  FontFamily: ${icon.fontFamily}');
    print('  FontPackage: ${icon.fontPackage}');
    
    // Test JSON serialization
    final json = {
      'iconCode': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'fontPackage': icon.fontPackage,
    };
    
    print('  JSON: $json');
    
    // Test deserialization
    final restoredIcon = IconData(
      json['iconCode'] as int,
      fontFamily: json['fontFamily'] as String?,
      fontPackage: json['fontPackage'] as String?,
    );
    
    print('  Restored CodePoint: ${restoredIcon.codePoint}');
    print('  Restored FontFamily: ${restoredIcon.fontFamily}');
    print('  Restored FontPackage: ${restoredIcon.fontPackage}');
    
    final isPreserved = icon.codePoint == restoredIcon.codePoint &&
                       icon.fontFamily == restoredIcon.fontFamily &&
                       icon.fontPackage == restoredIcon.fontPackage;
    
    print('  Icon preserved: $isPreserved\n');
  }
}
