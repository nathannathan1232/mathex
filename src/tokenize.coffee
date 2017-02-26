# This is the tokenizer for Mathex
# It takes a string and converts it into tokens

YAML = require('yamljs')

class Token
	constructor: (type, value) ->
		@type = type
		@value = value

# Loads token definitions from yaml files and builds them into one object.
build_tokens = (sources) ->
	res = []
	for i in sources
		res = Array::concat res, YAML.load(i).tokens
	res

tokenize = (expression, config) ->
	# Build tokens from config.
	tokens = build_tokens(config.tokens)

	res = []
	# Keep finding and removing tokens until the original expression is
	# nothing.
	while expression.length > 0
		
		# Try every token until one of them is found.
		for i in tokens
			reg = new RegExp('^' + i.match, '')
			match = expression.match reg
			break if match

		unless match
			console.log 'Invalid token: ' + expression.slice(0, 10)

		# Remove the token from the beginning of the expression.
		expression = expression.replace(reg, '')
		match = match.toString()

		match = match.replace(/^\s*/, '')
		# If an action is specified, do what it says.
		# Default to push.
		action = i.action || 'push'

		switch action
			when 'push'
				token = new Token(i.name, match)
				res.push token
			when 'discard'
				0
			else
				throw 'Invalid action ' + action

	res

module.exports = tokenize