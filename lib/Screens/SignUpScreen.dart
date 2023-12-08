import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  RegExp validEmail = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool signUp = true;
  bool _isLoading = false;
  bool _isVisible = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (signUp)
                  ? const Text(
                      'Register',
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
              Column(
                children: [
                  (signUp)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                          child: TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                    child: TextFormField(
                      controller: _emailController,
                      validator: (signUp)
                          ? (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter Email';
                              } else if (!validEmail.hasMatch(value)) {
                                return 'Check your Email';
                              }
                            }
                          : null,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                    child: TextFormField(
                      controller: _passwordController,
                      validator: (signUp)
                          ? (value) {
                              if (value!.isEmpty) {
                                return 'Please Enter Password';
                              } else if (value.length < 8) {
                                return 'Password should be minimum of 8 characters';
                              }
                            }
                          : null,
                      obscureText: _isVisible,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                              icon: (!_isVisible)
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(11))),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                )),
                            onPressed: (_isLoading) ? null :() async {
                              if (signUp) {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _emailController.text.trim(),
                                            password:
                                                _passwordController.text.trim())
                                        .then((value) async {
                                            await value.user?.updateDisplayName(_nameController.text.trim());
                                            await firestore.collection('Users').add(
                                                {
                                                  'uid' : value.user?.uid,
                                                  'name' : _nameController.text.trim(),
                                                  'email' : _emailController.text.trim()
                                                });

                                          },
                                        );
                                  } on FirebaseException catch (e) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
                                  }

                                }
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                   FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim())
                                      .then(
                                    (value) async {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                                  );
                                } on FirebaseException catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString())));
                                }
                              }
                            },
                            child: (signUp)
                                ? (_isLoading) ? const CircularProgressIndicator() :const Text('Sign Up')
                                : (_isLoading) ? const CircularProgressIndicator() : const Text('Login'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        signUp = !signUp;
                      });
                    },
                    child: const Text.rich(TextSpan(children: [
                      TextSpan(text: 'Already a User?'),
                      TextSpan(
                          text: 'Login',
                          style:
                              TextStyle(decoration: TextDecoration.underline))
                    ])),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
