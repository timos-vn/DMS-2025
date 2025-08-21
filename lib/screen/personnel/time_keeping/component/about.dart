// ignore_for_file: library_private_types_in_public_api

import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  final String? phepDaNghi;
  final String? phepConLai;
  final String? userName;
  final String? phoneNumber;
  final String? birthDay;
  final String? dayIn;
  final String? officialDate;
  final String? address;
  final String? workingPosition;
  final String? totalWorking;

  const About({Key? key, this.phepDaNghi, this.phepConLai, this.userName, this.phoneNumber, this.birthDay, this.dayIn, this.officialDate, this.address, this.workingPosition, this.totalWorking}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> with TickerProviderStateMixin<About>{

  bool isExpanded = false;
  @override
  void initState() {

    super.initState();
  }
  double _getFontSize(double size){
   if(MediaQuery.of(context).textScaleFactor < 1){
      return size;
   }
   else{
     return (size / MediaQuery.of(context).textScaleFactor);
   }

  }
  Widget aboutSection() {

    return SingleChildScrollView(
      child: Container(
      padding: const EdgeInsets.only(left: 20, right: 20,bottom: 20,top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10,),
         // _description(),
          Container(
            height: _getFontSize(70),
            margin: EdgeInsets.only(bottom: _getFontSize(10)),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.grey.withOpacity(.2),
                    offset: const Offset(0, 5),
                  )
                ]),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: _getFontSize(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Phép đã nghỉ',
                      style: TextStyle(
                          color: Colors.black87, fontFamily: 'Circular-bold',fontSize: _getFontSize(14)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    customText('${widget.phepDaNghi}',style: TextStyle(fontSize: _getFontSize(14)),)
                  ],
                ),
                const SizedBox(
                  width: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Phép còn lại',
                      style: TextStyle(
                          color: Colors.black87, fontFamily: 'Circular-bold',fontSize: _getFontSize(14)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('${widget.phepConLai}',style: TextStyle(fontSize: _getFontSize(14)),)
                  ],
                ),
              ],
            ),
          ),
          Text('Thông tin cá nhân',style: TextStyle(fontWeight: FontWeight.w600,fontSize: _getFontSize(14)),),
          const SizedBox(height: 10,),
          // _gender(),
          _propertyRow('Họ Tên',"${widget.userName}"),
          _propertyRow('Số điện thoại',"${widget.phoneNumber}"),
          _propertyRow('Ngày sinh',widget.birthDay!.isNotEmpty ? Utils.parseDateTToString(widget.birthDay.toString(), Const.DATE_FORMAT_1) : ''),
          _propertyRow('Ngày vào',widget.dayIn!.isNotEmpty ? Utils.parseDateTToString(widget.dayIn.toString(), Const.DATE_FORMAT_1) : ''),
          _propertyRow('Ngày ký HĐ',widget.officialDate!.isNotEmpty ? Utils.parseDateTToString(widget.officialDate.toString(), Const.DATE_FORMAT_1) : ''),
          _propertyRow('Ví trí',"${widget.workingPosition}"),
          const SizedBox(height: 10,),
          Text('Location',style: TextStyle(fontWeight: FontWeight.w600,fontSize: _getFontSize(14)),),
          const SizedBox(height: 10,),
          _propertyRow('Địa chỉ',"${widget.address}"),
          const SizedBox(height: 10,),
          Container(
            height: _getFontSize(100),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff9AB8AC),
                // image: DecorationImage(
                //     image: customAdvanceNetworkImage(
                //       'https://tr4.cbsistatic.com/hub/i/r/2014/07/09/5ddb5529-bdc9-4656-913d-8cc299ea5e15/resize/1200x/b4fddca0887e8fdbdef49b4515c2844a/staticmapgoogle0514.png',
                //     ),
                //     fit: BoxFit.cover)
            ),
          ),
          const SizedBox(height: 14,),
          Text('Training',style: TextStyle(fontWeight: FontWeight.w600,fontSize: _getFontSize(15)),),
          const SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Text('Base EXP',style: TextStyle(fontSize: _getFontSize(14), color: Colors.black45),),
              const SizedBox(width: 50,),
              customText('02',
                style: TextStyle(fontSize: _getFontSize(14), color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
 
  Widget _description(){

    // if(state.pokemonSpecies == null || state.pokemonSpecies.flavorTextEntries == null || state.pokemonSpecies.flavorTextEntries.length == 0){
    //   return Container();
    // }
    //   var list  = state.pokemonSpecies.flavorTextEntries.where((x)=> x.language.name == 'en').toSet().toList();
    //   list = list.toSet().toList();
    //   list.forEach((x)=> x.flavorText..replaceAll("\n", " "));
      String description = '17890';
      // StringBuffer description = new StringBuffer();
      
      // for(int i= 0; i< list.length ;i++){
      //   var it = list[i].flavorText.replaceAll("\n", " ");
      //   if(!desc.toString().toLowerCase().contains(it.toLowerCase())){
      //     description.write(it + ' ');
      //     desc += it+ ' ';
      //   }
      // }
     
      var wid =  Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
         AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: ConstrainedBox(
              constraints: isExpanded
                  ?  const BoxConstraints()
                  :  const BoxConstraints(maxHeight: 58.0),
              child:  Text(
               description.toString().replaceAll("\n", " "),
                softWrap: true,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: _getFontSize(14),),textAlign: TextAlign.justify,
              ))),
               ElevatedButton(
               child:  Text(!isExpanded ? 'more...' : 'Less...',style: const TextStyle(color: Colors.blue),),
               onPressed: () => setState(() => isExpanded = !isExpanded))
         ]);
    
    return wid;
  }
  Widget _gender(){
    return Row(
            children: <Widget>[
             Expanded(
               child:  Text('Họ Tên',style: TextStyle(fontSize: _getFontSize(14), color: Colors.black45),),
             ),
             Expanded(
               flex: 2,
               child:  Wrap(
                children: <Widget>[
                 Text('Nguyễn Quyết Tiến',style: TextStyle(fontSize: _getFontSize(14), color: Colors.black87),),
                 const SizedBox(width: 10,),
                 Text('-   Female',style: TextStyle(fontSize: _getFontSize(14), color: Colors.black87),),
                ],
              ),
             )
            ],
          );
  }
  Widget _eggGroup(){
     // final state = Provider.of<PokemonState>(context);
    // if(state.pokemonSpecies == null || state.pokemonSpecies.eggGroups == null || state.pokemonSpecies.eggGroups.length == 0){
    //   return Container();
    // }
     var list  = [''];//state.pokemonSpecies.eggGroups;
    return SizedBox(
      width: fullWidth(context),
      child: Row(
        children: <Widget>[
         Expanded(
           flex: 1,
           child: Text('Egg Groups',style: TextStyle(fontSize: _getFontSize(14), color: Colors.black45)),),
         // Expanded(
         //   flex: 2,
         //   child:  Wrap(
         //     children:list.map((x){
         //       return Container(
         //         child:Padding(
         //           padding: EdgeInsets.only(right: 10),
         //           child: customText(x.name,style:  TextStyle(fontSize: _getFontSize(14), color: Colors.black87))
         //         )
         //       );
         //     }).toList(),
         //   ),
         // )
      ],)
    );
  }

  Widget _propertyRow(String title,String value){
   return Padding(
     padding: const EdgeInsets.only(top: 10),
     child:  Row(
              children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(title,style: TextStyle(fontSize: _getFontSize(14), color: Colors.black45)),
              ),
              Expanded(flex: 2,
                child: Text(value,style: TextStyle(fontSize: _getFontSize(14), color: Colors.black87),)
              )
            ],),);
  }

  
  @override
  Widget build(BuildContext context) {
    return   aboutSection();
  }
}
