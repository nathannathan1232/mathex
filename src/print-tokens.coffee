# A simple function to print out a tokenized math expression as
# a string.

color = require('./color.js')

colors =
	'number': 'blue'
	'operator': 'cyan'
	'string': 'yellow'
	'annotation': 'red'
	'function_define': 'green'
	'default': 'white'
	'keyword': 'magenta'

# Whether or not a token can have a space before/after
spaces =
	'number': [true, true]
	'operator': [true, true]
	'open_parinthesis': [true, false]
	'close_parinthesis': [false, true]
	'variable': [true, true]
	'function_call': [true, false]
	'comma': [false, true]
	'line_end': [false, true]

print_tokens = (tokens) ->
	res = ''

	for i in [0...tokens.length]
		c = if colors.hasOwnProperty(tokens[i].type)
			colors[tokens[i].type]
		else
			colors['default']

		v = color(
				tokens[i].value
				c
			)

		next_space =
			if i < tokens.length - 1 and spaces.hasOwnProperty(tokens[i + 1].type)
				spaces[tokens[i + 1].type][0]
			else
				true

		this_space =
			if spaces.hasOwnProperty(tokens[i].type)
				spaces[tokens[i].type][1]
			else
				true

		space =
			if this_space and next_space
				' '
			else
				''
		
		res += v + space

	res.replace(/\ $/, '')

module.exports = print_tokens