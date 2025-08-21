import '../../../../model/network/response/inventory_response.dart';

class DraftTicket {
  final List<ItemHistoryInventoryResponseData> historyList;
  final List<ListItemInventoryResponseData> inventoryList;
  final DateTime lastModified;
  int autoIncrementSttRec0;

  DraftTicket({
    required this.historyList,
    required this.inventoryList,
    required this.lastModified,
    required this.autoIncrementSttRec0,
  });

  DraftTicket copyWith({
    List<ItemHistoryInventoryResponseData>? historyList,
    List<ListItemInventoryResponseData>? inventoryList,
    DateTime? lastModified,
    int? autoIncrementSttRec0,
  }) {
    return DraftTicket(
      historyList: historyList ?? this.historyList,
      inventoryList: inventoryList ?? this.inventoryList,
      lastModified: lastModified ?? this.lastModified,
      autoIncrementSttRec0: autoIncrementSttRec0 ?? this.autoIncrementSttRec0,
    );
  }

  Map<String, dynamic> toJson() => {
    'historyList': historyList.map((e) => e.toJson()).toList(),
    'inventoryList': inventoryList.map((e) => e.toJson()).toList(),
    'lastModified': lastModified.toIso8601String(),
    'autoIncrementSttRec0': autoIncrementSttRec0,
  };

  factory DraftTicket.fromJson(Map<String, dynamic> json) => DraftTicket(
    historyList: (json['historyList'] as List)
        .map((e) => ItemHistoryInventoryResponseData.fromJson(e))
        .toList(),
    inventoryList: (json['inventoryList'] as List)
        .map((e) => ListItemInventoryResponseData.fromJson(e))
        .toList(),
    lastModified: DateTime.parse(json['lastModified']),
    autoIncrementSttRec0: json['autoIncrementSttRec0'] ?? 1,
  );
}
