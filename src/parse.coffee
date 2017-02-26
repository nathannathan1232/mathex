# This is the parser for Mathex.
# It takes a list of tokens and parses it into a tree.

class Node
	constructor: (type, value) ->
		@type = type
		@value = value

OPERATORS = [
	['=', ':=', '+=', '-=', '*=', '/=', '%=', '.=']
	['^']
	['&&', '&']
	['||', '|']
	['>', '<', '==', '!=', '>=', '<=', '~~']
	['.']
	['<<', '>>']
	['+', '-']
	['*', '/', '%']
	['**']
]

priority = (op) ->
	for i in [0...OPERATORS.length]
		return i if OPERATORS[i].includes op

remove_padding = (tokens) ->
	if ['open_parinthesis', 'close_parinthesis'].includes tokens[0].type
		tokens.shift()

	if ['open_parinthesis', 'close_parinthesis'].includes tokens[tokens.length - 1].type
		tokens.pop()

is_one_function_call = (tokens) ->
	indents = 0
	for i in [0...tokens.length]
		if ['open_parinthesis', 'function_call'].includes tokens[i].type
			indents += 1
		else if ['close_parinthesis'].includes tokens[i].type
			indents -= 1

		if indents < 1 and i > 0 and i < tokens.length - 1
			return false

	return true if (
		tokens[0].type is 'function_call'
	)

is_function_define = (tokens) ->
	for i in tokens
		if i.type is 'function_define'
			return true
	false

least_important_operator = (tokens) ->
	index = 0
	p = Infinity
	indents = 1

	for i in [0...tokens.length]
		if tokens[i].type is 'operator' and priority(tokens[i].value) * indents < p
			index = i
			p = priority(tokens[i].value) * indents
		else if ['open_parinthesis', 'function_call'].includes tokens[i].type
			indents += 1
		else if ['close_parinthesis'].includes tokens[i].type
			indents -= 1

	index

split_at_index = (tokens, i) ->
	tokens = JSON.parse JSON.stringify tokens
	left = []

	for j in [0...i]
		left.push tokens.shift()

	# Remove the operator
	tokens.shift()

	[left, tokens]

split_by_line = (tokens) ->
	tokens = JSON.parse JSON.stringify tokens
	
	res = []
	while tokens.length > 0
		res.push []
		until tokens.length < 1 or tokens[0].type is 'line_end'
			res[res.length - 1].push tokens.shift()
		tokens.shift()
	res

get_block = (tokens) ->
	stack = []
	indents = 0
	while tokens.length > 0 and indents >= 0
		switch tokens[0].type
			when 'block_start' then indents += 1
			when 'block_end' then indents -= 1
		stack.push tokens.shift()

	stack

get_next_param = (tokens) ->
	stack = []
	indents = 0
	while tokens.length > 0
		if ['open_parinthesis', 'function_call'].includes tokens[0].type
			indents += 1
		else if ['close_parinthesis'].includes tokens[0].type
			indents -= 1

		if (tokens[0].type is 'comma' and indents < 1) or tokens.length < 1
			tokens.shift()
			return stack

		stack.push tokens.shift()

	return stack

parse_params = (tokens) ->
	res = []
	while tokens.length > 0
		res.push parse_line get_next_param tokens
	res

parse_line = (tokens) ->
	remove_padding tokens

	# Keyword
	if tokens[0].type is 'keyword'
		node = new Node('conditional', tokens[0].value)
		tokens.shift()
		# Get the amount of times it will run
		stack = []
		until tokens[0].type is 'block_start'
			stack.push tokens.shift()
		node.times = parse_line stack
		# Remove block start
		tokens.shift()

		stack = get_block tokens

		stack.pop()

		node.block = new Node('block', '')

		node.block.children = parse stack

		return node

	# If not keyword, extract the line and parse it.
	stack = []
	until tokens.length < 1 or tokens[0].type is 'line_end'
		stack.push tokens.shift()

	tokens.shift()
	tokens = stack

	# Annotation
	if tokens[0].type is 'annotation'
		node = new Node('annotation', tokens[0].value)
		node.ref = tokens[1].value

		return node

	# Function define
	if is_function_define tokens
		node = new Node('function_define', tokens[0].value.replace(/\($/, ''))
		
		# Remove function name
		tokens.shift()

		node.params = []
		until tokens[0].type is 'function_define'
			# Extract variable name
			node.params.push tokens.shift().value
			# Remove comma or close parinthesis
			tokens.shift()

		# Remove function define arrow
		tokens.shift()

		node.block = parse_line tokens

		return node

	# Function call
	if is_one_function_call tokens
		fn = tokens[0].value.replace(/\($/, '')
		node = new Node(tokens[0].type, fn)

		# Remove function call
		tokens.shift()

		node.params = parse_params tokens

		return node

	# Single value
	if tokens.length is 1
		node = new Node(tokens[0].type, tokens[0].value)
		return node

	# Binary expression...
	index = least_important_operator tokens

	op = tokens[index].value

	split = split_at_index tokens, index

	left = parse_line(split[0])
	right = parse_line(split[1])

	node = new Node('binary_operation', op)

	node.left = left
	node.right = right

	return node

parse = (tokens) ->
	block = []

	while tokens.length > 0
		block.push parse_line tokens

	block

module.exports = parse