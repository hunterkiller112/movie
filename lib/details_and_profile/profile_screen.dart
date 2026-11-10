import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../account_screens/forgot_password_screen.dart';
import '../account_screens/login_screen.dart';
import '../account_screens/auth_service.dart';
import '../movie_catalog/movie_cards.dart';
import '../movie_catalog/movie_data.dart';
import '../movie_catalog/movie_storage.dart';
import 'movie_details_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool showHistory = false;

  Widget count(String label, int number) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            '$number',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Movie> savedMovies = MovieStorage.watchList;
    List<Movie> movieHistory = MovieStorage.history;
    List<Movie> movies = showHistory ? movieHistory : savedMovies;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: const Color(0xFF212121),
          child: Column(
            children: [
              if (!showHistory)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 52, 16, 8),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/avatar_${MovieStorage.profileAvatar}.png',
                                  height: 116,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  MovieStorage.profileName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          count('Wish List', savedMovies.length),
                          count('History', movieHistory.length),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    EditProfileScreen.routeName,
                                  );
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await AuthService.signOut();
                                    MovieStorage.userId = null;
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not sign out.'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    LoginScreen.routeName,
                                    (route) => false,
                                  );
                                },
                                iconAlignment: IconAlignment.end,
                                icon: const Icon(Icons.logout, size: 20),
                                label: const Text(
                                  'Exit',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              DefaultTabController(
                length: 2,
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(fontSize: 18),
                  dividerColor: Colors.transparent,
                  indicatorColor: AppTheme.yellow,
                  indicatorSize: TabBarIndicatorSize.tab,
                  onTap: (index) {
                    setState(() {
                      showHistory = index == 1;
                    });
                  },
                  tabs: const [
                    Tab(
                      height: 83,
                      icon: Icon(Icons.list, size: 30, color: AppTheme.yellow),
                      iconMargin: EdgeInsets.only(bottom: 4),
                      text: 'Watch List',
                    ),
                    Tab(
                      height: 83,
                      icon: Icon(
                        Icons.folder,
                        size: 30,
                        color: AppTheme.yellow,
                      ),
                      iconMargin: EdgeInsets.only(bottom: 4),
                      text: 'History',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (movies.isEmpty)
          SizedBox(
            height: 420,
            child: Center(
              child: Image.asset('assets/images/empty_movies.png', width: 124),
            ),
          )
        else
          GridView.count(
            primary: false,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 10,
            childAspectRatio: 0.68,
            children: [
              for (Movie movie in movies)
                MovieCard(
                  movie: movie,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      MovieDetailsScreen.routeName,
                      arguments: movie,
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String name = MovieStorage.profileName;
  String phone = MovieStorage.profilePhone;
  int avatar = MovieStorage.profileAvatar;
  bool savingProfile = false;

  void pickAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: GridView.count(
            shrinkWrap: true,
            padding: const EdgeInsets.all(18),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (int number = 1; number <= 9; number++)
                InkWell(
                  onTap: () {
                    setState(() {
                      avatar = number;
                    });
                    Navigator.pop(sheetContext);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: number == avatar ? const Color(0x807E6600) : null,
                      border: Border.all(color: AppTheme.yellow),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Image.asset('assets/images/avatar_$number.png'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateProfile() async {
    String? id = MovieStorage.userId;
    if (id == null ||
        savingProfile ||
        !(formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      savingProfile = true;
    });
    try {
      await MovieStorage.saveProfile(id, name, phone, avatar);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        savingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your profile.')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Avatar', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 38, 16, 20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: InkWell(
                  onTap: pickAvatar,
                  child: Image.asset(
                    'assets/images/avatar_$avatar.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                initialValue: phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your phone number';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                onChanged: (value) {
                  phone = value;
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      ForgotPasswordScreen.routeName,
                    );
                  },
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: savingProfile ? null : updateProfile,
              child: Text(savingProfile ? 'Saving...' : 'Update Data'),
            ),
          ),
        ),
      ),
    );
  }
}
