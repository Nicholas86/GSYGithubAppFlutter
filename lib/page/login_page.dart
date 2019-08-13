import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:gsy_github_app_flutter/common/config/config.dart';
import 'package:gsy_github_app_flutter/common/dao/user_dao.dart';
import 'package:gsy_github_app_flutter/common/local/local_storage.dart';
import 'package:gsy_github_app_flutter/common/localization/default_localizations.dart';
import 'package:gsy_github_app_flutter/common/redux/gsy_state.dart';
import 'package:gsy_github_app_flutter/common/style/gsy_style.dart';
import 'package:gsy_github_app_flutter/common/utils/common_utils.dart';
import 'package:gsy_github_app_flutter/common/utils/navigator_utils.dart';
import 'package:gsy_github_app_flutter/widget/gsy_flex_button.dart';
import 'package:gsy_github_app_flutter/widget/gsy_input_widget.dart';

/**
 * 登录页
 * Created by guoshuyu
 * Date: 2018-07-16
 */
class LoginPage extends StatefulWidget {
  static final String sName = "login";

  @override
  State createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  var _userName = "";

  var _password = "";

  final TextEditingController userController = new TextEditingController();
  final TextEditingController pwController = new TextEditingController();

  _LoginPageState() : super();

  @override
  void initState() {
    super.initState();
    initParams();
  }

  initParams() async {
    /// 获取本地缓存的用户名
    _userName = await LocalStorage.get(Config.USER_NAME_KEY);
    /// 获取本地缓存的密码
    _password = await LocalStorage.get(Config.PW_KEY);
    userController.value = new TextEditingValue(text: _userName ?? "");
    pwController.value = new TextEditingValue(text: _password ?? "");
  }

  @override
  Widget build(BuildContext context) {
    ///共享 store
    return new StoreBuilder<GSYState>(builder: (context, store) {
      /// 触摸收起键盘
      return new GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          body: new Container(
            color: Theme.of(context).primaryColor,
            child: new Center(
              ///防止overFlow的现象
              child: SafeArea(
                ///同时弹出键盘不遮挡
                child: SingleChildScrollView(
                  /// 卡片视图
                  child: new Card(
                    elevation: 5.0,
                    /// 圆角
                    shape: new RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Color(GSYColors.cardWhite),
                    /// 左、右间距
                    margin: const EdgeInsets.only(left: 30.0, right: 30.0),
                    /// 内边距
                    child: new Padding(
                      padding: new EdgeInsets.only(
                          left: 30.0, top: 40.0, right: 30.0, bottom: 0.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,

                        children: <Widget>[
                          /// 图片
                          new Image(
                              color: Colors.red,
                              image: new AssetImage(GSYICons.DEFAULT_USER_ICON),
                              width: 90.0,
                              height: 90.0),

                          /// 加空白间距
                          new Padding(padding: new EdgeInsets.all(10.0)),

                          /// 输入控件
                          new GSYInputWidget(
                            hintText: CommonUtils.getLocale(context)
                                .login_username_hint_text,
                            iconData: GSYICons.LOGIN_USER,
                            onChanged: (String value) {
                              _userName = value;
                            },
                            controller: userController,
                          ),

                          /// 加空白间距
                          new Padding(padding: new EdgeInsets.all(10.0)),

                          /// 输入控件
                          new GSYInputWidget(
                            hintText: CommonUtils.getLocale(context)
                                .login_password_hint_text,
                            iconData: GSYICons.LOGIN_PW,
                            obscureText: true,
                            onChanged: (String value) {
                              _password = value;
                            },
                            controller: pwController,
                          ),

                          /// 加空白间距
                          new Padding(padding: new EdgeInsets.all(30.0)),

                          /// 自定义登录按钮
                          new GSYFlexButton(
                            text: CommonUtils.getLocale(context).login_text,
                            color: Theme.of(context).primaryColor,
                            textColor: Color(GSYColors.textWhite),
                            onPress: () {
                              print('点击登录按钮');
                              if (_userName == null || _userName.length == 0) {
                                return;
                              }
                              if (_password == null || _password.length == 0) {
                                return;
                              }

                              /// 显示加载视图
                              CommonUtils.showLoadingDialog(context);

                              UserDao.login(
                                      _userName.trim(), _password.trim(), store)
                                  .then((res) {
                                Navigator.pop(context);
                                if (res != null && res.result) {
                                  new Future.delayed(const Duration(seconds: 1),
                                      () {
                                    /// 去主页
                                   print('去主页');
                                    NavigatorUtils.goHome(context);
                                    return true;
                                  });
                                }
                              });

                            },
                          ),
                          new Padding(padding: new EdgeInsets.all(15.0)),
                          InkWell(
                            onTap: () {
                              CommonUtils.showLanguageDialog(context, store);
                            },
                            child: Text(
                              CommonUtils.getLocale(context).switch_language,
                              style: TextStyle(
                                  color: Color(GSYColors.subTextColor)),
                            ),
                          ),
                          new Padding(padding: new EdgeInsets.all(15.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
