class TicTacToeCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	initialize: =>
		window.ctrl = @ #for debugging

		@s.rows = [
			[[0], [0], [0]]
			[[0], [0], [0]]
			[[0], [0], [0]]
		]

		@data = []
		@_randomMove()

	click: (cell) =>
		if @get(cell) isnt 0
			return

		oldRows = @values()
		@_set cell, 1
		@_learn oldRows
		@_randomMove()

	get: (cell) => cell[0]
	values: (shallow) => _.flatten @s.rows, shallow

	_learn: (oldRows) =>
		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

		@data.push
			input: oldRows
			output: @values()

	_randomMove: =>
		options = @values(true).filter (row) => @get(row) is 0
		if options.length > 0
			random = Math.floor Math.random() * options.length
			@_set options[random], -1

	_set: (cell, value) => cell[0] = value