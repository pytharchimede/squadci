import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/password_strength_indicator.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pseudoController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedQuartier = Constants.defaultQuartiers.first;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _currentPassword = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _passwordController.addListener(_updatePassword);
    _confirmPasswordController.addListener(_updateConfirmPassword);
  }

  void _updatePassword() {
    setState(() {
      _currentPassword = _passwordController.text;
    });
  }

  void _updateConfirmPassword() {
    setState(() {
      _confirmPassword = _confirmPasswordController.text;
    });
  }

  bool _isSignupFormValid() {
    // Vérifier que les champs ne sont pas vides
    if (_emailController.text.trim().isEmpty ||
        _pseudoController.text.trim().isEmpty ||
        _currentPassword.isEmpty ||
        _confirmPassword.isEmpty) {
      return false;
    }

    // Vérifier que les mots de passe correspondent
    if (_currentPassword != _confirmPassword) {
      return false;
    }

    // Vérifier la force du mot de passe (au moins 3 critères sur 5)
    int criteriaCount = 0;
    if (_currentPassword.length >= 8) criteriaCount++;
    if (_currentPassword.contains(RegExp(r'[A-Z]'))) criteriaCount++;
    if (_currentPassword.contains(RegExp(r'[a-z]'))) criteriaCount++;
    if (_currentPassword.contains(RegExp(r'[0-9]'))) criteriaCount++;
    if (_currentPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      criteriaCount++;

    return criteriaCount >= 3;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passwordController.removeListener(_updatePassword);
    _confirmPasswordController.removeListener(_updateConfirmPassword);
    _emailController.dispose();
    _passwordController.dispose();
    _pseudoController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.signInAnonymously();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showSnackBar(
            authProvider.errorMessage ?? 'Erreur de connexion anonyme');
      }
    } catch (e) {
      _showSnackBar('Erreur de connexion: $e');
    }
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showSnackBar(authProvider.errorMessage ?? 'Erreur de connexion');
      }
    } catch (e) {
      _showSnackBar('Erreur de connexion: $e');
    }
  }

  Future<void> _registerWithEmail() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _pseudoController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    // Validation de l'email
    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar('Veuillez entrer un email valide');
      return;
    }

    // Validation du pseudo
    if (_pseudoController.text.trim().length < 3) {
      _showSnackBar('Le pseudo doit contenir au moins 3 caractères');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _pseudoController.text.trim(),
        _selectedQuartier,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showSnackBar(authProvider.errorMessage ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      _showSnackBar('Erreur d\'inscription: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryOrange,
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  // En-tête
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.groups,
                            size: 40,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Bienvenue sur SQUAD CI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'L\'application sociale ivoirienne',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton Connexion Anonyme
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _signInAnonymously,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text(
                                    'Commencer sans compte',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Formulaires de connexion/inscription
                  Container(
                    height: 370, // Réduit pour éviter l'overflow
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // TabBar
                        Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: AppColors.primaryOrange,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: AppColors.textGrey,
                            tabs: const [
                              Tab(text: 'Connexion'),
                              Tab(text: 'Inscription'),
                            ],
                          ),
                        ),

                        // TabBarView
                        Container(
                          height: 300, // Réduit de 320 à 300
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildSignInTab(),
                              _buildSignUpTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Mot de passe',
            icon: Icons.lock,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onPasswordToggle: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          const SizedBox(height: 30),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _signInWithEmail,
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Se connecter'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(
              controller: _pseudoController,
              label: 'Pseudo',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'Mot de passe',
              icon: Icons.lock,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onPasswordToggle: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmer le mot de passe',
              icon: Icons.lock,
              isPassword: true,
              isPasswordVisible: _isConfirmPasswordVisible,
              onPasswordToggle: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            // Indicateur de force du mot de passe
            PasswordStrengthIndicator(
              password: _currentPassword,
              confirmPassword: _confirmPassword,
            ),
            // Indicateur de correspondance des mots de passe
            if (_confirmPassword.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentPassword == _confirmPassword
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _currentPassword == _confirmPassword
                        ? Colors.green
                        : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentPassword == _confirmPassword
                          ? Icons.check_circle
                          : Icons.error,
                      color: _currentPassword == _confirmPassword
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentPassword == _confirmPassword
                          ? 'Les mots de passe correspondent'
                          : 'Les mots de passe ne correspondent pas',
                      style: TextStyle(
                        color: _currentPassword == _confirmPassword
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildQuartierDropdown(),
            const SizedBox(height: 30),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading || !_isSignupFormValid()
                        ? null
                        : _registerWithEmail,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('S\'inscrire'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onPasswordToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryOrange),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textGrey,
                ),
                onPressed: onPasswordToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.textGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryOrange),
        ),
      ),
    );
  }

  Widget _buildQuartierDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedQuartier,
      decoration: InputDecoration(
        labelText: 'Quartier préféré',
        prefixIcon:
            const Icon(Icons.location_on, color: AppColors.primaryOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryOrange),
        ),
      ),
      items: Constants.defaultQuartiers.map((quartier) {
        return DropdownMenuItem(
          value: quartier,
          child: Text(quartier),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedQuartier = value;
          });
        }
      },
    );
  }
}
