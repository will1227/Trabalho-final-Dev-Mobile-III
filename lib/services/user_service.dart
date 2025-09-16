class UserService {
  String initials(name) {
    //se o nome estiver vazio ou só espaço
    if (name.trim().isEmpty) return 'NO';

    //maria_da_silva maria-da-silva
    //Maria da Silva ['Maria', 'da', 'Silva]
    final normalized =
    name.replaceAll(RegExp(r'[_\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');

    final parts = normalized.split(' ');

    if (parts.isEmpty) return "NO";
    
    if (parts.length == 1) {
      _getTwoCharsFromName(parts.first);
    }

    String firstInitial = 
        parts.first.substring(0,1).toUpperCase();
    String lastInitial = 
        parts.last.substring(0,1).toUpperCase(); 

    return firstInitial + lastInitial;
  }

  String _getTwoCharsFromName(String s) {
    final ocorr = s.length >= 2 ? 2 : 1;
    return s.substring(0, ocorr).toUpperCase();
  }
}
