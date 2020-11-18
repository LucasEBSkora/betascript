enum _logic { bsT, bsF, bsU }

const BSLogical bsTrue = BSLogical._("true", _logic.bsT);
const BSLogical bsFalse = BSLogical._("false", _logic.bsF);
const BSLogical bsUnknown = BSLogical._("unknown", _logic.bsU);

class BSLogical {
  final String _name;
  final _logic _value;

  const BSLogical._(this._name, this._value);

  factory BSLogical.fromBool(bool value) => (value) ? bsTrue : bsFalse;

  @override
  String toString() => _name;

  bool operator ==(other) {
    if (other is BSLogical) return _value == other._value;
    if (other is bool)
      return (other) ? (_value == _logic.bsT) : (_value == _logic.bsF);
    return false;
  }

  bool asBool() => _value == _logic.bsT;

  BSLogical operator &(BSLogical other) {
    if ((_value == _logic.bsU) | (other._value == _logic.bsU)) return bsUnknown;
    if ((_value == _logic.bsF) | (other._value == _logic.bsF)) return bsFalse;
    return bsTrue;
  }

  BSLogical operator |(BSLogical other) {
    if ((_value == _logic.bsU) | (other._value == _logic.bsU)) return bsUnknown;
    if ((_value == _logic.bsT) | (other._value == _logic.bsT)) return bsTrue;
    return bsFalse;
  }


  BSLogical operator ^(BSLogical other) {
    if ((_value == _logic.bsU) | (other._value == _logic.bsU)) return bsUnknown;
    return (other != this) ? bsTrue : bsFalse;
  }

  ///can't override !, so this makes the part of 'not'
  BSLogical operator -() => (_value == _logic.bsU)
      ? bsUnknown
      : ((_value == _logic.bsT) ? bsTrue : bsFalse);
}
