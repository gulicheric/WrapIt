// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use
// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:intl/intl.dart'; // Import this package to format the date

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:tefillin/widgets/group_list.dart';
import '../profile/profile_page.dart';

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tefillin/profile/profile_page.dart';
import 'package:tefillin/widgets/feed_screen.dart';
import 'package:tefillin/widgets/homepage.dart';
import 'package:navigator_scope/navigator_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColorDark = Color(0xFF212121);
    const Color secondaryColorDark = Color.fromARGB(255, 22, 131, 194);
    const Color backgroundColorDark = Color.fromARGB(255, 0, 0, 0);
    const Color cardColorDark = Color(0xFF424242);
    const Color textColorDark = Color(0xFFE0E0E0);
    const Color pink = Color.fromARGB(255, 93, 196, 255);

    ThemeData buildDarkThemeData() {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColorDark,
        accentColor: secondaryColorDark,
        backgroundColor: backgroundColorDark,
        cardColor: cardColorDark,
        scaffoldBackgroundColor: backgroundColorDark,
        shadowColor: pink,
        disabledColor: textColorDark,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: textColorDark),
          bodyText2: TextStyle(color: textColorDark),
          headline1: TextStyle(color: textColorDark),
          headline2: TextStyle(color: textColorDark),
          headline3: TextStyle(color: textColorDark),
          headline4: TextStyle(color: textColorDark),
          headline5: TextStyle(color: textColorDark),
          headline6: TextStyle(color: textColorDark),
          subtitle1: TextStyle(color: textColorDark),
          subtitle2: TextStyle(color: textColorDark),
          caption: TextStyle(color: textColorDark),
          button: TextStyle(color: textColorDark),
          overline: TextStyle(color: textColorDark),
        ),
      );
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nested Navigator Example',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        darkTheme: buildDarkThemeData(),
        themeMode: ThemeMode.dark,
        home: TestRoute());

    return MaterialApp(
      title: 'Nested Navigator Example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      darkTheme: buildDarkThemeData(),
      themeMode: ThemeMode.dark,
      home: const Home(),
    );

    return MaterialApp.router(
      routerConfig: _router,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: buildDarkThemeData(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(child: TestRoute()),
      ),
    );
  }
}

Future<List<String>> _getFollowingIds(BuildContext context) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    return [];
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference userDocRef =
      firestore.collection('Users').doc(currentUser.uid);
  DocumentSnapshot userDoc = await userDocRef.get();

  List<String> followingIds =
      List<String>.from(userDoc.get('following') as List<dynamic>);
  return followingIds;
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const FeedScreen(
          followingIds: [],
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          builder: (BuildContext context, GoRouterState state) {
            return FeedScreen(
              followingIds: [],
            );
          },
        ),
      ],
    ),
  ],
);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      try {
        await _uploadImageToFirebase(image);
        setState(() {
          _image = image;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            showCloseIcon: true,
            duration: Duration(seconds: 10),
          ),
        );
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 0, right: 0),
        child: FloatingActionButton(
          elevation: 0,
          onPressed: _openCamera,
          child: Icon(Icons.camera_alt),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("WrapIt",
                      style: GoogleFonts.sigmarOne(
                          textStyle: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).accentColor))),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GroupsMainPage(),
                          ),
                        ),
                        child: Icon(
                          Icons.group,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                          onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(),
                                ),
                              ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                          )),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: FeedSection()),
          ],
        ),
      ),
    );
  }
}

Future<void> _uploadImageToFirebase(File image) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get the identifier from the authentication
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Get the user's latest post
  QuerySnapshot querySnapshot = await firestore
      .collection('Posts')
      .where('postedBy', isEqualTo: currentUser?.uid)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .get();

  if (!querySnapshot.docs.isEmpty) {
    // Compare the date of the latest post with today's date
    DateTime latestPostDate =
        DateTime.parse(querySnapshot.docs.first.get('createdAt')).toLocal();

    DateTime now = DateTime.now();

    if (latestPostDate.year == now.year &&
        latestPostDate.month == now.month &&
        latestPostDate.day == now.day) {
      throw Exception(
          "Sorry 😢 - You only need to put tefillin on once a day, so you can only post once a day");
    }
  }

  // Generate a unique file name for the image
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();

  // Create a reference to the Firebase Storage location
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('images/$fileName');

  // Upload the image to Firebase Storage
  UploadTask uploadTask = ref.putFile(image);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

  // Get the download URL for the uploaded image
  String downloadURL = await taskSnapshot.ref.getDownloadURL();

  CollectionReference imagesCollection = firestore.collection('Posts');

  DateTime now = DateTime.now();
  String createdAt = now.toUtc().toIso8601String();
  String dateManipulated = DateFormat('EEEE, MMMM d').format(now);

  // Add the new fields to the document
  DocumentReference postRef = await imagesCollection.add({
    'url': downloadURL,
    'createdAt': createdAt,
    'dateManipulated': dateManipulated,
    'likes': [],
    'likeCount': 0,
    'postedBy': currentUser?.uid,
    'caption': "",
  });

  // Fetch user document from the 'Users' collection
  DocumentReference userRef =
      firestore.collection('Users').doc(currentUser?.uid);

  // Add the post document ID to the user's document
  await userRef.update({
    'posts': FieldValue.arrayUnion([postRef.id])
  });
}

class FeedSection extends StatelessWidget {
  const FeedSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getFollowingIds(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.data == null) {
          return Center(child: Text('No data available'));
        }

        return FeedScreen(followingIds: snapshot.data!);
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;

  final tabs = const [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: 'Feed',
    ),
    NavigationDestination(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final navigatorKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'Search Tab'),
    GlobalKey<NavigatorState>(debugLabel: 'Cart Tab'),
  ];

  NavigatorState get currentNavigator =>
      navigatorKeys[currentTab].currentState!;

  void onTabSelected(int tab) {
    if (tab == currentTab && currentNavigator.canPop()) {
      // Pop to the first route in the current navigator' stack
      // if the current tab is tapped again.
      currentNavigator.popUntil((route) => route.isFirst);
    } else {
      setState(() => currentTab = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = NavigatorScope(
      currentDestination: currentTab,
      destinationCount: tabs.length,
      destinationBuilder: (context, index) {
        if (index == 0) {
          return NestedNavigator(
            navigatorKey: navigatorKeys[index],
            builder: (context) => FutureBuilder<List<String>>(
              future: _getFollowingIds(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }
                if (snapshot.data == null) {
                  return Center(child: Text('No data available'));
                }

                return FeedScreen(followingIds: snapshot.data!);
              },
            ),
          );
        }

        return NestedNavigator(
            navigatorKey: navigatorKeys[index],
            builder: (context) => ProfilePage());
      },
    );

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        destinations: tabs,
        onDestinationSelected: onTabSelected,
      ),
      body: body,
    );
  }
}

class ExampleTabView extends StatefulWidget {
  const ExampleTabView({
    super.key,
    this.depth = 0,
    required this.tabName,
  });

  final int depth;
  final String tabName;

  @override
  State<ExampleTabView> createState() => _ExampleTabViewState();
}

Color randomColor() => Color.fromARGB(
      160,
      Random().nextInt(155) + 100,
      Random().nextInt(155) + 100,
      Random().nextInt(155) + 100,
    );

class _ExampleTabViewState extends State<ExampleTabView> {
  final color = randomColor();
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.tabName} (depth=${widget.depth})')),
      body: ColoredBox(
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExampleTabView(
                        depth: widget.depth + 1,
                        tabName: widget.tabName,
                      ),
                    ),
                  );
                },
                child: const Text('Go deeper 🐡'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Show dialog'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => counter++);
                },
                child: const Text('Increment'),
              ),
              const SizedBox(height: 24),
              Text(
                'Counter: $counter',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/details'),
              child: const Text('Go to the Details screen'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The details screen
class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen]
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <ElevatedButton>[
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go back to the Home screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestRoute extends StatefulWidget {
  const TestRoute({Key? key}) : super(key: key);

  @override
  State<TestRoute> createState() => _TestRouteState();
}

class _TestRouteState extends State<TestRoute> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          var size = MediaQuery.of(context).size;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error");
          } else if (snapshot.hasData) {
            return MainScreen();
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 200),
                  SizedBox(
                      width: size.width * .8,
                      child: Image.asset('assets/images/tefillin.png')),
                  Text("One day at a time",
                      style: GoogleFonts.sigmarOne(
                          textStyle: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 224, 117, 128))))
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                      onTap: () async {
                        try {
                          final googleSignIn = GoogleSignIn();
                          GoogleSignInAccount? user;
                          final googleUser = await googleSignIn.signIn();
                          if (googleUser == null) return;
                          user = googleUser;

                          final googleAuth = await googleUser.authentication;
                          final credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken);

                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .signInWithCredential(credential);
                          User? firebaseUser = userCredential.user;

                          // Check if user exists in the Users collection
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;
                          DocumentReference userDocRef = firestore
                              .collection('Users')
                              .doc(firebaseUser!.uid);
                          DocumentSnapshot userDoc = await userDocRef.get();

                          if (!userDoc.exists) {
                            // Add user to the Users collection
                            String username = user.email.split('@')[0];
                            DateTime now = DateTime.now();
                            String createdAt = now.toUtc().toIso8601String();

                            await userDocRef.set({
                              'username': username,
                              'createdAt': createdAt,
                              'following': [],
                              'followers': [],
                              'posts': [],
                              'photoUrl': ""
                            });
                          }
                        } on PlatformException catch (e) {
                          if (e.code == 'sign_in_canceled') {
                            // The user has canceled the sign-in process
                            if (kDebugMode) {
                              print('User canceled sign-in');
                            }
                          } else {
                            // Handle other errors
                            if (kDebugMode) {
                              print('Error during sign-in: $e');
                            }
                          }
                        } catch (e) {
                          // Handle other exceptions
                          if (kDebugMode) {
                            print('Unexpected error during sign-in: $e');
                          }
                        }

                        setState(() {});
                      },
                      child: ContinueWithGoogleWidget()),
                  SizedBox(height: 50),
                ],
              ),
            ],
          );
        }),
      ),
    ));
  }
}

class ContinueWithGoogleWidget extends StatelessWidget {
  const ContinueWithGoogleWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(width: 3, color: Color.fromARGB(255, 224, 117, 128)),
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
              "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-suite-everything-you-need-know-about-google-newest-0.png",
              height: 30,
              width: 30),
          SizedBox(width: 10),
          Text(
            "Continue with Google",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 224, 117, 128)),
          )
        ],
      ),
    );
  }
}
