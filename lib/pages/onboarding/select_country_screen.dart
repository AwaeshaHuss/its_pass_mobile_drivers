import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/l10n/app_localizations.dart';
import 'package:itspass_driver/main.dart';

class SelectCountryScreen extends StatefulWidget {
  const SelectCountryScreen({super.key});

  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {
  String selectedCountry = 'Jordan';
  String selectedLanguage = 'English';
  String selectedCountryCode = 'JO';
  String selectedLanguageCode = 'en';

  final List<Map<String, String>> countries = [
    {'name': 'Jordan', 'code': 'JO', 'flag': '🇯🇴', 'currency': 'JOD'},
    {'name': 'Syria', 'code': 'SY', 'flag': '🇸🇾', 'currency': 'SYP'},
  ];

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'العربية', 'code': 'ar', 'flag': '🇯🇴'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  _loadSavedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCountry = prefs.getString('selectedCountry') ?? 'Jordan';
      selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
      selectedCountryCode = prefs.getString('selectedCountryCode') ?? 'JO';
      selectedLanguageCode = prefs.getString('selectedLanguageCode') ?? 'en';
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountry', selectedCountry);
    await prefs.setString('selectedLanguage', selectedLanguage);
    await prefs.setString('selectedCountryCode', selectedCountryCode);
    await prefs.setString('selectedLanguageCode', selectedLanguageCode);
    
    // Save currency based on country
    String currency = countries.firstWhere(
      (country) => country['name'] == selectedCountry,
      orElse: () => {'currency': 'JOD'},
    )['currency']!;
    await prefs.setString('selectedCurrency', currency);
    
    print('Saved preferences: Country: $selectedCountry, Language: $selectedLanguage, Currency: $currency');
  }

  void _showCountrySelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.country ?? 'Country',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Countries list
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    final isSelected = selectedCountry == country['name'];
                    
                    return ListTile(
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        country['name'] == 'Jordan' ? (AppLocalizations.of(context)?.jordan ?? 'Jordan') : (AppLocalizations.of(context)?.syria ?? 'Syria'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey[700],
                        ),
                      ),
                      subtitle: Text(
                        'Currency: ${country['currency']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedCountry = country['name']!;
                          selectedCountryCode = country['code']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.language ?? 'Language',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Languages list
              ...languages.map((language) {
                final isSelected = selectedLanguage == language['name'];
                
                return ListTile(
                  leading: Text(
                    language['flag']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    language['name'] == 'English' ? (AppLocalizations.of(context)?.english ?? 'English') : (AppLocalizations.of(context)?.arabic ?? 'العربية'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedLanguage = language['name']!;
                      selectedLanguageCode = language['code']!;
                    });
                    Navigator.pop(context);
                    _changeLanguage(language['code']!);
                  },
                );
              }).toList(),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _saveAndContinue() async {
    await _savePreferences();
    
    // Navigate to register screen (mobile number entry)
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  void _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageCode', languageCode);
    
    // Trigger app restart using the proper method from main.dart
    if (mounted) {
      MyApp.restartApp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.selectCountryAndLanguage ?? 'Select Country & Language',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Text(
                AppLocalizations.of(context)?.selectCountryAndLanguage ?? 'Select Your Preferences',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                AppLocalizations.of(context)?.chooseCountryLanguage ?? 'Choose your country and language to customize your experience',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Country Selection Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _showCountrySelection,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            countries.firstWhere(
                              (country) => country['name'] == selectedCountry,
                              orElse: () => {'flag': '🇯🇴'},
                            )['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.country ?? 'Country',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedCountry == 'Jordan' ? (AppLocalizations.of(context)?.jordan ?? 'Jordan') : (AppLocalizations.of(context)?.syria ?? 'Syria'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Language Selection Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _showLanguageSelection,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            languages.firstWhere(
                              (language) => language['name'] == selectedLanguage,
                              orElse: () => {'flag': '🇺🇸'},
                            )['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.language ?? 'Language',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedLanguage == 'English' ? (AppLocalizations.of(context)?.english ?? 'English') : (AppLocalizations.of(context)?.arabic ?? 'العربية'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.saveAndContinue ?? 'Save Settings',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
