// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:dms/widget/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../../animation_widget/animated_button.dart';
import '../../../animation_widget/animation_text_form_field.dart';
import '../../../model/models/info_cpn_data.dart';
import '../../../utils/auth/auth.dart';
import '../../../utils/const.dart';
import '../../../utils/permission_req.dart';
import '../../../utils/utils.dart';
import '../../login/login_screen.dart';
import '../info_cpn_bloc.dart';
import '../info_cpn_event.dart';
import '../info_cpn_state.dart';
import 'expandable_container.dart';

class InfoCPNCard extends StatefulWidget {
  const InfoCPNCard({
    Key? key,
    required this.loadingController,
    this.onSubmitCompleted,
  }) : super(key: key);

  final AnimationController loadingController;
  final Function? onSubmitCompleted;



  @override
  // ignore: library_private_types_in_public_api
  _InfoCPNCardState createState() => _InfoCPNCardState();
}

class _InfoCPNCardState extends State<InfoCPNCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late TextEditingController _companyController;
  late TextEditingController _unitController;
  late TextEditingController _storeController;

  var _isLoading = false;
  var _isSubmitting = false;
  var _showShadow = true;

  /// switch between login and signup
  late AnimationController _switchAuthController;
  late AnimationController _postSwitchAuthController;
  late AnimationController _submitController;

  Interval? _companyTextFieldLoadingAnimationInterval;
  Interval? _unitTextFieldLoadingAnimationInterval;
  Interval? _storeButtonLoadingAnimationInterval;
  late Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;
  late InfoCPNBloc _bloc;

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 1650);

  @override
  void initState() {
    super.initState();
    CheckPermission.getLocation2();
    _bloc = InfoCPNBloc(context);
    _bloc.add(GetPrefsInfoCPN());
    _companyController = TextEditingController(text: 'Company');
    _unitController = TextEditingController(text: 'Unit');
    _storeController = TextEditingController(text: 'Store');

    widget.loadingController.addStatusListener(handleLoadingAnimationStatus);

    _switchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _companyTextFieldLoadingAnimationInterval = const Interval(0, .85);
    _unitTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
    _storeButtonLoadingAnimationInterval =
    const Interval(.6, 1.0, curve: Curves.easeOut);
    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: widget.loadingController,
          curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
        ));
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    widget.loadingController.removeStatusListener(handleLoadingAnimationStatus);
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();
    _submitController.dispose();

    super.dispose();
  }

  void _switchAuthMode() {
    final auth = Provider.of<Auth>(context, listen: false);
    final newAuthMode = auth.switchAuth();

    if (newAuthMode == AuthMode.showStore) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  Future<bool> _submit() async {
    // a hack to force unfocus the soft keyboard. If not, after change-route
    // animation completes, it will trigger rebuilding this widget and show all
    // textfields and buttons again before going to new route
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<Auth>(context, listen: false);
    bool? success;
    success = await auth.onInfoCPN?.call(InfoCPNData(
      accessToken: _bloc.refreshToken.toString(),
      uId: _bloc.deviceToken.toString()
    ));

    await _submitController.reverse();

    if(success == false){
      setState(() {
        _isSubmitting = false;
      });
      return false;
    }else {
      Future.delayed(const Duration(milliseconds: 270), () {
        if (mounted) {
          setState(() => _showShadow = false);
        }
      });
    }

    widget.onSubmitCompleted?.call();

    return true;
  }

  Widget _buildCompanyField(double width, Auth auth,) {
    return //_bloc.listInfoCPN.length > 1 ?
    PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      color: Colors.white,
      offset: const Offset(3, 65),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              height: _bloc.listInfoCPN.length == 1 ? 100 : _bloc.listInfoCPN.length == 2 ? 150 : _bloc.listInfoCPN.length == 3 ? 200 : 250,
              width: 500,
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _bloc.listInfoCPN.length,
                  itemBuilder: (context, index) {
                    final trans = _bloc.listInfoCPN[index].companyName;
                    return ListTile(
                      title: Text(
                        trans.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      subtitle: index == _bloc.listInfoCPN.length ? Container() :const Divider(height: 1,),
                      onTap: () {
                        if(_bloc.listInfoCPN.length > 1){
                          _bloc.companiesNameSelected = _bloc.listInfoCPN[index].companyName!;
                          _bloc.companiesIdSelected = _bloc.listInfoCPN[index].companyId!;
                          Const.companyName =  _bloc.listInfoCPN[index].companyName!;
                          Const.companyId =  _bloc.listInfoCPN[index].companyId!;
                          _bloc.add(Config(_bloc.listInfoCPN[index].companyId.toString()));
                        }
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          )
        ];
      },
      child: AnimatedTextFormField(
        showCard: false,
        controller: _companyController,
        width: width,
        loadingController: widget.loadingController,
        interval: _companyTextFieldLoadingAnimationInterval,
        labelText: 'Company',
        prefixIcon: Icon(MdiIcons.briefcaseOutline,color: Color.fromARGB(255, 0, 51, 114),size: 22,),
        enabled: false,
      ),
    ) ;
    // :
    // AnimatedTextFormField(
    //   showCard: false,
    //   controller: _companyController,
    //   width: width,
    //   loadingController: widget.loadingController,
    //   interval: _companyTextFieldLoadingAnimationInterval,
    //   labelText: 'Company',
    //   prefixIcon: Icon(MdiIcons.briefcaseOutline,color: Color.fromARGB(255, 0, 51, 114),size: 22,),
    //   enabled: false,
    // );
  }

  Widget _buildUnitField(double width, Auth auth) {
    return AnimatedTextFormField(
      showCard: false,
      width: width,
      loadingController: widget.loadingController,
      interval: _unitTextFieldLoadingAnimationInterval,
      labelText: 'Unit',
      controller: _unitController,
      focusNode: _passwordFocusNode,
      enabled: false,
      prefixIcon:const Icon(Icons.pin_drop,color: Color.fromARGB(255, 0, 51, 114),size: 20),
    );
  }

  Widget _buildStoreField(double width,  Auth auth) {
    return
     AnimatedTextFormField(
      width: width,
      showCard: false,
      enabled: false,
      loadingController: widget.loadingController,
      inertiaController: _postSwitchAuthController,
      inertiaDirection: TextFieldInertiaDirection.right,
      labelText: 'Store',
      controller: _storeController,
      prefixIcon: Icon(MdiIcons.storefront,color: Color.fromARGB(255, 0, 51, 114),size: 20),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, Auth auth) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        text: '      Tiếp tục      ',
        onPressed: (){
          if(_bloc.unitsIdSelected != null && _bloc.unitsIdSelected != 'null' && _bloc.unitsIdSelected != ''){
            _submit();
          }else{
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Hãy chọn đơn vị (unit) của bạn');
          }
        },//
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isShowStore = auth.onInfoCPN;
    final theme = Theme.of(context);
    final cardWidth = min(MediaQuery.of(context).size.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final authForm = Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: cardPadding,
              right: cardPadding,
              top: cardPadding + 10,
            ),
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildCompanyField(textFieldWidth, auth),
                const SizedBox(height: 20),
                PopupMenuButton(
                    color: Colors.white,
                    shape: const TooltipShape(),
                    padding: EdgeInsets.zero,
                    offset: const Offset(3, 65),
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<Widget>>[
                        PopupMenuItem<Widget>(
                          child: Container(
                            decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            height:_bloc.listUnitsCPN.length < 3 ? 150 : _bloc.listUnitsCPN.length == 3 ? 200 : 250,
                            width: 500,
                            child: Scrollbar(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(top: 10),
                                itemCount: _bloc.listUnitsCPN.length,
                                itemBuilder: (context, index) {
                                  final trans = _bloc.listUnitsCPN[index].unitName;
                                  return ListTile(
                                    minVerticalPadding: 1,
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            trans.toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,overflow: TextOverflow.fade,
                                          ),
                                        ),
                                        Text(
                                          _bloc.listUnitsCPN[index].unitId.toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle:const Divider(height: 1,),
                                    onTap: () {
                                      if(_bloc.listUnitsCPN.length > 1){
                                        _bloc.unitsNameSelected = _bloc.listUnitsCPN[index].unitName!;
                                        _bloc.unitsIdSelected = _bloc.listUnitsCPN[index].unitId!;
                                        Const.unitId = _bloc.listUnitsCPN[index].unitId!;
                                        Const.unitName = _bloc.listUnitsCPN[index].unitName!;
                                        _bloc.add(GetStore(_bloc.unitsIdSelected.toString()));
                                      }
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ];
                    },
                    child: Container(child: _buildUnitField(textFieldWidth, auth))),
                const SizedBox(height: 10),
              ],
            ),
          ),
          ExpandableContainer(
            backgroundColor: _switchAuthController.isCompleted
                ? null
                : theme.colorScheme.secondary,
            controller: _switchAuthController,
            initialState: isShowStore != null
                ? ExpandableContainerState.shrunk
                : ExpandableContainerState.expanded,
            alignment: Alignment.topLeft,
            color: theme.cardTheme.color,
            width: cardWidth,
            padding: const EdgeInsets.symmetric(horizontal: cardPadding),
            onExpandCompleted: (){
              _postSwitchAuthController.forward();
            },
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: _bloc.listInfoCPN.length > 1 ? PopupMenuButton(
                  color: Colors.white,
                  shape: const TooltipShape(),
                  padding: EdgeInsets.zero,
                  offset: const Offset(3, 65),
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<Widget>>[
                      PopupMenuItem<Widget>(
                        child: Container(
                          decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          height: _bloc.listStoreCPN.length == 1 ? 100 : _bloc.listStoreCPN.length == 2 ? 150 : _bloc.listStoreCPN.length == 3 ? 200 : 250,
                          width: 500,
                          child: Scrollbar(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 10),
                              itemCount: _bloc.listStoreCPN.length,
                              itemBuilder: (context, index) {
                                final trans = _bloc.listStoreCPN[index].storeName;
                                return ListTile(
                                  title: Text(
                                    trans.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  subtitle:const Divider(height: 1,),
                                  onTap: () {
                                    if(_bloc.listStoreCPN.length > 1){
                                      _bloc.storeNameSelected = _bloc.listStoreCPN[index].storeName!;
                                      _bloc.storeIdSelected = _bloc.listStoreCPN[index].storeId!;
                                      Const.storeName = _bloc.listStoreCPN[index].storeName!;
                                      Const.storeId = _bloc.listStoreCPN[index].storeId!;
                                      _bloc.add(UpdateCacheStoreEvent(storeId: Const.storeId.toString()));
                                    }
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ];
                  },
                  child: _buildStoreField(textFieldWidth, auth),
                ) : _buildStoreField(textFieldWidth, auth),
              )
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(right: cardPadding, bottom: cardPadding, left: cardPadding,),
            width: cardWidth,
            child: Column(
              children: <Widget>[
                _buildSubmitButton(theme, auth),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    return BlocListener<InfoCPNBloc, InfoCPNState>(
      bloc: _bloc,
      listener: (context, state) {
        if(state is InfoCPNSuccess){
          // _bloc.accessToken = DataLocal.accessTokenLogin;
          Future.delayed(loginTime).then((_) {
            _switchAuthMode();
          });
          _bloc.add(GetCompanyIF());
          //_bloc.add(GetSettingOption());
        }
        else if(state is GetSettingsSuccessful){

        }
        else if(state is UpdateUIdSuccess){

        }
        else if(state is InfoCPNFailure){
          Utils.showCustomToast(context, Icons.error, state.error);
          PersistentNavBarNavigator.pushNewScreen(context, screen: const LoginScreen(),withNavBar: false);
        }
        else if(state is GetInfoCompanySuccessful) {
          _bloc.add(GetSettingOption());
          if(_bloc.listInfoCPN.length == 1){
            _bloc.companiesNameSelected = _bloc.listInfoCPN[0].companyName!;
            _companyController.text = _bloc.listInfoCPN[0].companyName!;
            _bloc.companiesIdSelected = _bloc.listInfoCPN[0].companyId!;
            Const.companyName =  _bloc.listInfoCPN[0].companyName!;
            Const.companyId =  _bloc.listInfoCPN[0].companyId!;
            _bloc.add(GetUnits());
          } else{
            _companyController.text = _bloc.companiesNameSelected!;
          }
        }
        else if(state is GetInfoUnitsSuccessful){
          if(_bloc.listUnitsCPN.length == 1){
            _bloc.unitsNameSelected = _bloc.listUnitsCPN[0].unitName!;
            _unitController.text = _bloc.listUnitsCPN[0].unitName!;
            _bloc.unitsIdSelected = _bloc.listUnitsCPN[0].unitId!;
            Const.unitName = _bloc.listUnitsCPN[0].unitName!;
            Const.unitId = _bloc.listUnitsCPN[0].unitId!;
            _bloc.add(GetStore(_bloc.unitsIdSelected.toString()));
          }else{
           // _unitController.text = state.unitName;
          }
        }
        else if(state is GetInfoStoreSuccessful){
          _bloc.keyLock =0;
          Const.storeId = _bloc.storeIdSelected.toString();
          _unitController.text = _bloc.unitsNameSelected!;
          if(_bloc.listStoreCPN.isEmpty){
            if(_bloc.showAnimationStore == true){
              _switchAuthMode();
            }
          }
          if(_bloc.listStoreCPN.length == 1){
            _bloc.storeNameSelected = _bloc.listStoreCPN[0].storeName!;
            _storeController.text = _bloc.listStoreCPN[0].storeName!;
            _bloc.storeIdSelected = _bloc.listStoreCPN[0].storeId!;
            Const.storeName = _bloc.listStoreCPN[0].storeName!;
            Const.storeId = _bloc.listStoreCPN[0].storeId!;
            _bloc.add(UpdateCacheStoreEvent(storeId: Const.storeId.toString()));
          }
          else{
            _storeController.text = _bloc.storeNameSelected.toString();
          }
          _bloc.add(UpdateTokenFCM());
        }
        else if(state is GetStoreCPNFailure){
          print(state.error.toString());
          _unitController.text = _bloc.unitsNameSelected!;
          _bloc.showAnimationStore = false;
          if(_bloc.keyLock < 1){
            _bloc.keyLock +=1;
            _switchAuthMode();
          }
          _bloc.add(UpdateTokenFCM());
        }
        else if(state is ConfigSuccessful){
          _bloc.add(GetUnits());
        }
        else if(state is GetPermissionFail){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn không có quyền truy cập vào app !!!');
        }
        // else if(state is GetPermissionSuccess){
        //   _bloc.add(UpdateTokenFCM());
        // }
      },
      child: BlocBuilder<InfoCPNBloc, InfoCPNState>(
        bloc: _bloc,
        builder: (BuildContext context, InfoCPNState state){
          return FittedBox(
            child: Card(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.white,
              child: authForm,
            ),
          );
        }
      )
    );
  }
}

class MySelectionItem extends StatelessWidget {
  final String? title;
  final bool isForList;

  const MySelectionItem({Key? key, this.title, this.isForList = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: isForList
          ? Padding(
        padding:const EdgeInsets.all(10.0),
        child: _buildItem(context),
      )
          : Card(
        margin:const EdgeInsets.symmetric(horizontal: 10.0),
        child: Stack(
          children: <Widget>[
            _buildItem(context),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_drop_down),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: FittedBox(
          child: Text(
            title!,
          )),
    );
  }
}