import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/dataset.dart';
import 'widgets.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class ModelViewer extends StatelessWidget {
  const ModelViewer({
    super.key,
    required this.model,
  });
  final Model model;

  @override
  Widget build(BuildContext context) {

    final Widget modelViewer = SuperModelViewer(
      objectUUID: model.objectUUID,
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