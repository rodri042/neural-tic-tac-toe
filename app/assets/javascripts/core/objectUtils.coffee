window.Function::partial = ->
	fn = @
	args = Array.prototype.slice.call arguments
	->
		fullArgs = args.concat Array.prototype.slice.call(arguments)
		fn.apply @, fullArgs

window.Array::isEmpty = -> @length is 0

window.Array::none = (fn) -> not @some fn