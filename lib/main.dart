// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_build_context_synchronously
// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; // Import this package to format the date

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tefillin/activity/activity_screen.dart';
import 'package:tefillin/firebase/firebase_uploads.dart';
import 'package:tefillin/groups/group_list.dart';
import 'package:tefillin/profile/group_list.dart';
import 'package:tefillin/signin/sign_in_widgets.dart';
import 'package:tefillin/posting/check_if_users_are_ready_to_posts.dart';
import 'package:tefillin/widgets/sign_in_with_email.dart';
import 'package:tefillin/wrapping_guide/wrapping_guide_screen.dart';
import '../profile/profile_page.dart';
import 'package:badges/badges.dart' as badges;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tefillin/feed/feed_screen.dart';
import 'package:tefillin/widgets/homepage.dart';
import 'package:navigator_scope/navigator_scope.dart';

import 'anonymous/sign_up.dart';
import 'activity/follower_requests/accept_follower_requests.dart';
import 'onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  // await FirebaseApi().initNotification();
  runApp(MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        fontFamily: 'Circular',
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
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Nested Navigator Example',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        darkTheme: buildDarkThemeData(),
        themeMode: ThemeMode.dark,
        home: TestRoute());
  }
}

Future<List<String>> _getFollowingIds(BuildContext context) async {
  String? currentUser = FirebaseAuth.instance.currentUser!.uid;
  if (currentUser == null) {
    return [];
  }

  final userDoc = await FirebaseFirestore.instance
      .collection("Users")
      .doc(currentUser)
      .get();

  if (!userDoc.exists) {
    print("true?");
    List<String> returnError = ["Error"];
    return returnError;
  }

  final List<String> userGroups = List<String>.from(userDoc['groups'] ?? []);
  final List<String> following = List<String>.from(userDoc['following'] ?? []);

  Set<String> userIds = Set.from(following); // Use a set for uniqueness
  for (String groupId in userGroups) {
    final groupDoc = await FirebaseFirestore.instance
        .collection("Groups")
        .doc(groupId)
        .get();
    final List<String> groupMembers =
        List<String>.from(groupDoc['users'] ?? []);
    userIds.addAll(groupMembers);
  }

  return userIds.toList();
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _feedScrollController = ScrollController();
  final ValueNotifier<bool> _showFABNotifier = ValueNotifier<bool>(false);

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      try {
        // await _uploadImageToFirebase(image);
        setState(() {
          _image = image;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CheckIfUsersAreReadyToPost(image: image),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Error: ', '')),
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
  void initState() {
    super.initState();

    _feedScrollController.addListener(() {
      if (_feedScrollController.offset > 2000 && !_showFABNotifier.value) {
        _showFABNotifier.value = true;
      } else if (_feedScrollController.offset <= 2000 &&
          _showFABNotifier.value) {
        _showFABNotifier.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _showFABNotifier,
            builder: (context, showFAB, child) {
              return Visibility(
                visible: showFAB,
                child: FloatingActionButton(
                  heroTag: null,
                  elevation: 0,
                  backgroundColor: Color.fromARGB(255, 68, 138, 25),
                  mini: true,
                  onPressed: () {
                    HapticFeedback.lightImpact();

                    _feedScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Icon(Icons.arrow_upward),
                ),
              );
            },
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.only(bottom: 0, right: 0),
            child: (!FirebaseAuth.instance.currentUser!.isAnonymous)
                ? GestureDetector(
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      _showOptions();
                    }, // handle the long press here
                    child: FloatingActionButton(
                      elevation: 0,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _openCamera();
                      },
                      child: Icon(Icons.camera_alt),
                    ),
                  )
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            HomepageTopBarWithNameAndIcons(
                scrollController: _feedScrollController),

            // SizedBox(height: 5),
            // SizedBox(height: 10),
            Expanded(child: FeedSection(controller: _feedScrollController)),
          ],
        ),
      ),
    );
  }

  void _showOptions() {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
        backgroundColor: Colors.black,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
              ),
            ),
            height: 230,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 15),
                Container(
                  height: 5.0,
                  width: size.width * .1,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 10),
                        Text('You putting on tefillin'),
                      ],
                    ),
                    onTap: () => _openCamera(),
                  ),
                ),
                Container(
                  height: 60,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.sentiment_satisfied_alt),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              'Another Jew putting on tefillin',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 139, 138, 138)),
                            ),
                            Text(
                              'Coming Soon',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // _chooseFromGallery(); // Add your method to choose from gallery here
                    },
                  ),
                ),
                // Add more options if you like
              ],
            ),
          );
        });
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
    'reports': 0
  });

  incrementStreak(currentUser!.uid);

  // Fetch user document from the 'Users' collection
  DocumentReference userRef =
      firestore.collection('Users').doc(currentUser?.uid);

  // Add the post document ID to the user's document
  await userRef.update({
    'posts': FieldValue.arrayUnion([postRef.id])
  });
}

class FeedSection extends StatefulWidget {
  const FeedSection({Key? key, required this.controller}) : super(key: key);

  final ScrollController controller;

  @override
  _FeedSectionState createState() => _FeedSectionState();
}

class _FeedSectionState extends State<FeedSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print("Entering feed section: ");
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {}); // refresh the feed
      },
      child: FutureBuilder<List<String>>(
        future: _getFollowingIds(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
                padding: EdgeInsets.only(top: 1000.0), child: Container());
          }
          if (snapshot.hasError) {
            print("hell nah");
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.data == null) {
            print("lets test");
            return Center(child: Text('No data available'));
          }

          if (snapshot.data!.isEmpty) {
            var size = MediaQuery.of(context).size;
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join groups to see posts and follow people"),
                SizedBox(height: 20),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GroupsMainPage(
                            selectedTab: 1,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Text("Join groups",
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          )),
                    ))
              ],
            ));
          }

          if (snapshot.data!.first == "Error") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OnboardingScreen(),
                ),
              );
            });
            return Container(); // Return an empty container or another widget
          }

          return FeedScreenss(
            followingIds: snapshot.data!,
            controller: widget.controller,
          );
        },
      ),
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
    NavigationDestination(label: 'Search', icon: Icon(Icons.search)),
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
    print("This is actually where to start: ");
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
                  return Center(child: Container());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }
                if (snapshot.data == null) {
                  return Center(child: Text('No data available'));
                }

                return Text("hi");
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
  var flag = false;
  bool _internetFlag = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    // if (!_internetFlag) {
    //   return NoInternetConnection(context);
    // }

    return Scaffold(
        body: SafeArea(
            child: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  }
                  if (snapshot.data != null) {
                    // return AutomaticSignout(text: "snapsh");

                    User user = snapshot.data as User;
                    DateTime creationTime = user.metadata.creationTime!;
                    DateTime currentTime = DateTime.now();
                    Duration difference = currentTime.difference(creationTime);

                    if (flag && snapshot.hasData) {
                      return MainScreen();
                    }

                    if (snapshot.hasData && difference.inSeconds > 10) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                            // return CircularProgressIndicator(); // show a loader while waiting
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.data!.exists) {
                            // The document with user.uid exists in the database
                            return MainScreen();
                          } else {
                            // The document with user.uid does not exist in the database
                            return OnboardingScreen(); // Replace with your own logic
                          }
                        },
                      );
                    }

                    return Container();
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TeffilinPictureAndBigText(),
                      Column(
                        children: [
                          // GuestSignIn(
                          //   onFlagChanged: _handleFlagChange,
                          // ),
                          SizedBox(height: 15),
                          EmailAndAppleSignInOptions(),
                          SizedBox(height: 15),
                          GoogleSignOption(),
                          SizedBox(height: 50),
                        ],
                      ),
                    ],
                  );
                }))));
  }

  Scaffold NoInternetConnection(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 60),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor,
        ),
        child:
            Text("There is no internet connection, please connect to internet"),
      )),
    );
  }

  void _handleFlagChange(bool newFlag) {
    setState(() {
      flag = newFlag;
    });
  }

  // add the _checkConnectivity method here
  _checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      setState(() {
        _internetFlag = false;
      });
    } else {
      // Internet connection is available
      setState(() {
        _internetFlag = true;
      });
    }
  }
}

class HomepageTopBarWithNameAndIcons extends StatefulWidget {
  const HomepageTopBarWithNameAndIcons(
      {super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<HomepageTopBarWithNameAndIcons> createState() =>
      _HomepageTopBarWithNameAndIconsState();
}

class _HomepageTopBarWithNameAndIconsState
    extends State<HomepageTopBarWithNameAndIcons> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              widget.scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Text("WrapIt",
                style: GoogleFonts.sigmarOne(
                    textStyle: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).accentColor))),
          ),
          Row(
            children: [
              StreamBuilder(
                  // add future stream that checks in Settings collection whether the document isCalendarPublicToAll has a 'value' of true or false
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    var isTefillinRequired =
                        snapshot.data!['settings.isTefillinHelpRequired'];

                    return isTefillinRequired
                        ? GestureDetector(
                            onTap: () async {
                              HapticFeedback.heavyImpact();
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => WrappingGuideScreen(),
                                ),
                              );

                              if (mounted && result != null && result) {
                                setState(() {
                                  // This will rebuild your widget when you return from the ProfilePage.
                                  // You can also use the result to conditionally rebuild or make updates.
                                });
                              }
                            },
                            child: Icon(
                              Icons.help_outline,
                              size: 27,
                            ),
                          )
                        : Container();
                  }),
              SizedBox(width: 20),
              if (!FirebaseAuth.instance.currentUser!.isAnonymous)
                StreamBuilder(
                    // add future stream that checks in Settings collection whether the document isCalendarPublicToAll has a 'value' of true or false
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      }

                      var numberOfFollowerRequested =
                          snapshot.data!['followers_requested'].length;

                      return GestureDetector(
                        onTap: () async {
                          // Go through every Users document and check if the current user's uid is in the followers_requested array
                          // If it is, then add it to the list of followers
                          // await FirebaseFirestore.instance
                          //     .collection("Users")
                          //     .get()
                          //     .then((value) => value.docs.forEach((element) {
                          //           element.reference.update({'blockedBy': []});
                          //         }));

                          HapticFeedback.heavyImpact();
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ActivityScreen(),
                            ),
                          );

                          if (mounted && result != null && result) {
                            setState(() {
                              // This will rebuild your widget when you return from the ProfilePage.
                              // You can also use the result to conditionally rebuild or make updates.
                            });
                          }
                        },
                        child: (numberOfFollowerRequested > 0)
                            ? badges.Badge(
                                badgeContent: Text("•"),
                                child: Icon(
                                  Icons.notifications,
                                  size: 27,
                                ),
                              )
                            : Icon(
                                Icons.notifications_outlined,
                                size: 27,
                              ),
                      );
                    }),
              if (!FirebaseAuth.instance.currentUser!.isAnonymous)
                SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GroupsMainPage(),
                    ),
                  );
                },
                child: Icon(
                  Icons.group_outlined,
                  size: 30,
                ),
              ),
              SizedBox(width: 20),
              if (FirebaseAuth.instance.currentUser!.isAnonymous)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignUp(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
              if (!FirebaseAuth.instance.currentUser!.isAnonymous)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact();
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );

                    if (mounted && result != null && result) {
                      setState(() {
                        // This will rebuild your widget when you return from the ProfilePage.
                        // You can also use the result to conditionally rebuild or make updates.
                      });
                    }
                  },
                  child: Icon(
                    Icons.person_outline,
                    size: 30,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
