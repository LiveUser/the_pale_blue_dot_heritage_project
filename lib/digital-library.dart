import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/model-viewer.dart';
import 'widgets.dart';
import 'dataset.dart';
import 'package:lost/lost.dart';
import 'package:flutter/services.dart';
import 'package:sortero/sortero.dart';
import 'package:http/http.dart';
import 'package:bson/bson.dart';

class DigitalLibrary extends StatefulWidget {
  const DigitalLibrary({
    super.key,
  });

  @override
  State<DigitalLibrary> createState() => _DigitalLibraryState();
}

class _DigitalLibraryState extends State<DigitalLibrary> {
  final TextEditingController searchQuery = TextEditingController();
  Future<List<Model>> fetchModels()async{
    List<Model> models = [];
    Map<String,dynamic> requestBody = {
      "variables": {
        
      },
      "query": "get-object-list",
    };
    Response response = await post(
      Uri.parse("https://man-well-sharply.ngrok-free.app/graphene"),
      body: BsonCodec.serialize(requestBody).byteList,
      headers: {
        'ngrok-skip-browser-warning': 'true', // This skips the ngrok landing page
        'Content-Type': 'application/bson',
      },
    );
    Map<String,dynamic> responseData = BsonCodec.deserialize(BsonBinary.from(response.bodyBytes));
    //print("---------------------------------------------------------");
    //print(responseData);
    //print("---------------------------------------------------------");
    for(Map<String,dynamic> model in responseData["data"]){
      models.add(Model(
        title: model["title"] ?? "No title", 
        description: model["description"] ?? "No description", 
        zenodoDigitalObjectIdentifier: model["zenodoDOI"], 
        zenodoDownloadLink: model["zenodoDownloadLink"],
      ));
    }
    return models;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: NavBar(),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: fetchModels(),
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
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if(orientation == Orientation.portrait){
                      return Column(
                        children: [
                          Image.asset(
                            "images/project-logo.png",
                            width: 300,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SearchBar(
                                  controller: searchQuery,
                                  backgroundColor: WidgetStatePropertyAll(Colors.orange),
                                  textStyle: WidgetStatePropertyAll(TextStyle(
                                    color: Colors.white,
                                  )),
                                  leading: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  trailing: [
                                    GestureDetector(
                                      onTap: (){
                                        searchQuery.text = "";
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          //Display all models
                          ModelsList(
                            initialValue: searchQuery.text,
                            onChange: (newText){
                              searchQuery.text = newText;
                            },
                            allModels: asyncSnapshot.data as List<Model>,
                          ),
                        ],
                      );
                    }else{
                      return Row(
                        children: [
                          Image.asset(
                            "images/project-logo.png",
                            width: 300,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SearchBar(
                                  controller: searchQuery,
                                  backgroundColor: WidgetStatePropertyAll(Colors.orange),
                                  textStyle: WidgetStatePropertyAll(TextStyle(
                                    color: Colors.white,
                                  )),
                                  leading: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  trailing: [
                                    GestureDetector(
                                      onTap: (){
                                        searchQuery.text = "";
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                //Display all models
                                ModelsList(
                                  initialValue: searchQuery.text,
                                  onChange: (newText){
                                    searchQuery.text = newText;
                                  },
                                  allModels: asyncSnapshot.data as List<Model>,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }
                ),
              ),
            );
          }else{
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            );
          }
        }
      ),
    );
  }
}
class ModelsList extends StatefulWidget {
  ModelsList({
    super.key,
    required this.initialValue,
    required this.onChange,
    required this.allModels,
  });
  final String initialValue;
  final TextEditingController searchQuery = TextEditingController();
  final Function(String newString) onChange;
  final List<Model> allModels;
  @override
  State<ModelsList> createState() => _ModelsListState();
}

class _ModelsListState extends State<ModelsList> {

  Future<List<ModelDetails>> getModelsList()async{
    List<ModelDetails> widgets = [];
    if(widget.searchQuery.text.isEmpty){
      //Do not filter
      for(Model model in widget.allModels){
        widgets.add(ModelDetails(model: model));
      }
    }else{
      //Filter
      for(Model model in widget.allModels){
        int titleInstances = model.title.instancesOf(widget.searchQuery.text);
        int descriptionInstances = model.description.instancesOf(widget.searchQuery.text);
        int zenodoDigitalObjectIdentifierInstances = model.zenodoDigitalObjectIdentifier.instancesOf(widget.searchQuery.text);
        if(0 < titleInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < descriptionInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < zenodoDigitalObjectIdentifierInstances){
          widgets.add(ModelDetails(model: model));
        }else{
          //No match. Do not add to list.
        }
      }
      //Rank based on query instances
      await widgets.bubbleSortAsync(
        compare: (modelDetails)async{
          int titleInstances = (modelDetails as ModelDetails).model.title.instancesOf(widget.searchQuery.text);
          String description  = "";
          try{
            description = await rootBundle.loadString("assets/descriptions/${modelDetails.model.description}");
          }catch(error){
            //Do nothing
          }
          int descriptionInstances = description.instancesOf(widget.searchQuery.text);
          int zenodoDigitalObjectIdentifierInstances = modelDetails.model.zenodoDigitalObjectIdentifier.instancesOf(widget.searchQuery.text);
          return titleInstances +  descriptionInstances + zenodoDigitalObjectIdentifierInstances;
        },
        reverseOrder: true,
      );
    }
    return widgets;
  }

  @override
  void initState(){
    super.initState();
    widget.searchQuery.text = widget.initialValue;
    widget.searchQuery.addListener((){
      widget.onChange(widget.searchQuery.text);
      setState(() {
        
      });
    });
  }
  @override
  void dispose(){
    super.dispose();
    widget.searchQuery.removeListener((){});
    widget.searchQuery.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getModelsList(), 
      builder: (context, asyncSnapshot){
        if(asyncSnapshot.connectionState == ConnectionState.waiting){
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          );
        }else{
          return Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Column(
                spacing: 10,
                children: asyncSnapshot.data as List<Widget>,
              ),
            ),
          );
        }
      },
    );
  }
}
class ModelDetails extends StatelessWidget {
  const ModelDetails({
    super.key,
    required this.model,
  });
  final Model model;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        //Model Viewer to see 3d model and object details
        Navigator.push(context, MaterialPageRoute(
          builder: (context)=> ModelViewer(model: model),
        ));
      },
      child: Container(
        padding: EdgeInsets.all(20),
        color: Colors.orange,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 10,
          children: [
            Expanded(
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
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}