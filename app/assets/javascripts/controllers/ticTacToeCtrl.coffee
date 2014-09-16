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

	click: (x, y) =>
		alert "#{x}, #{y}"