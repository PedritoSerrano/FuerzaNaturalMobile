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
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('shared/logoFuerzaNatural.png', height: 250),
              SizedBox(
                width: 300,
                height: 120,
                child: Column(
                  children: [
                    Text("Sign In", style: TextStyle(fontSize: 40)),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text("Don't have an account? ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                        Text("Create account", style: TextStyle(color: const Color.fromARGB(255, 99, 122, 103), fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 400,
                height: 60,
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[350],
                    hintText: 'Enter your username or email',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none
                    ),
                    labelText: 'Username or Email',
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 400,
                height: 60,
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[350],
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none
                    ),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 15),
              Text('Forgot password?', style: TextStyle(color: const Color.fromARGB(255, 99, 122, 103), fontSize: 12)),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 155, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 99, 122, 103),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white) ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text('---------------------------------------------------- or ----------------------------------------------------', style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                ],
              ),
              SizedBox(height: 20),
              Row()
            ],
          ),
        ),
      ),
    );
  }
}