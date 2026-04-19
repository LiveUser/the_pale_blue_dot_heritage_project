import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/model-viewer.dart';
import 'widgets.dart';
import 'dataset.dart';
import 'package:lost/lost.dart';
import 'package:flutter/services.dart';
import 'package:sortero/sortero.dart';

class DigitalLibrary extends StatelessWidget {
  DigitalLibrary({
    super.key,
  });
  final TextEditingController searchQuery = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: NavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
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
      ),
    );
  }
}
class ModelsList extends StatefulWidget {
  ModelsList({
    super.key,
    required this.initialValue,
    required this.onChange,
  });
  final String initialValue;
  final TextEditingController searchQuery = TextEditingController();
  final Function(String newString) onChange;
  @override
  State<ModelsList> createState() => _ModelsListState();
}

class _ModelsListState extends State<ModelsList> {

  Future<List<ModelDetails>> getModelsList()async{
    List<ModelDetails> widgets = [];
    if(widget.searchQuery.text.isEmpty){
      //Do not filter
      for(Model model in allModels){
        widgets.add(ModelDetails(model: model));
      }
    }else{
      //Filter
      for(Model model in allModels){
        int titleInstances = model.title.instancesOf(widget.searchQuery.text);
        String description  = "";
        try{
          description = await rootBundle.loadString("assets/descriptions/${model.description}");
        }catch(error){
          //Do nothing
        }
        int descriptionInstances = description.instancesOf(widget.searchQuery.text);
        int universityIDInstances = model.universityID == null ? 0 : model.universityID!.instancesOf(widget.searchQuery.text);
        int zenodoDigitalObjectIdentifierInstances = model.zenodoDigitalObjectIdentifier.instancesOf(widget.searchQuery.text);
        int locationFoundInstances = model.locationFound == null ? 0 : model.locationFound!.instancesOf(widget.searchQuery.text);
        int dateTimeFoundInstances = model.dateTimeFound == null ? 0 : model.dateTimeFound!.toString().instancesOf(widget.searchQuery.text);
        if(0 < titleInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < descriptionInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < universityIDInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < zenodoDigitalObjectIdentifierInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < locationFoundInstances){
          widgets.add(ModelDetails(model: model));
        }else if(0 < dateTimeFoundInstances){
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
          int universityIDInstances = modelDetails.model.universityID == null ? 0 : modelDetails.model.universityID!.instancesOf(widget.searchQuery.text);
          int zenodoDigitalObjectIdentifierInstances = modelDetails.model.zenodoDigitalObjectIdentifier.instancesOf(widget.searchQuery.text);
          int locationFoundInstances = modelDetails.model.locationFound == null ? 0 : modelDetails.model.locationFound!.instancesOf(widget.searchQuery.text);
          int dateTimeFoundInstances = modelDetails.model.dateTimeFound == null ? 0 : modelDetails.model.dateTimeFound!.toString().instancesOf(widget.searchQuery.text);
          return titleInstances +  descriptionInstances + universityIDInstances + zenodoDigitalObjectIdentifierInstances + locationFoundInstances + dateTimeFoundInstances;
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