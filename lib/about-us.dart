import 'package:flutter/material.dart';
import 'package:the_pale_blue_dot_heritage_project/widgets.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: NavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset(
                "images/project-logo.png",
                width: 300,
              ),
              BoxOfText(
                title: "Why the name?", 
                file: "text-files/carl-sagan-quote.txt",
              ),
            ],
          ),
        ),
      ),
    );
  }
}