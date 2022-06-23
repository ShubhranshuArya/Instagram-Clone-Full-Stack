import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';

import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout.dart';

import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // This is done to initialize flutter web app with firebase.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBykwzqmWw2Mhl_Y4xEtEQo8Wf6J9hWj1U',
        appId: '1:417052441482:web:d7a78e07561001d729a673',
        messagingSenderId: '417052441482',
        projectId: 'instagram-clone-f99d3',
        // We have to add this in order to work with firebase storage.
        storageBucket: 'instagram-clone-f99d3.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // First check if the connection with the stream is active.
            if (snapshot.connectionState == ConnectionState.active) {
              // Now if the connected snapshot has data then the user has already logged in.
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout(),
                );
              }
              // If the connection has been made but there is some error.
              else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }
            // If snapshot doesn't have any data then it means the user has not logged in
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
