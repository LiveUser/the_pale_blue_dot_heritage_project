import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/dataset.dart';
import 'widgets.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';
import 'dart:convert';

class ModelViewer extends StatefulWidget {
  const ModelViewer({
    super.key,
    required this.model,
  });
  final Model model;

  @override
  State<ModelViewer> createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  Future<String> fetchData()async{
    //print(url);
    Response response = await get(
      Uri.parse(widget.model.zenodoDownloadLink),
      headers: {
        'ngrok-skip-browser-warning': 'true', // This skips the ngrok landing page
      },
    );
    //print("--------------------------------------------------------------------");
    //print(response.bodyBytes);
   String base64Model = base64Encode(response.bodyBytes);
    // Return it as a Data URI that the Webview can read
    return "data:model/gltf-binary;base64,$base64Model";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBar(),
      drawer: NavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, asyncSnapshot) {
            if(asyncSnapshot.hasError){
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
            }else if(asyncSnapshot.connectionState == ConnectionState.done){
              return OrientationBuilder(
                builder: (context, orientation){
                  if(orientation == Orientation.portrait){
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 2,
                          child: SuperModelViewer(
                            base64String: asyncSnapshot.data as String,
                          ),
                        ),
                        //Display Details
                        Expanded(
                          child: SingleChildScrollView(
                            child: ModelDetailsDisplayer(
                              model: widget.model,
                            ),
                          ),
                        ),
                      ],
                    );
                  }else{
                    return Row(
                      children: [
                        //Display Model
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          height: double.infinity,
                          child: SuperModelViewer(
                            base64String: asyncSnapshot.data as String,
                          ),
                        ),
                        //Display Details
                        Expanded(
                          child: SingleChildScrollView(
                            child: ModelDetailsDisplayer(
                              model: widget.model,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }else{
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.orange),
                ),
              );
            }
          }
        ),
      ),
    );
  }
}
class ModelDetailsDisplayer extends StatelessWidget {
  const ModelDetailsDisplayer({
    super.key,
    required this.model,
  });
  final Model model;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(20),
      color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Title: ${model.title}",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "SairaStencil",
            ),
          ),
          Text(
            "Zenodo Digital Object Identifier: ${model.zenodoDigitalObjectIdentifier}",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "SairaStencil",
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Html(
              data: model.description,
            ),
          ),
          GestureDetector(
            onTap: (){
              //TODO: Open Zenodo Link
              final Uri uri = Uri.parse(model.zenodoDigitalObjectIdentifier);
              launchUrl(
                uri,
                mode: LaunchMode.platformDefault,
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(
                top: 20
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                "View on Zenodo",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}