import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Moves extends StatefulWidget {
  _MovesState createState() => _MovesState();
}

class _MovesState extends State<Moves> with TickerProviderStateMixin<Moves>{
  // PokemonListModel model;
  bool isExpanded = false;
  @override
  void initState() {
    // model = widget.model;
    super.initState();
  }
  Widget _moves() {
     // final state = Provider.of<PokemonState>(context);
     // if(state.pokemonDetail == null || state.pokemonDetail.moves == null || state.pokemonDetail.moves.length == 0){
     //    return Container(child:Center(child:  Text('No information available'),),);
     // }
     // List<Widget> moves = state.pokemonDetail.moves.map((f)=> Container(
     //    margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
     //    padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
     //    decoration: BoxDecoration(
     //      borderRadius: BorderRadius.all(Radius.circular(5)),
     //      color:  setprimaryColor(widget.type).withAlpha(150),
     //      boxShadow: <BoxShadow>[
     //              BoxShadow(blurRadius: 5,offset: Offset(0, 2),color: setprimaryColor(widget.type).withAlpha(150),spreadRadius:0),
     //            ],
     //    ),
     //   child: Text(f.move.name, style: TextStyle(fontSize: getFontSize(context, 15),color: Colors.white,fontWeight: FontWeight.w400),),
     // )).toList();

      return SingleChildScrollView(
        child:  Padding(
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children:[
            Container()
          ]
        )
       ),
      );
 }
  @override
  Widget build(BuildContext context) {
    return   Container();
  }
}
