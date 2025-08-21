import 'dart:math';
import 'package:dms/screen/personnel/personnel_bloc.dart';
import 'package:dms/screen/personnel/personnel_event.dart';
import 'package:dms/screen/personnel/personnel_state.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../themes/colors.dart';
import '../../../utils/debouncer.dart';
import '../../../utils/utils.dart';
import '../../sell/component/history_order.dart';
class SearchEmployeeScreen extends StatefulWidget {
  final int typeView;
  final String userId;
  final String userName;

  const SearchEmployeeScreen({Key? key, required this.userId, required this.userName, required this.typeView}) : super(key: key);

  @override
  _SearchEmployeeScreenState createState() => _SearchEmployeeScreenState();
}

class _SearchEmployeeScreenState extends State<SearchEmployeeScreen> {

  late PersonnelBloc _bloc;
  int lastPage=0;
  int selectedPage=1;
  final focusNode = FocusNode();
  final _searchController = TextEditingController();
  final Debounce onSearchDebounce =  Debounce(delay:  const Duration(milliseconds: 1000));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = PersonnelBloc(context);
    _bloc.listEmployee.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<PersonnelBloc,PersonnelState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is TimeKeepingFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder<PersonnelBloc,PersonnelState>(
          bloc: _bloc,
          builder: (BuildContext context, PersonnelState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is PersonnelLoading,
                  child: const PendingAction(),
                )
              ],
            );

          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,PersonnelState state){
    return Padding(
      padding: const EdgeInsets.only(bottom: 63),
      child: Column(
        children: [
          buildAppBar(),
          const Divider(height: 1,),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                    itemCount: _bloc.listEmployee.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index){
                      return GestureDetector(
                        onTap: (){
                          Navigator.pop(context,[
                            'Yeah',
                            _bloc.listEmployee[index].capQl,
                            _bloc.listEmployee[index].userId,
                            _bloc.listEmployee[index].tenNvbh,
                          ]);
                        },
                        child: Card(
                          semanticContainer: true,
                          margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: 5,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
                                      borderRadius:const BorderRadius.all( Radius.circular(6),)
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding:const EdgeInsets.only(left: 10,right: 3,top: 6,bottom: 5),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quản lý: ${_bloc.listEmployee[index].tenNvql.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6,),
                                        Text(
                                          'Tên nhân viên: ${_bloc.listEmployee[index].tenNvbh.toString().trim()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12,color: Colors.blueGrey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6,),
                                        Text(
                                          'Bộ phận: ${_bloc.listEmployee[index].tenCapql.toString()}',
                                          textAlign: TextAlign.left,
                                          style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 11,color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: _bloc.listEmployee[index].soLuong.toString() != 'null' && _bloc.listEmployee[index].soLuong.toString().isNotEmpty && _bloc.listEmployee[index].soLuong.toString() != '',
                                    child: Text('Tháng ${DateTime.now().month}: ${_bloc.listEmployee[index].soLuong.toString()} đơn',style:const TextStyle(color: Colors.black,fontSize: 12),)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                ),
                Visibility(
                  visible: state is EmptyEmployeeState,
                  child: Center(
                    child: Text('Úi, Có vẻ ${widget.userName.toString().trim()} chưa quản lý thành viên này',style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),textAlign: TextAlign.center,),
                  ),
                ),
              ],
            ),
          ),
          _bloc.totalPager > 1 ? _getDataPager() : Container(),
        ],
      ),
    );
  }

  Widget _getDataPager() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Center(
        child: SizedBox(
          height: 57,
          width: double.infinity,
          child: Column(
            children: [
              const Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16,top: 0),
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
                            _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: widget.userId,keySearch: '',typeAction: 1));
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
                              _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: widget.userId,keySearch: '',typeAction: 1));
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
                                  _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: widget.userId,keySearch: '',typeAction: 1));
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
                              _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: widget.userId,keySearch: '',typeAction: 1));
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
                            _bloc.add(GetListEmployeeEvent(pageIndex: selectedPage,userId: widget.userId,keySearch: '',typeAction: 1));
                          },
                          child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                          style:
                          const TextStyle(fontSize: 14, color: Colors.white),
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
                                      ()=> _bloc.add(GetListEmployeeEvent(
                                          pageIndex: selectedPage,
                                          userId: widget.userId,
                                          keySearch: Utils.convertKeySearch(text),typeAction: widget.typeView)));
                            }
                            _bloc.add(CheckShowCloseEvent(text));
                          },
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: true,
                              fillColor: transparent,
                              hintText: 'Tìm kiếm thành viên',
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
}
