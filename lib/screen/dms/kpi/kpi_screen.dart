// ignore_for_file: library_private_types_in_public_api
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'kpi_bloc.dart';
import 'kpi_event.dart';
import 'kpi_state.dart';

class KPIScreen extends StatefulWidget {
  const KPIScreen({Key? key}) : super(key: key);

  @override
  _KPIScreenState createState() => _KPIScreenState();
}

class _KPIScreenState extends State<KPIScreen> {

  late KPIBloc _bloc;

  String dateFrom = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);
  String dateTo = Utils.parseDateToString(DateTime.now(), Const.DATE_SV_FORMAT_2);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = KPIBloc(context);
    _bloc.add(GetPrefsKPIEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<KPIBloc,KPIState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetListKPISummary(dateFrom: dateFrom, dateTo: dateTo));
          }
          else if(state is KPIFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error.toString());
          }
        },
        child: BlocBuilder<KPIBloc,KPIState>(
          bloc: _bloc,
          builder: (BuildContext context, KPIState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is KPILoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,KPIState state){
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          buildAppBar(),
          Expanded(child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10,top: 10,left: 8),
                  child: Text('Kết quả hoạt động trong ngày' ,style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize: 13.5),),
                ),
                Container(
                  height: 80,width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (BuildContext context, int index)=>Container(),
                    itemBuilder: (BuildContext context, int index){
                      return
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Card(
                          semanticContainer: true,
                          margin: const EdgeInsets.only(left: 0,right: 10,top: 5,bottom: 5),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8,right: 6,top: 10,bottom: 10),
                            child: SizedBox(
                              height: 60,width: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _bloc.listKPISummary[index].thucHien.toString().trim(),
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.bold,fontSize: 12.5,color:  Colors.blue),
                                    overflow: TextOverflow.ellipsis,maxLines: 1,
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    _bloc.listKPISummary[index].tenKpi.toString().trim(),
                                    textAlign: TextAlign.left,
                                    style:const TextStyle(fontWeight: FontWeight.normal,fontSize: 12.5,color:  Colors.black),
                                    overflow: TextOverflow.ellipsis,maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _bloc.listKPISummary.length,
                  ),
                ),
              ],
            ),
          ))
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
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: ()=> Navigator.pop(context),
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
          const Expanded(
            child: Center(
              child: Text(
                "Báo cáo KPI",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 10,),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
