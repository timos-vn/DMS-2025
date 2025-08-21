
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/response/get_item_holder_detail_response.dart';
import '../../../model/network/response/manager_customer_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/debouncer.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../detail_info_customer/detail_customer_screen.dart';
import 'search_customer_state.dart';
import 'search_customer_event.dart';
import 'search_customer_bloc.dart';

class SearchCustomerScreen extends StatefulWidget {
  final bool? selected;
  final bool? typeName;
  final bool allowCustomerSearch;
  final bool inputQuantity;
  final ListItemHolderDetailResponse? itemHolderDetail;
  final int? indexItemHolder;
  final double? quantityTotalItemHolder;
  final bool? isCreateItemHolder;

  const SearchCustomerScreen({Key? key,this.itemHolderDetail,this.isCreateItemHolder,
    this.quantityTotalItemHolder,this.indexItemHolder ,this.selected,this.typeName,
    required this.allowCustomerSearch, required this.inputQuantity}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchCustomerScreenState();
  }
}

class SearchCustomerScreenState extends State<SearchCustomerScreen> {

  final focusNode = FocusNode();
  final _searchController = TextEditingController();
  late SearchCustomerBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));
  late List<ManagerCustomerResponseData> _dataListSearch;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = SearchCustomerBloc(context);
    _bloc.add(GetPrefs());

    Future.delayed(const Duration(seconds: 3));
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(SearchCustomer(Utils.convertKeySearch(_searchController.text), widget.typeName,isLoadMore: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: white,
      body: BlocListener<SearchCustomerBloc, SearchCustomerState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is GetPrefsSuccess){
              _bloc.allowCustomerSearch = widget.allowCustomerSearch;
              _bloc.add(SearchCustomer(Utils.convertKeySearch(_searchController.text), widget.typeName));
            }
              //Utils.showErrorSnackBar(context, state.message);
            if (state is SearchSuccess) {
              print('load');
            }
          },
          child: BlocBuilder<SearchCustomerBloc, SearchCustomerState>(
              bloc: _bloc,
              builder: (BuildContext context, SearchCustomerState state) {
                return Stack(
                  children: [
                    buildBody(context, state),
                    Visibility(
                      visible: state is EmptySearchState,
                      child: const Center(
                        child: Text('Úi, Không có gì ở đây cả !!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                      ),
                    ),
                    Visibility(
                      visible: state is SearchLoading,
                      child: const PendingAction(),
                    ),
                  ],
                );
              })),
    );
  }

  buildBody(BuildContext context,SearchCustomerState state){
    _dataListSearch = _bloc.searchResults;
    int length = _dataListSearch.length;
    if (state is SearchSuccess) {
      _hasReachedMax = length < _bloc.currentPage * 20;
    } else {
      _hasReachedMax = false;
    }
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white.withOpacity(.09),
      child: Column(
        children: [
          buildAppBar(),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: const Divider(
                    height: 0.5,
                  ),
                );
              },
              shrinkWrap: true,
              itemCount: length == 0
                  ? length
                  : _hasReachedMax ? length : length + 1,
              itemBuilder: (context, index) {
                return index >= length
                    ? Container(
                  height: 100.0,
                  color: white,
                  // child: PendingAction(),
                )
                    :
                GestureDetector(
                  onTap: (){
                    if(widget.inputQuantity == true){
                      showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return InputQuantityShipping(
                              title: 'Vui lòng nhập số lượng',
                              desc: 'Số lượng giữ theo Khách hàng',
                              isCreateItemHolder: widget.isCreateItemHolder
                            );
                          }).then((values){
                        if(values != null){
                          double countQuantity = 0;
                          DataLocal.listItemHolderCreate[widget.indexItemHolder??0].listCustomer?.forEach((element) {
                            countQuantity += element.soLuong??0;
                          });
                          if(double.parse(values[0]??'0') <= (widget.quantityTotalItemHolder??0) - countQuantity){
                            ListCustomerItemHolderDetailResponse item = ListCustomerItemHolderDetailResponse(
                                sttRec: '',
                                sttRec0: '',
                                maDVCS: values[1],
                                tenDVCS: values[2],
                                maKh: _dataListSearch[index].customerCode.toString().trim(),
                                tenVt: widget.itemHolderDetail!.tenVt.toString().trim(),
                                maVt: widget.itemHolderDetail!.maVt.toString().trim(),
                                tenKh: _dataListSearch[index].customerName.toString().trim(),
                                dvt: widget.itemHolderDetail!.dvt.toString().trim(),
                                tenDvt: widget.itemHolderDetail!.tenVt.toString().trim(),
                                soLuong: double.parse( values[0]??'0')
                            );
                            DataLocal.listItemHolderCreate[widget.indexItemHolder??0].listCustomer?.add(item);
                            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật khách hàng thành công');
                          }else{
                            Utils.showCustomToast(context, Icons.check_circle_outline, 'Số lượng cho phép ${(widget.quantityTotalItemHolder??0) - countQuantity}');
                          }

                        }
                      });
                    }
                    else{
                      if(widget.selected == true){
                        Navigator.pop(context,_dataListSearch[index]);
                      }else{
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> DetailInfoCustomerScreen(idCustomer: _dataListSearch[index].customerCode,)));
                      }
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8,right: 8,top: 16,bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            height: 50,
                            width: 50,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(img),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_dataListSearch[index].customerName}',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontWeight: FontWeight.bold,color: blue),
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,size: 12,color: grey,),
                                    const SizedBox(width: 4,),
                                    Expanded(
                                      child: Text(
                                        '${_dataListSearch[index].address}',
                                        style: const TextStyle(fontSize: 12,color: grey,),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,size: 12,color: grey,),
                                    const SizedBox(width: 4,),
                                    Text(
                                      '${_dataListSearch[index].phone}',
                                      style: const TextStyle(fontSize: 12,color: grey,),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 5,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.pop(context),
            child: Container(
              width: 40,
              height: 50,
              padding: const EdgeInsets.only(bottom: 10),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius:
                  const BorderRadius.all(Radius.circular(20))),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: Center(
                        child: TextField(
                          autofocus: true,
                          textAlign: TextAlign.left,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          focusNode: focusNode,
                          onSubmitted: (text) {
                           // _bloc.add(SearchCustomer(text));
                          },
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onChanged: (text){
                            if(text.isNotEmpty){
                              onSearchDebounce.debounce(
                                      ()=> _bloc.add(SearchCustomer(Utils.convertKeySearch(text),widget.typeName)));
                            }
                            _bloc.add(CheckShowCloseEvent(text));
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: transparent,
                            hintText: 'Tìm kiếm khách hàng',
                            hintStyle: TextStyle(color: Colors.white),
                              contentPadding: EdgeInsets.only(
                                  bottom: 10, top: 15)
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _bloc.isShowCancelButton,
                    child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(left: 0,top:0,right: 8,bottom: 0),
                          child: Icon(
                            MdiIcons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onTap: () {
                          _searchController.text = "";
                          _bloc.add(CheckShowCloseEvent(""));
                        }),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc.reset();
    super.dispose();
  }
}
