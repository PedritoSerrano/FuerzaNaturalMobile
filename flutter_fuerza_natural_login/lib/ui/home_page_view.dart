import 'package:flutter/material.dart';

class HomePageView extends StatelessWidget {
  const HomePageView ({
    super.key,

    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('shared/logoFuerzaNatural.png', height: 250),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 60,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Username or Email',
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 300,
                height: 60,
                child: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text('Login', style: TextStyle(fontSize: 18, color: Colors.black) ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}