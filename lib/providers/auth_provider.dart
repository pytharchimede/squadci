import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadCurrentUser();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }
  
  Future<void> _loadCurrentUser() async {
    if (_firebaseUser == null) return;
    
    try {
      _currentUser = await _firestoreService.getUser(_firebaseUser!.uid);
      notifyListeners();
    } catch (e) {
      print('Erreur chargement utilisateur: $e');
    }
  }
  
  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInAnonymously();
      if (user != null) {
        // Créer un profil utilisateur anonyme
        final userModel = UserModel(
          uid: user.uid,
          pseudo: _generateAnonymousPseudo(),
          quartierPrefere: 'Non défini',
          inscritAt: DateTime.now(),
          isAnonymous: true,
        );
        
        await _firestoreService.createUser(userModel);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur de connexion anonyme: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.signInWithEmail(email, password);
      return user != null;
    } catch (e) {
      _setError('Erreur de connexion: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> registerWithEmail(String email, String password, String pseudo, String quartier) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.registerWithEmail(email, password);
      if (user != null) {
        // Créer le profil utilisateur
        final userModel = UserModel(
          uid: user.uid,
          pseudo: pseudo,
          email: email,
          quartierPrefere: quartier,
          inscritAt: DateTime.now(),
          isAnonymous: false,
        );
        
        await _firestoreService.createUser(userModel);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur d\'inscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      _currentUser = null;
      _firebaseUser = null;
    } catch (e) {
      _setError('Erreur de déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateProfile({String? pseudo, String? quartier}) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    
    try {
      final updatedUser = _currentUser!.copyWith(
        pseudo: pseudo ?? _currentUser!.pseudo,
        quartierPrefere: quartier ?? _currentUser!.quartierPrefere,
      );
      
      await _firestoreService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur de mise à jour: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  String _generateAnonymousPseudo() {
    final adjectives = ['Cool', 'Super', 'Brave', 'Drôle', 'Gentil', 'Sympa'];
    final nouns = ['Gbaka', 'Attiéké', 'Bangui', 'Garba', 'Kedjo', 'Yako'];
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    
    final adjective = adjectives[random % adjectives.length];
    final noun = nouns[random % nouns.length];
    
    return '$adjective$noun$random';
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
