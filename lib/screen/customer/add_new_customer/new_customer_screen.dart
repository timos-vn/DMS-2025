import 'package:cached_network_image/cached_network_image.dart';
import 'package:dms/widget/text_field_widget.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../themes/colors.dart';
import '../../../utils/utils.dart';
import '../../../widget/pending_action.dart' show PendingAction;
import 'new_customer_bloc.dart';
import 'new_customer_event.dart';
import 'new_customer_state.dart';

class AddNewCustomerScreen extends StatefulWidget {
  const AddNewCustomerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddNewCustomerScreenState();
  }
}

class AddNewCustomerScreenState extends State<AddNewCustomerScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _customerNameController =  TextEditingController();
  final TextEditingController _customerIDController =  TextEditingController();
  final TextEditingController _customerDetailAddressController =  TextEditingController();
  final TextEditingController _emailController =  TextEditingController();
  late NewCustomerBloc _bloc;
  final FocusNode _phoneNumberFocus = FocusNode(),
      _customerNameFocus = FocusNode(),
      _emailFocus = FocusNode(),
      _customerIDFocus = FocusNode(),
      _customerDetailAddressFocus = FocusNode();
  final List<String> _list = ['Male','Female',];
  bool validate = true;
  bool validateID = true;
  bool showError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = NewCustomerBloc(context);
    _bloc.add(GetPrefs());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocProvider(
          create: (context) => _bloc,
          child: BlocListener<NewCustomerBloc, NewCustomerState>(
              listener: (context, state) {
                if (state is NewCustomerFailure) {
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, ${state.error}');
                }
                if (state is AddNewCustomerSuccess) {
                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Thêm mới KH thành công');
                }
                if (state is FocusAddress) {
                  FocusScope.of(context).requestFocus(_customerIDFocus);
                }
                if (state is FocusName) {
                  FocusScope.of(context).requestFocus(_customerNameFocus);
                }
                if (state is FocusEmail) {
                  FocusScope.of(context).requestFocus(_emailFocus);
                }
                if (state is FocusPhoneNumber) {
                  FocusScope.of(context).requestFocus(_phoneNumberFocus);
                }
                if (state is PhoneNumberInputSuccess){}
              }, child: BlocBuilder<NewCustomerBloc, NewCustomerState>(builder: (BuildContext context, NewCustomerState state,) {
            return Stack(
              children: <Widget>[
                GestureDetector(
                    onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                    child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Center(child: avatarWidget()),

                      const SizedBox(
                        height: 10,
                      ),
                      buildInputCustomerID(context),
                      buildInputCustomerName(context),
                      buildInputPhoneNumber(context),
                      buildInputEmail(context),
                      buildInputCustomerSpecifiedAddress(context),
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 18.0),
                        child: Text('Giới tính',
                          style: TextStyle(color: grey, fontSize: 11.0),
                        ),
                      ),
                      genderWidget(),
                      const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(height: 1,thickness: 1,color: grey,),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 18.0),
                        child: Text(
                          'Ngày sinh',
                          style: TextStyle(color: grey, fontSize: 11.0),
                        ),
                      ),
                      buildDateSelector(state, context),
                      const Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20.0),
                        child: Divider(height: 1,thickness: 1,color: grey,),
                      ),
                      const SizedBox(height: 30,),
                      buildChangeProfile(state, context),
                    ])),
                Visibility(
                  visible: state is NewCustomerLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          })),
        ));
  }

  Widget genderWidget() {
    return Utils.isEmpty(_list)
        ? const Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12))
        : DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: _list[_bloc.sex + 1],
          items: _list.map((value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            _bloc.add(PickGender(_list.indexOf(value!) - 1));
          }),
    );
  }

  Widget avatarWidget() {
    return GestureDetector(
        onTap: () => _showDialog(context),
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: 120.0,
              width: 120.0,
              child: _bloc.file.path.isEmpty ? CircleAvatar(
                backgroundImage: (_bloc.avatar.isEmpty)
                ?
                const CachedNetworkImageProvider("https://cdn4.iconfinder.com/data/icons/users-38/24/user_symbol_person_2-256.png")
                : CachedNetworkImageProvider(_bloc.avatar)
              )
                  :
              CircleAvatar(
                  backgroundImage: FileImage(_bloc.file)
              ) ,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: CircleAvatar(
                radius: 15.0,
                backgroundColor: blue,
                child: Icon(
                  MdiIcons.cameraOutline,
                  color: white,
                  size: 20,
                ),
              ),
            )
          ],
        ));
  }

  Widget buildChangeProfile(NewCustomerState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16,top: 5,bottom: 20,right: 16),
      child: InkWell(
        onTap: (){
          if(!Utils.isEmpty(_customerIDController.text) && !Utils.isEmpty(_customerNameController.text) && !Utils.isEmpty(_phoneNumberController.text) && !Utils.isEmpty(_emailController.text)){
            setState(() => showError = false);
            _bloc.add(AddNewCustomerEvent(
              code: _customerIDController.text,
              name: _customerNameController.text,
              phoneNumber: _phoneNumberController.text,
              email: _emailController.text,
              address: _customerDetailAddressController.text,
            ));
          }else{
            setState(() => showError = true);
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vui lòng nhập đủ thông tin');
          }
        },
        child: Container(
          height: 50,
          width: 120,
          decoration: const BoxDecoration(
            color: orange,
            borderRadius: BorderRadius.all(Radius.circular(16))
          ),
          child: const Center(
            child: Text('Thêm',style: TextStyle(color: white,),),
          ),
        ),
      ),
    );
  }

  Padding buildInputCustomerID(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      child: TextFieldWidget2(
        controller: _customerIDController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        labelText: 'ID' ' *',
        color: Colors.red,
        focusNode: _customerIDFocus,
        onChanged: (_){
          setState(() {
            if(!Utils.isEmpty(_customerIDController.text)){
              validateID = true;
            }else{
              validateID = false;
            }
          });
        },
        onSubmitted: (text) => Utils.navigateNextFocusChange(context,_customerIDFocus , _customerNameFocus),
        errorText:validateID == false? 'Mã khách hàng': null,
      ),
    );
  }

  Padding buildInputCustomerName(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      child: TextFieldWidget2(
        controller: _customerNameController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        color: Colors.red,
        labelText: 'Tên khách hàng' ' *',
        focusNode: _customerNameFocus,
        onChanged: (_){
          setState(() {
            if(_customerNameController.text.trim().length >= 4){
              validate = true;
            }else if(_customerNameController.text.trim().length<4){
              validate = false;
            }
          });
        },
        onSubmitted: (text) => Utils.navigateNextFocusChange(context, _customerNameFocus, _phoneNumberFocus),

        errorText:validate == false? 'Tên Khách Hàng phải có ít nhất 4 ký tự': null,
      ),
    );
  }

  Padding buildInputPhoneNumber(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      child: TextFieldWidget2(
        controller: _phoneNumberController,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.phone,
        labelText: 'Điện thoại' ' *',
        color: Colors.red,
        errorText: _bloc.errorPhoneNumber,
        onChanged: (text) => _bloc.add(ValidatePhoneNumber(text!)),
        focusNode: _phoneNumberFocus,
        onSubmitted: (text) {
          Utils.navigateNextFocusChange(context, _phoneNumberFocus, _emailFocus);
        },
      ),
    );
  }

  Padding buildInputEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      child: TextFieldWidget2(
          controller: _emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          labelText: "Email" ' *',
          color: Colors.red,
          errorText: _bloc.errorEmail,
          focusNode: _emailFocus,
          onChanged: (text) => _bloc.add(ValidateEmail(text!)),
          onSubmitted: (text) => Utils.navigateNextFocusChange(
              context, _emailFocus, _customerDetailAddressFocus)),
    );
  }

  Padding buildInputCustomerSpecifiedAddress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
      child: TextFieldWidget(
          controller: _customerDetailAddressController,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          labelText: 'Địa chỉ',
          focusNode: _customerDetailAddressFocus, readOnly: false,)
          // onSubmitted: (text) => Utils.navigateNextFocusChange(
          //     context, _customerDetailAddressFocus, _customerAddressFocus)),
    );
  }

  Widget buildDateSelector(NewCustomerState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 7.0),
      child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                _bloc.dob.toString(),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
                child: Icon(
                  MdiIcons.calendar,
                  color: primaryColor,
                ),
                onTap: () {
                  Utils.selectDatePicker(
                    context,
                        (value) {
                      if (value != null) {
                        _bloc.add(PickDate(value));
                      }
                    },
                    initDate: _bloc.dobDate,
                  );
                }),
          ]),
    );
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text("Avatar"),
            actions: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Text("Library"),
                    onPressed: () {
                      _bloc.add(UploadAvatarEvent(false));
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Camera"),
                    onPressed: () {
                      _bloc.add(UploadAvatarEvent(true));
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          );
        });
  }
}
