import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'home_screen.dart'; // 🔥 হোম স্ক্রিনে যাওয়ার জন্য

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 📝 ১. সব টেক্সট কন্ট্রোলার
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // সাইন আপের জন্য বাড়তি ফিল্ড
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLogin = true; // লগইন নাকি সাইন আপ পেজ
  bool _isLoading = false; // লোডিং দেখানোর জন্য
  bool _isPasswordVisible = false; // পাসওয়ার্ড লুকানো/দেখানো

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignInObj = GoogleSignIn();

  // 🔥 ২. গুগল সাইন-ইন ফাংশন
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);

    try {
      // গুগল পপ-আপ ওপেন করা
      final GoogleSignInAccount? googleUser = await _googleSignInObj.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // ইউজার ব্যাক করেছে
      }

      // অথেন্টিকেশন টোকেন নেওয়া
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ফায়ারবেস ক্রেডেনশিয়াল তৈরি (accessToken null রাখা হয়েছে v7 এর জন্য)
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // ফায়ারবেসে সাইন-ইন
      UserCredential userCred = await _auth.signInWithCredential(credential);
      User? user = userCred.user;

      if (user != null) {
        // ডাটাবেস চেক করা: ইউজার আগে থেকেই আছে কিনা
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // নতুন ইউজার হলে ডাটাবেসে সেভ
          String customId = "MIA-CT-${10000 + Random().nextInt(90000)}";

          // নাম আলাদা করা (First & Last Name)
          String fullName = user.displayName ?? "Unknown User";
          List<String> names = fullName.split(" ");
          String fName = names.isNotEmpty ? names[0] : "";
          String lName = names.length > 1 ? names.sublist(1).join(" ") : "";

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'email': user.email,
            'user_id': customId,
            'joined_at': DateTime.now().toIso8601String(),
            'photo_url': user.photoURL,
            'first_name': fName,
            'last_name': lName,
            'location': "Earth", // গুগলে লোকেশন পাওয়া যায় না, তাই ডিফল্ট
            'dob': "-",
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Google Login Successful!"),
                backgroundColor: Colors.green),
          );
          // হোম স্ক্রিনে পাঠানো
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Google Sign-In Error: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔥 ৩. পাসওয়ার্ড রিসেট ফাংশন (Forgot Password)
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter your email first!"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Password reset link sent to your email!"),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 🔥 ৪. জন্মতারিখ সিলেক্ট করার ফাংশন
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // 🔥 ৫. মেইন লগইন এবং সাইন-আপ ফাংশন
  Future<void> _submitAuthForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // নতুন ফিল্ডের ডাটা
    final fName = _firstNameController.text.trim();
    final lName = _lastNameController.text.trim();
    final location = _locationController.text.trim();
    final dob = _dobController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill email & password")));
      return;
    }

    // সাইন আপের সময় সব ফিল্ড চেক করা
    if (!_isLogin &&
        (fName.isEmpty || lName.isEmpty || location.isEmpty || dob.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all details")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // লগইন লজিক
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Welcome Back!"), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        // সাইন আপ লজিক
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String customId = "MIA-CT-${10000 + Random().nextInt(90000)}";

        // ডাটাবেসে সেভ
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'email': email,
          'user_id': customId,
          'joined_at': DateTime.now().toIso8601String(),
          'photo_url': "",
          'first_name': fName,
          'last_name': lName,
          'location': location,
          'dob': dob,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Account Created! Please Login."),
              backgroundColor: Colors.green));
          setState(() => _isLogin = true);
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? "Error"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ব্যাকগ্রাউন্ড গ্রেডিয়েন্ট
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364)
                ],
              ),
            ),
          ),
          // ব্যাকগ্রাউন্ড ইমেজ (Texture)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                "https://image.tmdb.org/t/p/original/uDgy6hyPd82kOHh6I95FLtLnj6p.jpg",
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox(),
              ),
            ),
          ),

          // মেইন ফর্ম (Glassmorphism UI)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // লোগো
                        if (_isLogin) ...[
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage('assets/images/app-logo.png'),
                          ),
                          const SizedBox(height: 15),
                        ],

                        Text(
                          _isLogin ? "Welcome Back" : "Create Profile",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        // 🔥 নতুন ফিল্ডস (শুধু সাইন আপের সময় দেখাবে)
                        if (!_isLogin) ...[
                          Row(
                            children: [
                              Expanded(
                                  child: _buildGlassTextField(
                                      controller: _firstNameController,
                                      icon: Icons.person,
                                      hint: "First Name")),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _buildGlassTextField(
                                      controller: _lastNameController,
                                      icon: Icons.person_outline,
                                      hint: "Last Name")),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildGlassTextField(
                              controller: _locationController,
                              icon: Icons.location_on,
                              hint: "Location (e.g. Dhaka)"),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: _buildGlassTextField(
                                  controller: _dobController,
                                  icon: Icons.calendar_today,
                                  hint: "Date of Birth"),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],

                        // ইমেইল এবং পাসওয়ার্ড (সব সময় থাকবে)
                        _buildGlassTextField(
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            hint: "Email"),
                        const SizedBox(height: 15),
                        _buildGlassTextField(
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hint: "Password",
                          isPassword: true,
                          isObscure: !_isPasswordVisible,
                          onEyePressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible),
                        ),

                        const SizedBox(height: 10),

                        // 🔥 Forgot Password বাটন
                        if (_isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _resetPassword,
                              child: const Text("Forgot Password?",
                                  style: TextStyle(color: Colors.amber)),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // লগইন / সাইন আপ বাটন
                        if (_isLoading)
                          const CircularProgressIndicator(color: Colors.amber)
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _submitAuthForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text(_isLogin ? "LOG IN" : "SIGN UP",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                              ),

                              // 🔥 Google Sign In Button
                              if (_isLogin) ...[
                                const SizedBox(height: 15),
                                const Text("OR",
                                    style: TextStyle(color: Colors.white54)),
                                const SizedBox(height: 15),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    onPressed: _googleSignIn,
                                    icon: const Icon(Icons.g_mobiledata,
                                        size: 35, color: Colors.white),
                                    label: const Text("Continue with Google",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.white30),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                        const SizedBox(height: 20),

                        // টগল বাটন (Switch between Login & Signup)
                        GestureDetector(
                          onTap: () => setState(() => _isLogin = !_isLogin),
                          child: RichText(
                            text: TextSpan(
                              text:
                                  _isLogin ? "New here? " : "Already member? ",
                              style: const TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: _isLogin ? "Register now" : "Log in",
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 হেল্পার উইজেট (কোড ছোট ও ক্লিন রাখার জন্য)
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onEyePressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white70),
                  onPressed: onEyePressed)
              : null,
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}
