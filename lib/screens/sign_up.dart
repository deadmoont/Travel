import 'package:flutter/material.dart';
import 'package:travel/screens/home_screen.dart';
import 'package:travel/screens/loginscreen.dart';
import 'package:travel/services/auth.dart';
import 'package:travel/widgets/snack_bar.dart';

import '../widgets/button.dart';
import '../widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //for controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  @override
  void despose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signupUser() async {
    String res = await AuthServices().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
    );
    //if signup then success else err
    if(res=="success"){
      setState(() {
          isLoading=true;
      });
      //navigate to next string
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
    else{
      setState(() {
          isLoading=false;
      });
      showSnackBar(context, res);
    }
  }


  @override
  Widget build(BuildContext context) {
    double height= MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(
              width: double.infinity,
              height: height/2.7,
              child: Image.asset('assets/images/signup.jpeg'),
            ),

            TextFieldInpute(
                textEditingController: nameController,
                hintText: "Enter Your Name",
                icon: Icons.person,
              ),

            TextFieldInpute(
              textEditingController: emailController,
              hintText: "Enter Your Email",
              icon: Icons.email,
            ),
            TextFieldInpute(
              textEditingController: passwordController,
              hintText: "Enter Your Password",
              isPass: true,
              icon: Icons.lock,
            ),
            MyButton(onTap: signupUser, text: "Sign Up"),
            SizedBox(height: height/15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an Account ?", style: TextStyle(fontSize: 16),),
                GestureDetector(onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      )
                  );
                },
                  child: Text(" LogIn", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
