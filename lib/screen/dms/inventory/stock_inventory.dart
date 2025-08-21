import 'package:flutter/material.dart';

import '../../../model/network/response/inventory_response.dart';

class WarehousePicker extends StatefulWidget {
  final List<ListsStockInventoryResponseData> warehouses;
  final void Function(ListsStockInventoryResponseData) onSelected;

  const WarehousePicker({
    Key? key,
    required this.warehouses,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<WarehousePicker> createState() => _WarehousePickerState();
}

class _WarehousePickerState extends State<WarehousePicker> {
  String searchKey = '';
  late List<ListsStockInventoryResponseData> filteredList;

  @override
  void initState() {
    super.initState();
    filteredList = widget.warehouses;
  }

  void updateFilter(String value) {
    searchKey = value.toLowerCase();
    filteredList = widget.warehouses.where((w) {
      return w.tenKho.toString().trim().toLowerCase().contains(searchKey) ||
          w.maKho.toString().trim().toLowerCase().contains(searchKey);
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Chọn kho',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: updateFilter,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: filteredList.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final w = filteredList[index];
                  return ListTile(
                    title: Text(w.tenKho.toString().trim()),
                    subtitle: Text(w.maKho.toString().trim()),
                    onTap: () {
                      widget.onSelected(w);
                      Navigator.pop(context);
                    },
                  );
                },
              )
                  : const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Không tìm thấy kho nào'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Huỷ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}