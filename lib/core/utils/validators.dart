class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isStrongPassword(String password) {
    // At least 8 characters
    if (password.length < 8) return false;

    // Check for at least one uppercase letter
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));

    // Check for at least one lowercase letter
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));

    // Check for at least one digit
    bool hasDigit = password.contains(RegExp(r'[0-9]'));

    // Check for at least one special character
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // For a strong password, require at least 3 of the 4 criteria
    int criteriaCount = 0;
    if (hasUppercase) criteriaCount++;
    if (hasLowercase) criteriaCount++;
    if (hasDigit) criteriaCount++;
    if (hasSpecialChar) criteriaCount++;

    return criteriaCount >= 3;
  }
}
