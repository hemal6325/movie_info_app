import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 Firebase Import
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/trending_horizontal_list.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; // 🔥 ইমপোর্ট

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _inited = false;
  final ScrollController _scrollController = ScrollController();

  // 🔥 ইউজারের অবস্থা চেক করার ভেরিয়েবল
  User? _currentUser;

  final List<Map<String, dynamic>> genres = [
    {'id': 0, 'name': 'All'},
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 18, 'name': 'Drama'},
    {'id': 27, 'name': 'Horror'},
    {'id': 878, 'name': 'Sci-Fi'},
    {'id': 53, 'name': 'Thriller'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prov = Provider.of<MovieProvider>(context, listen: false);
        prov.loadPopular();
        _checkUser(); // অ্যাপ চালুর সময় ইউজার চেক করা
      });
      _inited = true;
    }
  }

  // 🔥 ইউজার চেক করার ফাংশন
  void _checkUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  void initState() {
    super.initState();

    // 🔥 লগইন/লগআউট লাইভ শোনার জন্য লিসেনার
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final prov = Provider.of<MovieProvider>(context, listen: false);
        if (!prov.isLoading) prov.loadPopular();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTrendingTab(String title, String value, MovieProvider prov) {
    final isSelected = prov.trendingTab == value;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          prov.setTrendingTab(value);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MovieProvider>(context);
    final movies = prov.popular;
    final selectedGenre = prov.selectedGenreId;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      // 🔥 আপডেটেড ড্রয়ার
      drawer: Drawer(
        backgroundColor: const Color(0xFF1e1e1e),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.amber),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  // 🔥 এখানে নাম বা ইমেইল দেখাবে
                  Text(
                    _currentUser != null
                        ? (_currentUser!.email ?? "User")
                        : "Welcome, Guest!",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16, // ইমেইল বড় হলে যাতে ধরে তাই সাইজ কমানো হলো
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _currentUser != null
                        ? "Synced with Firebase"
                        : "Sign in to sync data",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

            // 🔥 ডাইনামিক লগইন/লগআউট বাটন
            ListTile(
              leading: Icon(
                _currentUser != null ? Icons.logout : Icons.login,
                color: _currentUser != null ? Colors.redAccent : Colors.white,
              ),
              title: Text(
                _currentUser != null ? 'Logout' : 'Login / Sign Up',
                style: TextStyle(
                  color: _currentUser != null ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                Navigator.pop(context); // মেনু বন্ধ হবে

                if (_currentUser != null) {
                  // লগআউট লজিক
                  await FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logged Out Successfully!")),
                  );
                } else {
                  // লগইন পেজে যাওয়া
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // মেনু বন্ধ হবে

                if (_currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please Login first!")),
                  );
                  // চাইলে এখানে লগইন পেজেও পাঠিয়ে দিতে পারো
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                } else {
                  // 🔥 লগইন থাকলে প্রোফাইল পেজে যাবে
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),

            const Divider(color: Colors.grey),

            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text(
                'About App',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/app-logo.png',
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (c, o, s) => const Text(
            'Movie Info',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => prov.loadPopular(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(child: WelcomeBanner()),
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = selectedGenre == genre['id'];
                    return ActionChip(
                      label: Text(genre['name']),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: isSelected
                          ? Colors.amber
                          : Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.amber : Colors.grey[800]!,
                        ),
                      ),
                      onPressed: () {
                        if (!prov.isLoading) {
                          prov.setGenre(genre['id']);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            if (selectedGenre == 0 && prov.trending.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Trending",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTrendingTab("Today", "day", prov),
                            _buildTrendingTab("This Week", "week", prov),
                            _buildTrendingTab("Upcoming", "upcoming", prov),
                            _buildTrendingTab("Top Rated", "top_rated", prov),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: TrendingHorizontalList(movies: prov.trending),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
                child: Text(
                  selectedGenre == 0
                      ? "Popular Movies"
                      : "${genres.firstWhere((g) => g['id'] == selectedGenre)['name']} Movies",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            prov.isLoading && movies.isEmpty
                ? const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.55,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final m = movies[index];
                        return MovieCard(
                          movie: m,
                          imageBase: 'https://image.tmdb.org/t/p/',
                          size: 'w342',
                        );
                      }, childCount: movies.length),
                    ),
                  ),
            if (prov.isLoading && movies.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }
}
