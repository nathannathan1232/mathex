# The standard library for Mathex.
# This file includes basic math functions and constants like
# log, sin, cos and PI

Decimal = require('./decimal.js')

module.exports =
	name: 'stdlib'
	description: 'The built-in library'

	variables:
		PI: new Decimal('3.1415926535897932384626433832795028841971693993751')
		E:  new Decimal('2.7182818284590452353602874713526624977572470937000')

	functions:
		log: (p) ->
			p[0].log()
		sin: (p) ->
			p[0].sin()
		cos: (p) ->
			p[0].cos()
		tan: (p) ->
			p[0].tan()
		ln: (p) ->
			p[0].ln()
		asin: (p) ->
			p[0].asin()
		acos: (p) ->
			p[0].acos()
		atan: (p) ->
			p[0].atan()
		sqrt: (p) ->
			p[0].sqrt()
		cbrt: (p) ->
			p[0].cbrt()
		round: (p) ->
			p[0].round()
		floor: (p) ->
			p[0].floor()
		ceil: (p) ->
			p[0].ceil()
		factorial: (p) ->
			# If the input is low, use a javascript number for the iterator.
			# If the input is too high, use a Decimal.
			if p[0].lessThan(1000000)
				n = p[0].toString()
				res = new Decimal(1)
				i = 1
				while i <= n
					res = res.times(i)
					i += 1
				res
			else
				res = new Decimal(1)
				i = new Decimal(1)
				while i.lessThanOrEqualTo(p[0])
					res = res.times(i)
					i = i.add(1)
				res
		random: (p) ->
			sd = if p[0] then Number(p[0].toString()) else 10
			Decimal.random(sd)