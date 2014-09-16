# Partial apply to a function.
window.Function.prototype.partial = ->
	fn = @
	args = Array.prototype.slice.call arguments
	->
		fullArgs = args.concat Array.prototype.slice.call(arguments)
		fn.apply @, fullArgs