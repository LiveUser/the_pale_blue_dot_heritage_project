import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:html' as html;

AppBar appBar(){
  return AppBar(
    title: Text(
      "The Pale Blue Dot Heritage Project",
      style: TextStyle(
        fontFamily: "SairaStencil",
      ),
    ),
    foregroundColor: Colors.white,
    backgroundColor: Colors.orange,
    centerTitle: true,
  );
}

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.orange,
      child: SingleChildScrollView(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          spacing: 10,
          children: [
            BackButton(
              color: Colors.white,
              onPressed: (){
                Navigator.pop(context);
                if(Navigator.canPop(context)){
                  Navigator.pop(context);
                }
              },
            ),
            NavOption(
              text: "Home", 
              routeName: "home",
            ),
            NavOption(
              text: "About Us", 
              routeName: "about-us",
            ),
            NavOption(
              text: "Digital Library", 
              routeName: "digital-library",
            ),
          ],
        ),
      ),
    );
  }
}
class NavOption extends StatelessWidget {
  const NavOption({
    super.key,
    required this.text,
    required this.routeName,
  });
  final String text;
  final String routeName;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        width: double.infinity,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: "SairaStencil",
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
class BoxOfText extends StatelessWidget {
  const BoxOfText({
    super.key,
    required this.title,
    this.text = "",
    this.file,
  });
  final String title;
  final String text;
  final String? file;
  Future<String> fetchStringFromFile()async{
    return await rootBundle.loadString(file!);
  }
  @override
  Widget build(BuildContext context) {
    if(file == null){
      return Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "SairaStencil",
                    fontSize: 25,
                    color: Colors.orange
                  ),
                ),
              ),
              SpeakLoudButton(
                text: "$title. $text",
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: Colors.white,
          ),
          Text(
            text,
            style: TextStyle(
              fontFamily: "SairaStencil",
              fontSize: 25,
            ),
          ),
        ],
      );
    }else{
      return FutureBuilder(
        future: fetchStringFromFile(),
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            );
          }else{
            return Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: "SairaStencil",
                          fontSize: 25,
                          color: Colors.orange
                        ),
                      ),
                    ),
                    SpeakLoudButton(
                      text: "$title. ${asyncSnapshot.data as String}",
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 2,
                  color: Colors.white,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.orange,
                  child: Text(
                    asyncSnapshot.data as String,
                    style: TextStyle(
                      fontFamily: "SairaStencil",
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }
        }
      );
    }
  }
}

class SpeakLoudButton extends StatefulWidget {
  const SpeakLoudButton({
    super.key,
    required this.text,
  });
  final String text;

  @override
  State<SpeakLoudButton> createState() => _SpeakLoudButtonState();
}

class _SpeakLoudButtonState extends State<SpeakLoudButton> {
  FlutterTts flutterTts = FlutterTts();
  bool speaking = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()async{
        if(!speaking){
          setState(() {
            speaking = true;
          });
          flutterTts.speak(widget.text);
        }else{
          setState(() {
            speaking = false;
          });
          flutterTts.stop();
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        child: Icon(
          speaking ? Icons.volume_off : Icons.volume_up,
          color: Colors.orange,
        ),
      ),
    );
  }
}
class SuperModelViewer extends StatefulWidget {
  const SuperModelViewer({
    super.key,
    required this.objectUUID,
  });
  final String objectUUID;
  @override
  State<SuperModelViewer> createState() => _SuperModelViewerState();
}

class _SuperModelViewerState extends State<SuperModelViewer> {
  Future<String> fetchData()async{
    String url = "https://man-well-sharply.ngrok-free.app/3d-model/${widget.objectUUID}";
    //print(url);
    Response response = await get(
      Uri.parse(url),
      headers: {
        'ngrok-skip-browser-warning': 'true', // This skips the ngrok landing page
        'Content-Type': 'application/bson',
      },
    );
    // Create a Blob from the bytes
    final blob = html.Blob([response.bodyBytes], 'model/gltf-binary');
    
    // Create a temporary URL pointing to that Blob
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    
    return blobUrl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context,snapshot){
        if(snapshot.hasError){
          return GestureDetector(
            onTap: (){
              setState(() {
                
              });
            },
            child: Center(
              child: Container(
                color: Colors.orange,
                padding: EdgeInsets.all(10),
                child: Text(
                  "Reload",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }else if(snapshot.connectionState == ConnectionState.done){
          return ModelViewer(
            key: widget.key,
            src: snapshot.data as String,
            autoRotate: true,
            cameraControls: true,
          );
        }else{
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.orange),
            ),
          );
        }
      },
    );
  }
}