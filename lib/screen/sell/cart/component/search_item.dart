import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../themes/colors.dart';
import '../../../../utils/debouncer.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';
import '../cart_state.dart';

class SearchItem extends StatefulWidget {
  const SearchItem({Key? key, this.customerID, required this.typeSearch,required this.title, }) : super(key: key);

  final String? customerID;
  final String title;
  final int typeSearch;

  @override
  State<SearchItem> createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {

 

  final TextEditingController _searchController = TextEditingController();
  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));
  int lastPage=0;
  int selectedPage=1;
  late CartBloc _bloc;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = CartBloc(context);
    _bloc.add(GetPrefs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.title.toString()),
        centerTitle: true,
      ),
      body: BlocListener<CartBloc,CartState>(
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch: widget.typeSearch, pageIndex: selectedPage));
          }
        },
        bloc: _bloc,
        child: BlocBuilder<CartBloc,CartState>(
          bloc: _bloc,
          builder: (BuildContext context,CartState state){
            return Stack(
              children: [
                buildBody(context),
                Visibility(
                  visible: state is CartLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context){
    return Column(
      children: [
        Container(
          height: 45,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 5),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              border: Border.all(color: Colors.white),
              borderRadius: const BorderRadius.all(Radius.circular(12))),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: TextField(
                    autofocus: false,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(color: Color(0xFF3B3935), fontSize: 13),
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Nhập tìm kiếm',
                        hintStyle: TextStyle(color:  Color(0xff5c616e),fontSize: 12.5),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 40),
                          child: Icon(EneftyIcons.search_normal_outline,size: 15,color: Colors.grey),
                        ),
                        prefixIconConstraints: BoxConstraints(maxWidth: 20),
                        contentPadding: EdgeInsets.only(left: 14,bottom: 15, top: 0,right: 12)
                    ),
                    onChanged: (text){
                      onSearchDebounce.debounce(
                            () {
                          _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch:widget.typeSearch, pageIndex: selectedPage));
                        },
                      );
                      _bloc.add(CheckShowCloseEvent(text));
                    },
                  ),
                ),
              ),
              Visibility(
                visible: _bloc.isShowCancelButton,
                child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.only(left: 0,top:0,right: 8,bottom: 0),
                      child: Icon(
                        EneftyIcons.close_outline,
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
        const Divider(height: 1,),
        Expanded(
          child: ListView.builder(
              itemCount: _bloc.listItemInOrder.length,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index){
                return GestureDetector(
                    onTap: ()
                    {
                      Navigator.pop(context,[_bloc.listItemInOrder[index].name.toString(),_bloc.listItemInOrder[index].values.toString()]);
                    },
                    child: Card(
                      semanticContainer: true,
                      margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              _bloc.listItemInOrder[index].name.toString().trim(),
                              textAlign: TextAlign.left,
                              style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10,),
                            Text(
                              _bloc.listItemInOrder[index].values.toString().trim(),
                              textAlign: TextAlign.left,
                              style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5,),
                          ],
                        ),
                      ),
                    )
                );
              }
          ),
        ),
        _bloc.totalPager > 1 ? _getDataPager() : Container(),
        const SizedBox(height: 5,),
      ],
    );
  }

  Widget _getDataPager() {
    return Center(
      child: SizedBox(
        height: 57,
        width: double.infinity,
        child: Column(
          children: [
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16,right: 16,bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = 1;
                          });
                          _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch: widget.typeSearch, pageIndex: selectedPage));
                        },
                        child: const Icon(Icons.skip_previous_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage > 1){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage - 1;
                            });
                            _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch: widget.typeSearch, pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_before_outlined,color: Colors.grey,)),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index){
                            return InkWell(
                              onTap: (){
                                setState(() {
                                  lastPage = selectedPage;
                                  selectedPage = index+1;
                                });
                                _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch: widget.typeSearch, pageIndex: selectedPage));
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedPage == (index + 1) ?  mainColor : Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(48))
                                ),
                                child: Center(
                                  child: Text((index + 1).toString(),style: TextStyle(color: selectedPage == (index + 1) ?  Colors.white : Colors.black),),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:(BuildContext context, int index)=> Container(width: 6,),
                          itemCount: _bloc.totalPager > 10 ? 10 : _bloc.totalPager),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          if(selectedPage < _bloc.totalPager){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch: widget.typeSearch, pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                    const SizedBox(width: 10,),
                    InkWell(
                        onTap: (){
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _bloc.totalPager;
                          });
                          _bloc.add(SearchItemInOrderEvent(customerID: widget.customerID.toString(),keySearch: _searchController.text,typeSearch:widget.typeSearch, pageIndex: selectedPage));
                        },
                        child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
