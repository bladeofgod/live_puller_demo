/*
* Author : LiJiqqi
* Date : 2020/8/10
*/

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterpulldemo/pull_page.dart';
import 'package:tencent_im_plugin/enums/log_print_level.dart';
import 'package:tencent_im_plugin/tencent_im_plugin.dart';

class LoginPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }

}

class LoginPageState extends State<LoginPage> {

  @override
  void initState() {
    //init();
    super.initState();
  }
  void init()async{
    await TencentImPlugin.init(
        appid: "1400408794", logPrintLevel: LogPrintLevel.debug);
  }

  Future<String> getPullUrl(String pusherName)async{
    Dio dio = Dio();
    var result = await dio.get('https://api.tripalink.com/index.php',
        queryParameters: {'r':'index/get-pull-url','pull_name':pusherName});
    debugPrint('${result.data.toString()}');
    debugPrint('pull url ${result.data['data']}');
    if(result != null ){
      return result.data['data']??'';

    }
    return '';


  }

  final String pusherName = 'pusher';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: Container(
        color: Colors.white,
        width: size.width,height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('测试demo，请勿同一时间登录一个账号',style: TextStyle(color: Colors.black),),
            SizedBox(
              width: 1,height: 40,
            ),
            RaisedButton(
              onPressed: (){
                getPullUrl(pusherName).then((value) {
                  Navigator.of(context).push(
                      new MaterialPageRoute(builder: (ctx)=>
                          VideoScreen(id:'bladeofgod' ,
                            pullUrl: value,
                            sign:  "eJwtzLEOgjAUheF36WzwUlvakjggC4MuKkSMC6QFrqgQIMRofHdJYTzfSf4vOe9Pzmg64hPqAFnZjdq8BizQcv7ItGmKstHL2*s6a1vUxHcZAAMpFJsf826xM5NzzikAzDrg05ryhCc23FsqWE7xENKkTy4QR4GscFfSeyg5uodrNNbVbc1imgYfpo61ELAlvz*F1jJf",
                          )));
                });

              },
              child: Text('bladeofgod',style: TextStyle(color: Colors.black),),
            ),
            SizedBox(
              width: 1,height: 40,
            ),
            RaisedButton(
              onPressed: (){
                getPullUrl(pusherName).then((value) {
                  Navigator.of(context).push(
                      new MaterialPageRoute(builder: (ctx)=>
                          VideoScreen(id:'administrator' ,
                            pullUrl: value,
                            sign: "eJwtzF0LgjAYBeD-suuQN5kfE7pYQlDY1YQ*7hZb8hba3FaZ0X9P1MvznMP5krIQwUtbkpEwALIYMyrdeLziyFLV2KDzVvqHnQdO3aUxqEi2pAAU0oTRqdGdQasHj6IoBIBJPdajsTiJU8ZmdVgN-5eqLMpTyuP*c74dN1Ls3HafH57YyrcI2473OTDu1kUCK-L7A2kbNPs_",

                          )));
                });



              },
              child: Text('administrator',style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}
























