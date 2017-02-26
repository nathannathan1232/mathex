# Main Mathex file.
# 
# To compile coffeescript to js, go into the main directory and do:
# coffee -c -o lib src
# 
# Run using (from the lib directory):
# node index.js <filename>
# replace <filename> with the name of your .mx file.

fs = require('fs')

tokenize = require('./tokenize.js')
print_tokens = require('./print-tokens.js')

parse = require('./parse.js')

calc = require('./calc.js')

config =
	tokens: [
		'./std-tokens.yml'
	]

exp = fs.readFileSync(process.argv[2]).toString()

tokens = tokenize exp, config
console.log print_tokens tokens

p = parse tokens

#console.log JSON.stringify p, null, 5

calc(p) + ''