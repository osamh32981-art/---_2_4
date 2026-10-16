import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// ======================= ١- الإعدادات والألوان =======================
const kPrimary = Color(0xFF0E7490);
const kSecondary = Color(0xFF06B6D4);
const kBg = Color(0xFFF0FDFD);
const kDesignerColor = Color(0xFFFFD700);

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: Locale('ar'),
  home: AppLAN(),
));

// ======================= ٢- نموذج الرسالة =======================
class Msg {
  String text;
  String type; // text, image, voice
  bool isMe;
  String sender;
  bool isDesigner;
  DateTime time;
  Msg({required this.text, required this.type, required this.isMe, required this.sender, this.isDesigner=false, required this.time});
}

// ======================= ٣- التطبيق الرئيسي =======================
class AppLAN extends StatefulWidget {
  @override
  _AppLANState createState() => _AppLANState();
}

class _AppLANState extends State<AppLAN> {
  // ---- أدوات التحكم ----
  TextEditingController nameCtrl = TextEditingController(text: "المصمم");
  TextEditingController msgCtrl = TextEditingController();
  List<Msg> messages = [];
  List<String> onlineUsers = ["جوال أحمد - 192.168.1.5", "لابتوب العمل - 192.168.1.12", "المصمم - أنت"];
  String myIp = "192.168.1.20";
  String selectedRingtone = "نغمة رنين هادئة";
  Color bubbleColor = kPrimary;
  bool isRecording = false;
  String? userName;
  bool get isDesigner => userName == "المصمم" || userName == "المصمم الذهبي";

  List<String> ringtones = [
    "نغمة رنين هادئة",
    "نغمة طيور الصباح",
    "نغمة بحر رائعة",
    "نغمة تنبيه ذكي",
    "نغمة مسجد خاشعة",
  ];

  List<String> fakeImages = ["🏔️", "🌅", "🕌", "🌴", "📸"];

  @override
  void initState(){
    super.initState();
    // رسالة ترحيبية
    messages.add(Msg(text: "مرحباً بك في تواصل LAN بدون نت! كل الأجهزة على نفس الشبكة تقدر تتكلم", type: "text", isMe: false, sender: "النظام", time: DateTime.now()));
  }

  void sendMsg(String type, String content){
    if(content.trim().isEmpty) return;
    setState(() {
      messages.add(Msg(text: content, type: type, isMe: true, sender: userName!, isDesigner: isDesigner, time: DateTime.now()));
    });
    msgCtrl.clear();
    // محاكاة رد من الشبكة + تشغيل النغمة
    Future.delayed(Duration(seconds: 1), (){
      setState(() {
        messages.add(Msg(text: "وصلتني: $content", type: "text", isMe: false, sender: "أحمد", time: DateTime.now()));
      });
      _playRingtone();
    });
  }

  void _playRingtone(){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("🔔 $selectedRingtone - وصلت رسالة جديدة!"),
      backgroundColor: bubbleColor,
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if(userName == null){
      return _buildLogin();
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kPrimary,
          title: Row(children: [
            Icon(Icons.wifi, color: Colors.white),
            SizedBox(width: 8),
            Text("تواصل LAN - بدون نت", style: TextStyle(color: Colors.white, fontSize: 16)),
            if(isDesigner) ...[
              SizedBox(width: 6),
              Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: kDesignerColor, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [Icon(Icons.star, size: 14, color: Colors.black), Text(" المصمم ", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))])
              )
            ]
          ]),
          actions: [
            IconButton(icon: Icon(Icons.color_lens, color: Colors.white), onPressed: _showColorPicker),
            IconButton(icon: Icon(Icons.music_note, color: Colors.white), onPressed: _showRingtones),
          ],
        ),
        body: Column(children: [
          // معلومات الشبكة
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _infoChip(Icons.router, "IP: $myIp"),
              _infoChip(Icons.people, "${onlineUsers.length} متصل"),
              _infoChip(Icons.check_circle, "متصل LAN", color: Colors.green),
            ]),
          ),
          // قائمة المتصلين
          Container(height: 55, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: onlineUsers.length,
            itemBuilder: (c,i)=> Container(margin: EdgeInsets.all(6), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: kSecondary)),
              child: Row(children: [Icon(Icons.phone_android, size: 16), SizedBox(width: 4), Text(onlineUsers[i], style: TextStyle(fontSize: 12))]),
            ),
          )),
          // الرسائل
          Expanded(child: ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (c,i){
              var m = messages[messages.length-1-i];
              return Align(
                alignment: m.isMe ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(margin: EdgeInsets.all(6), padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: m.isMe ? bubbleColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: m.isDesigner ? Border.all(color: kDesignerColor, width: 2) : null,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)]
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(m.sender, style: TextStyle(fontWeight: FontWeight.bold, color: m.isMe ? Colors.white : kPrimary, fontSize: 12)),
                      if(m.isDesigner) ...[SizedBox(width: 4), Icon(Icons.verified, color: kDesignerColor, size: 14), Text(" مصمم مميز", style: TextStyle(color: kDesignerColor, fontSize: 10, fontWeight: FontWeight.bold))],
                    ]),
                    SizedBox(height: 4),
                    if(m.type=="text") Text(m.text, style: TextStyle(color: m.isMe ? Colors.white : Colors.black)),
                    if(m.type=="image") Text(m.text, style: TextStyle(fontSize: 40)),
                    if(m.type=="voice") Row(children: [Icon(Icons.mic, color: m.isMe ? Colors.white : kPrimary), SizedBox(width: 6), Container(width: 120, height: 20, child: Row(children: List.generate(15, (i)=> Container(margin: EdgeInsets.all(1), width: 3, height: Random().nextInt(15)+5.0, color: m.isMe ? Colors.white70 : kPrimary)))), Text(" 0:${Random().nextInt(50)+10}", style: TextStyle(color: m.isMe ? Colors.white : Colors.black))]),
                    Text("${m.time.hour}:${m.time.minute}", style: TextStyle(fontSize: 9, color: m.isMe ? Colors.white70 : Colors.grey)),
                  ]),
                ),
              );
            },
          )),
          // أدوات الإرسال
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: Row(children: [
              IconButton(icon: Icon(Icons.image, color: kPrimary), onPressed: (){
                var img = fakeImages[Random().nextInt(fakeImages.length)];
                sendMsg("image", img);
              }),
              GestureDetector(
                onLongPress: (){ setState(()=> isRecording=true); },
                onLongPressEnd: (_){ setState(()=> isRecording=false); sendMsg("voice", "رسالة صوتية"); },
                child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: isRecording ? Colors.red : kPrimary, shape: BoxShape.circle), child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white)),
              ),
              SizedBox(width: 8),
              Expanded(child: TextField(controller: msgCtrl, decoration: InputDecoration(hintText: "اكتب رسالة عبر LAN...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)), contentPadding: EdgeInsets.symmetric(horizontal: 15)))),
              Sized