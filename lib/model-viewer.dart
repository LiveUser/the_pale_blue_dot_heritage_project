import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/dataset.dart';
import 'widgets.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart' as model_viewer;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelViewer extends StatelessWidget {
  ModelViewer({
    super.key,
    required this.model,
  });
  final Model model;
  final GlobalKey _viewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Widget modelViewer = model_viewer.ModelViewer(
      src: "assets/3d_models/${model.modelName}",
    );
    return Scaffold(
      appBar: appBar(),
      drawer: NavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation){
            if(orientation == Orientation.portrait){
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2,
                    child: modelViewer,
                  ),
                  //Display Details
                  Expanded(
                    child: SingleChildScrollView(
                      child: ModelDetailsDisplayer(
                        model: model,
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
                    child: modelViewer,
                  ),
                  //Display Details
                  Expanded(
                    child: SingleChildScrollView(
                      child: ModelDetailsDisplayer(
                        model: model,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
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
  Future<String> fetchDescription()async{
    String description  = "";
    try{
      description = await rootBundle.loadString("assets/descriptions/${model.description}");
    }catch(error){
      //Do nothing
    }
    return description;
  }
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
            "University ID: ${model.universityID}",
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
          Text(
            "Location found: ${model.locationFound}",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "SairaStencil",
            ),
          ),
          Text(
            model.dateTimeFound == null ? "Date Found: null" : "Date Found: ${model.dateTimeFound!.year}-${model.dateTimeFound!.month}-${model.dateTimeFound!.day}",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "SairaStencil",
            ),
          ),
          FutureBuilder(
            future: fetchDescription(), 
            builder: (context,asyncSnapshot){
              if(asyncSnapshot.connectionState == ConnectionState.waiting){
                return CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                );
              }else{
                return Text(
                  (asyncSnapshot.data as String).isEmpty ? "Description: No description" : "Description: ${asyncSnapshot.data}",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "SairaStencil",
                  ),
                );
              }
            },
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