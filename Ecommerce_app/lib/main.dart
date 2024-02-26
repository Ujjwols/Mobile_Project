import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Ecommerce_app/screens/auth/forget_password_screen.dart';
import 'package:Ecommerce_app/screens/auth/login_screen.dart';
import 'package:Ecommerce_app/screens/auth/register_screen.dart';
import 'package:Ecommerce_app/screens/dashboard.dart';
import 'package:Ecommerce_app/screens/product/add_product_screen.dart';
import 'package:Ecommerce_app/screens/product/edit_product_screen.dart';
import 'package:Ecommerce_app/screens/product/my_product_screen.dart';
import 'package:Ecommerce_app/screens/product/single_product_screen.dart';
import 'package:Ecommerce_app/screens/splash_screen.dart';
import 'package:Ecommerce_app/services/local_notification_service.dart';
import 'package:Ecommerce_app/viewmodels/auth_viewmodel.dart';
import 'package:Ecommerce_app/viewmodels/category_viewmodel.dart';
import 'package:Ecommerce_app/viewmodels/global_ui_viewmodel.dart';
import 'package:Ecommerce_app/viewmodels/product_viewmodel.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Ecommerce_app/screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalUIViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
      ],
      child: OverlayKit(
        child: Consumer<GlobalUIViewModel>(builder: (context, loader, child) {
          return MaterialApp(
            title: 'ecommerce app',
            debugShowCheckedModeBanner: false,
            color: Colors.white,
            theme: ThemeData(
              fontFamily: "Poppins",
              primarySwatch: Colors.brown,
              textTheme: GoogleFonts.aBeeZeeTextTheme(),
              backgroundColor: Colors.white,
            ),
            initialRoute: "/splash",
            routes: {
              "/login": (BuildContext context) => LoginScreen(),
              "/splash": (BuildContext context) => SplashScreen(),
              "/register": (BuildContext context) => RegisterScreen(),
              "/forget-password": (BuildContext context) =>
                  ForgetPasswordScreen(),
              "/dashboard": (BuildContext context) => DashboardScreen(),
              "/add-product": (BuildContext context) => AddProductScreen(),
              "/edit-product": (BuildContext context) => EditProductScreen(),
              "/single-product": (BuildContext context) =>
                  SingleProductScreen(),
              "/my-products": (BuildContext context) => MyProductScreen(),
              "/edit-profile": (BuildContext context) =>
                  EditProfileScreen(), // Add the route for EditProfileScreen
            },
          );
        }),
      ),
    );
  }
}
