import 'package:dms/screen/personnel/proposal/proposal_bloc.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/debouncer.dart';


class LookUpDynamicFormScreen extends StatefulWidget {
  final String title;
  final String controller;
  final bool? chooseValues;
  const LookUpDynamicFormScreen({key, required this.title, required this.controller, this.chooseValues});

  @override
  State<LookUpDynamicFormScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<LookUpDynamicFormScreen> {
  late ProposalBloc _bloc;
  int lastPage=0;
  int selectedPage=1;
  final TextEditingController _searchController = TextEditingController();
  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));
  List<Map<String, dynamic>> result = [];

  @override
  void initState() {
    super.initState();
    _bloc = ProposalBloc(context);
    _bloc.add(GetPrefsProposal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProposalBloc, ProposalState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is ProposalFailure) {
            Utils.showCustomToast(
                context, Icons.check_circle_outline, state.error.toString());
          }
          else if(state is GetPrefsSuccess){
            _bloc.add(GetLookUpFormDynamicEvent(controller: widget.controller, pageIndex: selectedPage,listRequestDetail: result));
          }
        },
        child: BlocBuilder<ProposalBloc, ProposalState>(
          bloc: _bloc,
          builder: (BuildContext context, ProposalState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListProposalEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is ProposalLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      )
    );
  }

  void generateFilterList(String inputValue) {
    final generatedList = _bloc.listFieldsLookup.map((field) {
      return {
        "variable": field["name"],
        "type": field["type"],
        "value": inputValue,
      };
    }).toList();
      result = generatedList;
    _bloc.add(GetLookUpFormDynamicEvent(controller: widget.controller, pageIndex: selectedPage,listRequestDetail: result));
  }

  buildBody(BuildContext context, ProposalState state) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          buildAppBar(),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
            decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                border: Border.all(color: Colors.green),
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
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      controller: _searchController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: transparent,
                          hintText: "Tìm kiếm ....",
                          hintStyle: const TextStyle(color: accent,fontSize: 12.5),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(right: 40),
                            child: Icon(EneftyIcons.search_normal_outline,size: 15,color: Colors.grey),
                          ),
                          prefixIconConstraints: const BoxConstraints(maxWidth: 20),
                          contentPadding: const EdgeInsets.only(left: 14,bottom: 15, top: 0,right: 12)
                      ),
                      onChanged: (text){
                        onSearchDebounce.debounce(
                              () {
                                generateFilterList(text);
                            // _bloc.add(GetListEvent(searchType: widget.searchType,pageIndex: pageIndex,keySearch: text,
                            //     chooseOneItemPartAndRemoveItemExit: widget.chooseOneItemPartAndRemoveItemExit??false,
                            //     poId: widget.poId.toString(),fabricFrom: widget.fabricFrom,fabricId: widget.fabricId,partId: widget.partId,typeUnit: widget.typeUnit,listUnitSelection: widget.listUnitSelection));
                          },
                        );
                        // _bloc.add(CheckShowCloseEvent(text));
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
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                      onTap: () {
                        _searchController.text = "";
                        // _bloc.add(CheckShowCloseEvent(""));
                      }),
                )
              ],
            ),
          ),
          Expanded(child: buildDynamicListData()),
          _bloc.totalPager > 1 ? _getDataPager() : Container(),
          const SizedBox(height: 5,),
        ],
      ),
    );
  }

  buildDynamicListData(){
    if (_bloc.jsonListLookUpDynamicForm.isEmpty) {
      return Container();
      // return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var fields = _bloc.jsonListLookUpDynamicForm['data']['lookupDefine']['fields'];
    var data = _bloc.jsonListLookUpDynamicForm['data']['lookupData']['data'];

    return ListView.builder(
      itemCount: data.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        var row = data[index];
        return GestureDetector(
          onTap: (){
            if(widget.chooseValues == true){
              String name = ''; String values = '';
              for(var item in fields){
                var value = row[item['name']];
                if(name.isEmpty){
                  name = value;
                }else{
                  values = value;
                }
              }
              Navigator.pop(context,['Yeah',name,values]);
            }else{
              Navigator.pop(context,['Yeah',data,index]);
            }

          },
          child: Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields
                    // .where((field) => !field['hidden'])
                    .map<Widget>((field) {
                  var value = row[field['name']];
                  // Kiểm tra nếu field là DateTime, thì chuyển đổi định dạng
                  if (field['type'] == 'DateTime' && value is String) {
                    DateTime parsedDate = DateTime.parse(value);
                    value = "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}";
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "${field['header']}: $value",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        field['style']?.contains('bold: true') ?? false
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  buildAppBar() {
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
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.check,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
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
                          _bloc.add(GetLookUpFormDynamicEvent(controller: widget.controller, pageIndex: selectedPage,listRequestDetail: result));
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
                            _bloc.add(GetLookUpFormDynamicEvent(pageIndex: selectedPage,controller: widget.controller,listRequestDetail: result));
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
                                _bloc.add(GetLookUpFormDynamicEvent(pageIndex: selectedPage,controller: widget.controller,listRequestDetail: result));
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
                            _bloc.add(GetLookUpFormDynamicEvent(pageIndex: selectedPage,controller: widget.controller,listRequestDetail: result));
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
                          _bloc.add(GetLookUpFormDynamicEvent(pageIndex: selectedPage,controller: widget.controller,listRequestDetail: result));
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
