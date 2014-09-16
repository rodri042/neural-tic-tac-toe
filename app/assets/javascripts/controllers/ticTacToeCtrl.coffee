class TicTacToeCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	initialize: =>
		window.ctrl = @ #for debugging

		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

		@s.rows = [
			[[-1], [-1], [-1]]
			[[-1], [-1], [-1]]
			[[-1], [-1], [-1]]
		]

	click: (cell) =>
		@_set cell, 1 if @get(cell) is -1

	get: (cell) => cell[0]
	_set: (cell, value) => cell[0] = value