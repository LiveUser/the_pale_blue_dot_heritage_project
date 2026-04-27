import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/about-us.dart';
import 'package:the_pale_blue_dot_heritage_project/digital-library.dart';
import 'package:the_pale_blue_dot_heritage_project/variables_and_functions.dart';
import 'package:the_pale_blue_dot_heritage_project/widgets.dart';
import 'package:http/http.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Pale Blue Dot Heritage Project',
      routes: {
        "home": (context)=> HomePage(),
        "about-us": (context)=> AboutUs(),
        "digital-library": (context)=> DigitalLibrary(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> fetchData()async{
    //print(url);
    Response response = await get(
      getRedirectURL("https://zenodo.org/records/19750457/files/default.glb?download=1"),
      headers: {
        //Not required by cloudflare proxy 'ngrok-skip-browser-warning': 'true', // This skips the ngrok landing page
        'Content-Type': 'model/gltf-binary',
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
      backgroundColor: Colors.white,
      appBar: appBar(),
      drawer: NavBar(),
      body: FutureBuilder(
        future: fetchData(), 
        builder: (context,asyncSnapshot){
          if(asyncSnapshot.hasError){
            return GestureDetector(
              onTap: (){
                setState(() {
                  
                });
              },
              child: Center(
                child: Column(
                  spacing: 10,
                  children: [
                    Text(
                      asyncSnapshot.error.toString(),
                    ),
                    Container(
                      color: Colors.orange,
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Reload",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }else if(asyncSnapshot.connectionState == ConnectionState.done){
            return SafeArea(
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: IconicModel(
                        base64Data: asyncSnapshot.data as String,
                      ),
                    ),
                  ),
                  AOTeachings(),
                ],
              ),
            );
          }else{
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            );
          }
        },
      ),
    );
  }
}
class IconicModel extends StatefulWidget {
  const IconicModel({
    super.key,
    required this.base64Data,
  });
  final String base64Data;
  @override
  State<IconicModel> createState() => _IconicModelState();
}

class _IconicModelState extends State<IconicModel> {
  
  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(
      builder: (context, orientation){
        if(orientation == Orientation.landscape){
          return Row(
            spacing: 5,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.70,
                height: MediaQuery.of(context).size.height,
                child: SuperModelViewer(
                  base64String: widget.base64Data,
                ),
              ),
              //Logo goes here
              Expanded(
                child: Image.asset(
                  "images/project-logo.png",
                ),
              ),
            ],
          );
        }else{
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 5,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  child: SuperModelViewer(
                    base64String: widget.base64Data,
                  ),
                ),
              ),
              //Logo goes here
              Expanded(
                child: Image.asset(
                  "images/project-logo.png",
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
class AOTeachings extends StatelessWidget {
  const AOTeachings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          color: Colors.orange,
          child: Text(
            "Free Open access for all beacause as they used to say in the Arecibo Observatory. \"Science is for humanity\"",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "SairaStencil",
            ),
          ),
        ),
      ],
    );
  }
}