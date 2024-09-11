import 'package:flutter/material.dart';
import 'package:travel/screens/home_screen.dart';
import 'package:travel/screens/sign_up.dart';
import 'package:travel/widgets/button.dart';
import 'package:travel/widgets/text_field.dart';

import '../services/auth.dart';
import '../widgets/snack_bar.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState()=> _SignupScreenState();
}
class _SignupScreenState extends State<LoginScreen>{
  //for controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void despose(){
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void loginUser() async {
    String res = await AuthServices().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    //if signup then success else err
    if(res=="success"){
      setState(() {
        isLoading=true;
      });
      //navigate to next string
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
    else{
      setState(() {
        isLoading=false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build (BuildContext context ){
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
              child: Image.asset('assets/images/login.jpg'),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35,),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text("Forgot Password?",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue
                ),),),
            ),
            MyButton(onTap: loginUser, text: "Log In"),
            SizedBox(height: height/15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an Account ?", style: TextStyle(fontSize: 16),),
                GestureDetector(onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      )
                    );
                },
                  child: Text(" SignUp", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
