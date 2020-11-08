class DirectiveManager {
  ///directives are commands that can affect how the rest of the program is run. Some take effect anywhere in the code (global directives),
  ///and others only affect the code after them (local directives)
  final Map<String, Object> _globalDirectives =  {
    //if this directive is activated, the program will run with twitter restrictions, which means while and for loops, as well as defining
    //and calling routines and creating classes is forbidden, to avoid endless loops blocking the bot
    "bs_tt_interpret": false,
  };

  final Map<String, Object> _localDirectives = <String, Object>{};

  DirectiveManager();

  bool isGlobal(String dir) => _globalDirectives.containsKey(dir);

  void setDirective(String dir, Object value) {
    if (_globalDirectives.containsKey(dir)) {
      _globalDirectives[dir] = value;
    } else {
      _localDirectives[dir] = value;
    }
  }

  ///wheter the directive was set
  bool setIfGlobal(String dir, Object value) {
    if (isGlobal(dir)) {
      _globalDirectives[dir] = value;
      return true;
    } else {
      return false;
    }
  }

  Object getDirective(String dir) {
    if (_globalDirectives.containsKey(dir)) return _globalDirectives[dir];
    if (_localDirectives.containsKey(dir)) return _localDirectives[dir];
    return null;
  }
}
