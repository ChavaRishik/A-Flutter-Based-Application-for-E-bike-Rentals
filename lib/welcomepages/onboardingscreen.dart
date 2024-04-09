import 'package:flutter/material.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:prayanaev/authentication/loginpage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF5FBF2), // Background color
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPage(
                  image: 'assets/images/prayanagreenlogo.png',
                  title: 'Welcome to Prayana',
                  description: 'Welcome to Prayana, the e-bike renting app.\nThrough this app, we are promoting intra-university eco transport.\nEnjoy the comfort of riding our e-bikes.',
                ),
                _buildPage(
                  image: 'assets/images/maps.png',
                  title: 'Go anywhere you want',
                  description: 'Prayana provides location of rental station locations, so you can easily see your one-stop-go and will provide you information about all the available e-bikes.',
                ),
                _buildPage(
                  image: 'assets/images/route.png',
                  title: 'Know your stats',
                  description: 'Prayana provides you with detailed history of all your rides. You can accordingly measure your subscription as per your needs.',
                  isLastPage: true,
                ),
              ],
            ),
            if (_currentPage == 2)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.12),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // Using MediaQuery for responsive width
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToLoginPage(context);
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(Color(0xFF69D84F)),
                      ),
                      child: _isLoading // Display loading animation if _isLoading is true
                        ? LoadingAnimationWidget.waveDots(
                      color: Colors.white,
                      size: 24,
                    )
                      : Text(
                        "Let's Go!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:  EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.20), // Adjusted padding value
                child: PageViewDotIndicator(
                  currentItem: _currentPage,
                  count: 3,
                  unselectedColor: Colors.black26,
                  selectedColor: Colors.blue,
                  size: const Size(12, 12),
                  unselectedSize: const Size(8, 8),
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  fadeEdges: false,
                  boxShape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String image,
    required String title,
    required String description,
    bool isLastPage = false,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25, // Position from top as percentage of screen height
            left: 0,
            right: 0,
            child: Image.asset(
              image,
              height: MediaQuery.of(context).size.height * 0.25, // Image height as percentage of screen height
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12, // Position from top as percentage of screen height
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05), // Font size as percentage of screen width
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6, // Position from top as percentage of screen height
            left: 15,
            right: 15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  description.replaceAll('\\n', '\n'), // Replace '\n' with actual line breaks
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035), // Font size as percentage of screen width
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    setState(() {
      _isLoading = true; // Start loading animation
    });

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

}
