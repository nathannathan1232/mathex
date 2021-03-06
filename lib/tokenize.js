// Generated by CoffeeScript 1.9.3
(function() {
  var Token, YAML, build_tokens, tokenize;

  YAML = require('yamljs');

  Token = (function() {
    function Token(type, value) {
      this.type = type;
      this.value = value;
    }

    return Token;

  })();

  build_tokens = function(sources) {
    var i, j, len, res;
    res = [];
    for (j = 0, len = sources.length; j < len; j++) {
      i = sources[j];
      res = Array.prototype.concat(res, YAML.load(i).tokens);
    }
    return res;
  };

  tokenize = function(expression, config) {
    var action, i, j, len, match, reg, res, token, tokens;
    tokens = build_tokens(config.tokens);
    res = [];
    while (expression.length > 0) {
      for (j = 0, len = tokens.length; j < len; j++) {
        i = tokens[j];
        reg = new RegExp('^' + i.match, '');
        match = expression.match(reg);
        if (match) {
          break;
        }
      }
      if (!match) {
        console.log('Invalid token: ' + expression.slice(0, 10));
      }
      expression = expression.replace(reg, '');
      match = match.toString();
      match = match.replace(/^\s*/, '');
      action = i.action || 'push';
      switch (action) {
        case 'push':
          token = new Token(i.name, match);
          res.push(token);
          break;
        case 'discard':
          0;
          break;
        default:
          throw 'Invalid action ' + action;
      }
    }
    return res;
  };

  module.exports = tokenize;

}).call(this);
