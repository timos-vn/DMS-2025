import 'package:dms/screen/customer/detail_info_customer/detail_customer_screen.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../model/network/response/manager_customer_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/images.dart';
import 'customer_recently_bloc.dart';
import 'customer_recently_event.dart';
import 'customer_recently_sate.dart';

class CustomerRecentlyScreen extends StatefulWidget {
  const CustomerRecentlyScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomerRecentlyScreenState();
  }
}

class _CustomerRecentlyScreenState extends State<CustomerRecentlyScreen> {
  late CustomerRecentlyBloc _bloc;
  late ScrollController _scrollController;
  final _scrollThreshold = 200.0;
  bool _hasReachedMax = true;

  @override
  void initState() {
    _bloc = CustomerRecentlyBloc(context);
    _bloc.add(GetPrefs());
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= _scrollThreshold && !_hasReachedMax && _bloc.isScroll == true) {
        _bloc.add(GetListCustomerRecently(isLoadMore: true));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        body: BlocProvider<CustomerRecentlyBloc>(
          create: (context) => _bloc,
          child: BlocBuilder<CustomerRecentlyBloc, CustomerRecentlyState>(
              bloc: _bloc,
              builder: (BuildContext context, CustomerRecentlyState state,){
                List<ManagerCustomerResponseData> _list = _bloc.list;
                int length = _list.length;
                if (state is CustomerRecentlyFailure){}
                  //Utils.showErrorSnackBar(context, state.error);
                if (state is GetLisCustomerRecentlySuccess){
                  //print('Show noti');
                  _hasReachedMax = length < _bloc.currentPage * 20;
                }
                if(state is GetPrefsSuccess){
                  _bloc.add(GetListCustomerRecently());
                }
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(children: <Widget>[
                    ListView.separated(
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
                          child: const PendingAction(),
                        )
                            :
                        GestureDetector(
                          onTap: ()=> Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context)=> DetailInfoCustomerScreen(idCustomer: _list[index].customerCode.toString().trim(),))),
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
                                          _list[index].customerName.toString(),
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(fontWeight: FontWeight.bold,color: blue),
                                        ),
                                        const SizedBox(height: 10,),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,size: 12,color: grey,),
                                            const SizedBox(width: 4,),
                                            Flexible(
                                              child: Text(
                                                _list[index].address.toString(),
                                                style: const TextStyle(fontSize: 12,color: grey,),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5,),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone,size: 12,color: grey,),
                                            const SizedBox(width: 4,),
                                            Flexible(
                                              child: Text(
                                              _list[index].phone.toString(),
                                              style: const TextStyle(fontSize: 12,color: grey,),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
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
                    Visibility(
                      visible: state is GetLisCustomerRecentlyEmpty,
                      child: const Center(
                        child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                      ),
                    ),
                    Visibility(
                      visible: state is CustomerRecentlyLoading,
                      child: const PendingAction(),
                    )
                  ]),
                );
              }),
        ));
  }
}
