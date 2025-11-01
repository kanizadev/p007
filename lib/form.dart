import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with TickerProviderStateMixin {
  static const Color _textPrimary = Color.fromARGB(255, 237, 242, 230);
  static const Color _textSecondary = Color.fromARGB(255, 180, 200, 165);
  static const Color _accent = Color.fromARGB(255, 135, 169, 107); // Sage green
  static const Color _cardBackground = Color.fromARGB(255, 55, 64, 50);
  static const Color _fieldBackground = Color.fromARGB(255, 68, 78, 62);
  static const Color _borderColor = Color.fromARGB(255, 107, 123, 90);

  static const List<String> _trackOptions = <String>[
    'Mobile Development',
    'Web Development',
    'UI/UX Design',
    'Data & Analytics',
    'Project Management',
  ];

  static const List<String> _availabilityOptions = <String>[
    'Weekdays - Morning',
    'Weekdays - Afternoon',
    'Weekdays - Evening',
    'Weekends',
  ];

  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(
    text: '+880',
  );
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  int _currentStep = 0;
  final int _totalSteps = 4;
  DateTime? _dob;
  String? _selectedTrack;
  String? _preferredAvailability;
  bool _remoteFriendly = true;
  bool _termsAccepted = false;
  double _experience = 3;
  String? _photoUrl;
  File? _selectedImage;
  final Set<String> _selectedSkills = <String>{};
  bool _isLoading = false;
  bool _isSaving = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ConfettiController _confetti;

  // Real-time validation
  Timer? _validationTimer;
  final Map<String, String?> _fieldErrors = <String, String?>{};

  // Completion stats
  double get _completionPercentage {
    int completedFields = 0;
    int totalFields = 8;

    if (_nameController.text.trim().isNotEmpty) completedFields++;
    if (_emailController.text.trim().isNotEmpty) completedFields++;
    if (_phoneController.text.trim().isNotEmpty) completedFields++;
    if (_addressController.text.trim().isNotEmpty) completedFields++;
    if (_dob != null) completedFields++;
    if (_selectedTrack != null) completedFields++;
    if (_aboutController.text.trim().isNotEmpty) completedFields++;
    if (_selectedSkills.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _fadeController.forward();
    _slideController.forward();
    _loadSavedData();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.selectionClick();
  }

  void _triggerHapticSuccess() {
    HapticFeedback.mediumImpact();
  }

  void _triggerHapticError() {
    HapticFeedback.heavyImpact();
  }

  void _validateFieldDebounced(String fieldName, String value) {
    _validationTimer?.cancel();
    _validationTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        switch (fieldName) {
          case 'email':
            if (value.trim().isNotEmpty &&
                !RegExp(
                  r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value.trim())) {
              _fieldErrors[fieldName] = 'Invalid email format';
            } else {
              _fieldErrors[fieldName] = null;
            }
            break;
          case 'phone':
            if (value.trim().isNotEmpty) {
              final String digits = value.replaceAll(RegExp(r'\D'), '');
              // +880 is Bangladesh country code, needs at least 13 digits total (880 + 10 digits)
              if (value.startsWith('+880') && digits.length < 13) {
                _fieldErrors[fieldName] = 'Phone number too short';
              } else if (!value.startsWith('+880') && digits.length < 10) {
                _fieldErrors[fieldName] = 'Phone number too short';
              } else {
                _fieldErrors[fieldName] = null;
              }
            } else {
              _fieldErrors[fieldName] = null;
            }
            break;
          case 'name':
            if (value.trim().isNotEmpty && value.trim().split(' ').length < 2) {
              _fieldErrors[fieldName] = 'Please include first and last name';
            } else {
              _fieldErrors[fieldName] = null;
            }
            break;
        }
      });
    });
  }

  Future<void> _loadSavedData() async {
    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _nameController.text = prefs.getString('name') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '+880 XXXX XXXXXX';
      _addressController.text = prefs.getString('address') ?? '';
      _aboutController.text = prefs.getString('about') ?? '';

      // Validate saved dropdown values exist in options
      final String? savedTrack = prefs.getString('track');
      _selectedTrack = savedTrack != null && _trackOptions.contains(savedTrack)
          ? savedTrack
          : null;

      final String? savedAvailability = prefs.getString('availability');
      _preferredAvailability =
          savedAvailability != null &&
              _availabilityOptions.contains(savedAvailability)
          ? savedAvailability
          : null;
      _remoteFriendly = prefs.getBool('remoteFriendly') ?? true;
      _termsAccepted = prefs.getBool('termsAccepted') ?? false;
      _experience = prefs.getDouble('experience') ?? 3.0;
      _currentStep = prefs.getInt('currentStep') ?? 0;
      _photoUrl = prefs.getString('photoUrl');

      final String? skillsJson = prefs.getString('skills');
      if (skillsJson != null) {
        final List<dynamic> skills = jsonDecode(skillsJson);
        _selectedSkills.addAll(skills.cast<String>());
      }

      final String? dobString = prefs.getString('dob');
      if (dobString != null) {
        _dob = DateTime.parse(dobString);
        _dobController.text = _formatDate(_dob!);
      }

      if (_currentStep > 0) {
        _pageController.jumpToPage(_currentStep);
      }
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _autoSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('phone', _phoneController.text);
      await prefs.setString('address', _addressController.text);
      await prefs.setString('about', _aboutController.text);
      // Only save valid dropdown values
      if (_selectedTrack != null && _trackOptions.contains(_selectedTrack)) {
        await prefs.setString('track', _selectedTrack!);
      } else {
        await prefs.remove('track');
      }
      await prefs.setBool('remoteFriendly', _remoteFriendly);
      await prefs.setBool('termsAccepted', _termsAccepted);
      await prefs.setDouble('experience', _experience);
      await prefs.setInt('currentStep', _currentStep);
      if (_photoUrl != null) {
        await prefs.setString('photoUrl', _photoUrl!);
      }
      if (_dob != null) {
        await prefs.setString('dob', _dob!.toIso8601String());
      }
      await prefs.setString('skills', jsonEncode(_selectedSkills.toList()));
    } catch (e) {
      debugPrint('Error auto-saving: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _validationTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    _confetti.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _addListenerToControllers() {
    _nameController.addListener(_autoSave);
    _emailController.addListener(_autoSave);
    _phoneController.addListener(_autoSave);
    _addressController.addListener(_autoSave);
    _aboutController.addListener(_autoSave);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 43, 50, 38),
        body: const Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    _addListenerToControllers();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        centerTitle: true,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: _textPrimary),
                onPressed: _previousStep,
              )
            : const Icon(Icons.edit_note_outlined, color: _textPrimary),
        title: const Text(
          'Application Form',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: <Widget>[
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _textPrimary,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _textPrimary),
            color: _cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (String value) async {
              if (value == 'export') {
                await _exportData();
              } else if (value == 'share') {
                await _shareData();
              } else if (value == 'stats') {
                _showStats();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'stats',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.analytics_outlined, color: _textPrimary),
                    SizedBox(width: 12),
                    Text('View Stats', style: TextStyle(color: _textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.download_outlined, color: _textPrimary),
                    SizedBox(width: 12),
                    Text('Export JSON', style: TextStyle(color: _textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.share_outlined, color: _textPrimary),
                    SizedBox(width: 12),
                    Text('Share', style: TextStyle(color: _textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Reset form',
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh, color: _textPrimary),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF2B3226),
                Color(0xFF37402D),
                Color(0xFF434C38),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: Column(
                  children: <Widget>[
                    _buildProgressIndicator(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (int index) {
                          setState(() {
                            _currentStep = index;
                            _fadeController.reset();
                            _slideController.reset();
                            _fadeController.forward();
                            _slideController.forward();
                          });
                          _autoSave();
                        },
                        children: <Widget>[
                          _buildStep1(),
                          _buildStep2(),
                          _buildStep3(),
                          _buildStep4(),
                        ],
                      ),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const <Color>[_accent, _textPrimary, _textSecondary],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          SmoothPageIndicator(
            controller: _pageController,
            count: _totalSteps,
            effect: WormEffect(
              dotColor: _borderColor,
              activeDotColor: _accent,
              dotHeight: 10,
              dotWidth: 10,
              spacing: 8,
              type: WormType.thinUnderground,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: _borderColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_completionPercentage.toStringAsFixed(0)}% Complete',
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBackground.withValues(alpha: 0.8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back, color: _textPrimary),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textPrimary,
                  side: BorderSide(color: _accent.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _currentStep < _totalSteps - 1 ? _nextStep : _submit,
              icon: Icon(
                _currentStep < _totalSteps - 1
                    ? Icons.arrow_forward
                    : Icons.check,
              ),
              label: Text(_currentStep < _totalSteps - 1 ? 'Next' : 'Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      _triggerHapticFeedback();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _triggerHapticFeedback();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _exportData() async {
    final Map<String, dynamic> data = <String, dynamic>{
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'dateOfBirth': _dob?.toIso8601String(),
      'track': _selectedTrack,
      'availability': _preferredAvailability,
      'experience': _experience,
      'skills': _selectedSkills.toList(),
      'remoteFriendly': _remoteFriendly,
      'about': _aboutController.text,
      'photoUrl': _photoUrl,
      'completionPercentage': _completionPercentage,
      'exportedAt': DateTime.now().toIso8601String(),
    };

    final String jsonData = const JsonEncoder.withIndent('  ').convert(data);

    await Share.share(jsonData, subject: 'Application Form Data');

    _triggerHapticSuccess();
  }

  Future<void> _shareData() async {
    final StringBuffer shareText = StringBuffer();
    shareText.writeln('Application Form Summary\n');
    shareText.writeln('Name: ${_nameController.text}');
    shareText.writeln('Email: ${_emailController.text}');
    shareText.writeln('Phone: ${_phoneController.text}');
    shareText.writeln('Location: ${_addressController.text}');
    if (_selectedTrack != null) {
      shareText.writeln('Track: $_selectedTrack');
    }
    if (_preferredAvailability != null) {
      shareText.writeln('Availability: $_preferredAvailability');
    }
    shareText.writeln('Experience: ${_experience.toStringAsFixed(1)} years');
    if (_selectedSkills.isNotEmpty) {
      shareText.writeln('Skills: ${_selectedSkills.join(', ')}');
    }

    await Share.share(shareText.toString(), subject: 'My Application Form');

    _triggerHapticSuccess();
  }

  void _showStats() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Form Statistics',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildStatRow(
                'Completion',
                '${_completionPercentage.toStringAsFixed(0)}%',
              ),
              const Divider(color: _borderColor),
              _buildStatRow(
                'Current Step',
                '${_currentStep + 1} / $_totalSteps',
              ),
              const Divider(color: _borderColor),
              _buildStatRow('Skills Selected', '${_selectedSkills.length}'),
              const Divider(color: _borderColor),
              _buildStatRow(
                'Experience',
                '${_experience.toStringAsFixed(1)} years',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: _accent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: _textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty ||
            _nameController.text.trim().split(' ').length < 2) {
          _showError('Please enter your full name (first and last)');
          _triggerHapticError();
          return false;
        }
        return true;
      case 1:
        if (_emailController.text.trim().isEmpty ||
            !RegExp(
              r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
            ).hasMatch(_emailController.text.trim())) {
          _showError('Please enter a valid email address');
          _triggerHapticError();
          return false;
        }
        final String phoneDigits = _phoneController.text.replaceAll(
          RegExp(r'\D'),
          '',
        );
        if (_phoneController.text.trim().isEmpty ||
            (_phoneController.text.startsWith('+880') &&
                phoneDigits.length < 13) ||
            (!_phoneController.text.startsWith('+880') &&
                phoneDigits.length < 10)) {
          _showError('Please enter a valid phone number');
          _triggerHapticError();
          return false;
        }
        return true;
      case 2:
        if (_selectedTrack == null) {
          _showError('Please select a preferred track');
          _triggerHapticError();
          return false;
        }
        return true;
      case 3:
        if (_aboutController.text.trim().length < 20) {
          _showError('Please add more details (at least 20 characters)');
          _triggerHapticError();
          return false;
        }
        if (!_termsAccepted) {
          _showError('Please confirm the accuracy of your information');
          _triggerHapticError();
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(Icons.error_outline, color: _textPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStep1() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _glassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: <Widget>[
                    _buildProfilePhoto(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: _fieldDecoration(
                        label: 'Full Name',
                        hint: 'Enter your complete name',
                        icon: Icons.person_outline,
                      ).copyWith(errorText: _fieldErrors['name']),
                      textInputAction: TextInputAction.next,
                      onChanged: (String value) {
                        _validateFieldDebounced('name', value);
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: _fieldDecoration(
                        label: 'Date of Birth',
                        hint: 'Tap to choose your birth date',
                        icon: Icons.cake_outlined,
                        suffix: IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            color: _textPrimary,
                          ),
                          onPressed: _pickDob,
                        ),
                      ),
                      onTap: _pickDob,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _addressController,
                      decoration: _fieldDecoration(
                        label: 'Location',
                        hint: 'City, Country',
                        icon: Icons.location_on_outlined,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _sectionHeader(
                'Contact Information',
                Icons.contact_mail_outlined,
                subtitle: 'Share the essentials so we can stay in touch.',
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: _fieldDecoration(
                        label: 'Email Address',
                        hint: 'name@example.com',
                        icon: Icons.email_outlined,
                      ).copyWith(errorText: _fieldErrors['email']),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (String value) {
                        _validateFieldDebounced('email', value);
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _fieldDecoration(
                        label: 'Phone Number',
                        hint: '+880 1XXX XXXXXX',
                        icon: Icons.phone_outlined,
                      ).copyWith(errorText: _fieldErrors['phone']),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onChanged: (String value) {
                        _validateFieldDebounced('phone', value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: _accent, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _sectionHeader(
                'Professional Information',
                Icons.workspace_premium_outlined,
                subtitle: 'Choose your track and experience level.',
              ),
              const SizedBox(height: 24),
              _glassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Preferred Track',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the area you want to focus on',
                      style: TextStyle(color: _textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _trackOptions.map((String track) {
                        final bool isSelected = _selectedTrack == track;
                        return _buildTrackCard(track, isSelected);
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _glassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Years of Experience',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_experience.toStringAsFixed(1)} years',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _experience,
                      onChanged: (double value) {
                        _triggerHapticFeedback();
                        setState(() => _experience = value);
                        _autoSave();
                      },
                      min: 0,
                      max: 15,
                      divisions: 30,
                      activeColor: _accent,
                      inactiveColor: _borderColor,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '0',
                          style: TextStyle(
                            color: _textSecondary.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '15+',
                          style: TextStyle(
                            color: _textSecondary.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackCard(String track, bool isSelected) {
    final Map<String, IconData> trackIcons = <String, IconData>{
      'Mobile Development': Icons.phone_android,
      'Web Development': Icons.web,
      'UI/UX Design': Icons.design_services,
      'Data & Analytics': Icons.analytics,
      'Project Management': Icons.assignment,
    };

    return GestureDetector(
      onTap: () {
        _triggerHapticFeedback();
        setState(() => _selectedTrack = track);
        _autoSave();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _accent.withValues(alpha: 0.2)
              : _fieldBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accent : _borderColor.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? _accent.withValues(alpha: 0.3)
                    : _borderColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                trackIcons[track] ?? Icons.work_outline,
                color: isSelected ? _accent : _textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              track,
              style: TextStyle(
                color: isSelected ? _textPrimary : _textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
            if (isSelected) ...<Widget>[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: _accent, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _aboutController,
                      maxLines: 6,
                      decoration: _fieldDecoration(
                        label: 'About yourself',
                        hint:
                            'Share a short elevator pitch about your background, interests, and what makes you unique...',
                        icon: Icons.chat_bubble_outline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CheckboxListTile(
                      value: _termsAccepted,
                      onChanged: (bool? value) {
                        setState(() => _termsAccepted = value ?? false);
                        _autoSave();
                      },
                      activeColor: _accent,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'I confirm the details above are accurate to the best of my knowledge.',
                        style: TextStyle(color: _textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                _accent.withValues(alpha: 0.45),
                _accent.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: _fieldBackground,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : (_photoUrl != null ? NetworkImage(_photoUrl!) : null)
                      as ImageProvider?,
            child: _selectedImage == null && _photoUrl == null
                ? const Icon(Icons.person, size: 60, color: _textSecondary)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: _textPrimary,
              ),
            ),
            color: _cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (String value) async {
              if (value == 'gallery') {
                await _pickImage(ImageSource.gallery);
              } else if (value == 'camera') {
                await _pickImage(ImageSource.camera);
              } else if (value == 'url') {
                await _openPhotoDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'gallery',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.photo_library, color: _textPrimary),
                    SizedBox(width: 12),
                    Text(
                      'Choose from Gallery',
                      style: TextStyle(color: _textPrimary),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'camera',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.camera_alt, color: _textPrimary),
                    SizedBox(width: 12),
                    Text('Take Photo', style: TextStyle(color: _textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'url',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.link, color: _textPrimary),
                    SizedBox(width: 12),
                    Text('Enter URL', style: TextStyle(color: _textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _photoUrl = null;
        });
        _autoSave();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _openPhotoDialog() async {
    final TextEditingController urlController = TextEditingController(
      text: _photoUrl ?? '',
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Update profile photo',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Paste a direct image URL to refresh your avatar.',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                style: const TextStyle(color: _textPrimary),
                decoration: _fieldDecoration(
                  label: 'Image URL',
                  hint: 'https://example.com/photo.jpg',
                  icon: Icons.link,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: _textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _textPrimary,
              ),
              onPressed: () =>
                  Navigator.of(context).pop(urlController.text.trim()),
              child: const Text('Use Image'),
            ),
          ],
        );
      },
    );
    urlController.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() {
        _photoUrl = result;
        _selectedImage = null;
      });
      _autoSave();
    }
  }

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final DateTime now = DateTime.now();
    final DateTime initial =
        _dob ?? DateTime(now.year - 18, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 70),
      lastDate: DateTime(now.year - 12),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accent,
              surface: Color(0xFF37402D),
              onSurface: _textPrimary,
              onPrimary: _textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = _formatDate(picked);
      });
      _autoSave();
    }
  }

  String _formatDate(DateTime date) {
    const List<String> monthNames = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final String month = monthNames[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  void _resetForm() async {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.text = '+880';
    _addressController.clear();
    _aboutController.clear();
    _dobController.clear();
    setState(() {
      _dob = null;
      _selectedTrack = null;
      _preferredAvailability = null;
      _selectedSkills.clear();
      _experience = 3;
      _remoteFriendly = true;
      _termsAccepted = false;
      _photoUrl = null;
      _selectedImage = null;
      _currentStep = 0;
    });
    _pageController.jumpToPage(0);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_validateCurrentStep()) {
      return;
    }
    _showSummarySheet();
  }

  void _showSummarySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        final EdgeInsets insets = MediaQuery.of(context).viewInsets;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: insets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Review submission',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: _accent),
                    title: Text(
                      _nameController.text,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _selectedTrack ?? 'Track not selected',
                      style: const TextStyle(color: _textSecondary),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined, color: _accent),
                    title: Text(
                      _emailController.text,
                      style: const TextStyle(color: _textPrimary),
                    ),
                    subtitle: Text(
                      _phoneController.text.isEmpty
                          ? 'No phone number provided'
                          : _phoneController.text,
                      style: const TextStyle(color: _textSecondary),
                    ),
                  ),
                  if (_addressController.text.trim().isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: _accent,
                      ),
                      title: Text(
                        _addressController.text.trim(),
                        style: const TextStyle(color: _textPrimary),
                      ),
                      subtitle: const Text(
                        'Preferred location',
                        style: TextStyle(color: _textSecondary),
                      ),
                    ),
                  if (_dob != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cake_outlined, color: _accent),
                      title: Text(
                        _formatDate(_dob!),
                        style: const TextStyle(color: _textPrimary),
                      ),
                      subtitle: Text(
                        '${_experience.toStringAsFixed(1)} years experience',
                        style: const TextStyle(color: _textSecondary),
                      ),
                    ),
                  if (_preferredAvailability != null || _remoteFriendly)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time, color: _accent),
                      title: Text(
                        _preferredAvailability ?? 'Flexible availability',
                        style: const TextStyle(color: _textPrimary),
                      ),
                      subtitle: Text(
                        _remoteFriendly
                            ? 'Open to remote collaboration'
                            : 'Prefers on-site collaboration',
                        style: const TextStyle(color: _textSecondary),
                      ),
                    ),
                  if (_selectedSkills.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSkills
                            .map(
                              (String skill) => Chip(
                                backgroundColor: _fieldBackground,
                                label: Text(
                                  skill,
                                  style: const TextStyle(color: _textPrimary),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (_aboutController.text.trim().isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _fieldBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _aboutController.text.trim(),
                        style: const TextStyle(color: _textSecondary),
                      ),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      final ScaffoldMessengerState messenger =
                          ScaffoldMessenger.of(context);
                      Navigator.of(context).pop();
                      _confetti.play();
                      _triggerHapticSuccess();
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Application submitted successfully!'),
                        ),
                      );
                      if (mounted) {
                        _resetForm();
                      }
                    },
                    child: const Text('Confirm & Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: _textPrimary) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldBackground,
      labelStyle: const TextStyle(color: _textPrimary),
      hintStyle: const TextStyle(color: _textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return Card(
      elevation: 12,
      color: Colors.transparent,
      shadowColor: _accent.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: <Color>[Color(0x5A3A452E), Color(0x33323828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _borderColor.withValues(alpha: 0.35)),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
