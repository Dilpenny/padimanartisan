import 'package:flutter/cupertino.dart';

class ChatMessage{
  String messageContent;
  String messageType;
  Widget? videoObj, photoObj, audioObj;
  String id;
  bool viewingOption;
  ChatMessage({required this.messageContent, required this.messageType, required this.viewingOption, required this.id,
    this.videoObj, this.audioObj, this.photoObj});
}