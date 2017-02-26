# This file runs a parsed tree and outputs the results of each line.

Decimal = require('./decimal.js')

DEFAULT_MODULES =
	'stdlib': './stdlib.js'

# Shallowly clone an object. Only used for creating local scopes.
# JSON stringifying removes the functions.
clone = (obj) ->
	res = {}
	for i of obj
		res[i] = obj[i] if obj.hasOwnProperty(i)

	res

load_module = (filename, scope) ->
	filename = DEFAULT_MODULES[filename] or filename

	m = require(filename)

	for i of m.variables
		scope[i] = m.variables[i]

	for i of m.functions
		scope[i] =
			function_type: 'native'
			fn: m.functions[i]

ASSIGNMENT_OPERATORS = ['=', '+=', '-=', '*=', '/=', '%=']

binary_operation = (a, b, op) ->
	unless typeof a is 'object' and typeof b is 'object' 
		return false

	switch op
		when '^'
			if isZero(a) ^ isZero(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '&&'
			unless isZero(a) or isZero(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '||'
			unless isZero(a) and isZero(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '<'
			if a.lessThan(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '>='
			unless a.lessThan(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '>'
			unless a.lessThanOrEqualTo(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '<='
			if a.lessThanOrEqualTo(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '=='
			if a.equals(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '!='
			unless a.equals(b)
				new Decimal(1)
			else
				new Decimal(0)
		when '<<'
			a.bitShift(b)
		when '>>'
			a.bitShift(-b)
		when '+'
			a.add(b)
		when '-'
			a.minus(b)
		when '*'
			a.times(b)
		when '/'
			a.dividedBy(b)
		when '%'
			a.mod(b)
		when '**'
			a.pow(b)

calc_line = (node, scope = {}, iteration, line) ->
	switch node.type
		when 'block'
			for i in [0...node.children.length]
				console.log (line + i) + ':' + iteration + ': ' + calc_line(node.children[i], scope) + ''
		when 'conditional'
			switch node.value
				when 'repeat'
					times = Number(calc_line(node.times, scope)+'')
					for i in [0...times]
						calc_line node.block, scope, i, line

				when 'while'
					i = 0
					until calc_line(node.times, scope).isZero()
						calc_line node.block, scope, i, line
						i += 1

				when 'if'
					unless calc_line(node.times, scope).isZero()
						calc_line node.block, scope, 0, line

			return '-'
	
		when 'variable'
			unless scope.hasOwnProperty(node.value)
				throw 'No variable named ' + node.value
			return scope[node.value]
		when 'number'
			return new Decimal(node.value)
		when 'binary_operation'
			if ASSIGNMENT_OPERATORS.includes node.value
				v = node.left.value
				b = calc_line node.right, scope
				if node.value == '='
					return scope[v] = b
				else
					return scope[v] =
						binary_operation scope[v], b, node.value[0]
			else
				a = calc_line node.left, scope
				b = calc_line node.right, scope
				return binary_operation a, b, node.value
		when 'function_define'
			scope[node.value] =
				function_type: 'local'
				params: node.params
				block: node.block

			return node.value + ' <- [function]'
		when 'function_call'
			name = node.value
			if scope[name].function_type is 'native'
				p = []
				for i in node.params
					p.push calc_line i, scope
				return scope[name].fn(p)
			else if scope[name].function_type is 'local'
				local = clone scope
				for i in [0...scope[name].params.length]
					local[scope[name].params[i]] = calc_line node.params[i], scope

				return calc_line scope[name].block, local
		when 'annotation'
			switch node.value
				when '@include'
					ref = node.ref.replace(/"/g, '')
					load_module ref, scope
					return 'Module ' + ref + ' loaded!'
				when '@precision'
					Decimal.set({
						precision: Number(node.ref)
					})
					return 'Precision set to ' + node.ref



calc = (block) ->
	scope = {}
	for i in [0...block.length]
		console.log i + ':   ' + calc_line(block[i], scope, 0, i) + ''

module.exports = calc