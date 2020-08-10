/*
* Author : LiJiqqi
* Date : 2020/8/5
*/


import 'dart:convert';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_im_plugin/entity/message_entity.dart';
import 'package:tencent_im_plugin/entity/session_entity.dart';
import 'package:tencent_im_plugin/enums/log_print_level.dart';
import 'package:tencent_im_plugin/message_node/text_message_node.dart';
import 'package:tencent_im_plugin/tencent_im_plugin.dart';

/// 数据实体
class DataEntity {
  /// 消息实体
  final MessageEntity data;

  /// 进度
  final int progress;

  DataEntity({
    this.data,
    this.progress,
  });
}

class VideoScreen extends StatefulWidget {

  final String id;
  final String sign;

  const VideoScreen({Key key, this.id, this.sign}) : super(key: key);



  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FijkPlayer player = FijkPlayer();
  final String pullUrl = 'rtmp://video.apitripalink.com/live/tripalink';
  final String cctv = 'rtmp://58.200.131.2:1935/livetv/cctv2';

  _VideoScreenState();

  final String id =  '@TGS#a2HHHJUGA';
  final SessionType type = SessionType.Group;

  /// 当前消息列表
  List<DataEntity> data = [];

  /// 滚动控制器
  ScrollController scrollController = ScrollController();
  TextEditingController textEditingController = TextEditingController();
  
  bool initSDK = false;
  bool login = false;
  
  @override
  void initState() {
    init();
    super.initState();
    player.setDataSource(pullUrl, autoPlay: true);
    // 添加监听器
    TencentImPlugin.addListener(listener);
  }

  void init()async{
    TencentImPlugin.init(
        appid: "1400408794", logPrintLevel: LogPrintLevel.debug)
        .then((value) => loginAA());
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.storage,
      Permission.microphone,
    ].request();
  }

  @override
  void dispose() {
    super.dispose();
    TencentImPlugin.removeListener(listener);
    player.release();
    textEditingController.dispose();
  }

  void loginAA()async{
    initSDK = true;
    await TencentImPlugin.login(
      identifier: widget.id,
      userSig:widget.sign,
    ).then((value)async{
      await TencentImPlugin.applyJoinGroup(groupId: id
          , reason: 'hello').then((value) => login = true);
    });
//    Navigator.of(context).push(new MaterialPageRoute(
//        builder: (ctx)=>ChatPage(id: '@TGS#a2HHHJUGA',type: SessionType.Group,)));
  }


  /// 监听器
  listener(type, params) {
    debugPrint('监听');
    debugPrint('${type.toString()}----------${params.toString()}');
    // 新消息时更新会话列表最近的聊天记录
    if (type == ListenerTypeEnum.NewMessages) {
      // 更新消息列表
      this.setState(() {
        data.add(DataEntity(data: params));
        debugPrint('data  ------- ${data.last.data.toJson().toString()}');
      });
      // 设置已读
      TencentImPlugin.setRead(sessionId: id, sessionType: type);
    }
    ///test
    ///test
    if (type == ListenerTypeEnum.RefreshConversation) {
      for(var i in params){
        if(i is SessionEntity){
          // 更新消息列表
          debugPrint('refresh data  ${i.message.toJson().toString()}');
          if(i.message.read){
            this.setState(() {
              data.add(DataEntity(data: i.message));

            });
          }

          // 设置已读
          //TencentImPlugin.setRead(sessionId: widget.id, sessionType: widget.type);

        }
      }
      scrollController.jumpTo(scrollController.position.maxScrollExtent);


    }

    // 消息上传通知
    if (type == ListenerTypeEnum.UploadProgress) {
      Map<String, dynamic> obj = jsonDecode(params);

      // 获得进度和消息实体
      int progress = obj["progress"];
      MessageEntity message = MessageEntity.fromJson(obj["message"]);

      // 更新数据
      this.updateData(DataEntity(
        data: message,
        progress: progress,
      ));
    }
  }

  /// 更新单个数据
  updateData(DataEntity dataEntity) {
    bool exist = false;
    for (var index = 0; index < data.length; index++) {
      DataEntity item = data[index];
      if (item.data == dataEntity.data) {
        this.data[index] = dataEntity;
        exist = true;
        break;
      }
    }

    if (!exist) {
      this.data.add(dataEntity);
    }

    this.setState(() {});
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: Text("Fijkplayer Example")),
        body: Container(
          width: size.width,height: size.height,
          alignment: Alignment.center,
          child: Stack(
            children: [
              FijkView(
                //width: size.width,height: size.height,
                fit: FijkFit.fill,
                fsFit: FijkFit.fill,
                player: player,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child:Container(
                  color: Colors.white.withOpacity(0.3),
                  width: MediaQuery.of(context).size.width,height: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: data.map((e){
                            return Container(
                              width: MediaQuery.of(context).size.width,height: 60,
                              child: Text('note : ${e.data.note}',style: TextStyle(color: Colors.black),),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        margin: EdgeInsets.only(bottom: 10),
                        width: MediaQuery.of(context).size.width,height: 40,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  hintText: 'input 666 , laoTie!',
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: ()async{
                                if(!initSDK){
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('sdk initialize failed，please retry later'),
                                  ));
                                  return;
                                }
                                if(!login){
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('login failed，please retry later'),
                                  ));
                                  return;
                                }
                                await TencentImPlugin.sendMessage(sessionId: '@TGS#a2HHHJUGA',
                                  sessionType: SessionType.Group, node: TextMessageNode(
                                    content: textEditingController.text??"",
                                  ),).then((value) {

                                  textEditingController?.clear();
                                  debugPrint('msg recall  ${value.toJson().toString()}');
                                });

                              },
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.orange,
                                width: 60,height: 40,
                                child: Text('发送',style: TextStyle(color: Colors.black),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ) ,
              ),
            ],
          ),
        ));
  }


}