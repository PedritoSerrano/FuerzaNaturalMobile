import 'package:flutter/material.dart';
import 'package:flutter_fuerza_natural_login/ui/dashboard_page.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView ({
    super.key,

    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.grey[200],
          padding: EdgeInsets.symmetric(vertical: 80),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
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
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('shared/logoGoogle.png', height: 30),
                          SizedBox(width: 10),
                          Text('Sign in with Google', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold) ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('shared/logoFacebook.png', height: 30),
                          SizedBox(width: 10),
                          Text('Sign in with Facebook', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold) ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('shared/logoLinkedin.png', height: 30),
                          SizedBox(width: 10),
                          Text('Sign in with LinkedIn', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold) ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('shared/logoGithub.png', height: 30),
                          SizedBox(width: 10),
                          Text('Sign in with GitHub', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold) ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}