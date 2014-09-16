class LandingCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	initialize: =>
		window.debu = @
		@net = new brain.NeuralNetwork