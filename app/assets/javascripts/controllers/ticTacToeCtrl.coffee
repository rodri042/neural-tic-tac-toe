class TicTacToeCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	initialize: =>
		window.ctrl = @

		@_ = "-"
		@x = "x"
		@o = "o"
		@data = []

		@s.rows = [
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
		]

		@firstTime = true
		@randomMove()

	click: (cell) =>
		if @get(cell) isnt 0
			return

		if @firstTime
			@doRandomMove()
		@s.winner = @winner()

	get: (cell) => cell[0]
	set: (cell) => cell[0] = value

	#---

	cells: => _.flatten @s.rows, true

	winner: =>
		values = @cells().map @get

		[
			[0, 1, 2], [3, 4, 5], [6, 7, 8]
			[0, 3, 6], [1, 4, 7], [2, 5, 8]
			[0, 4 8], [2, 4, 6]
		].forEach (win) =>
			verifyIndex = (player) =>
				win.every (i) => values[i] is player

			if verifyIndex @x
				return @x

			if verifyIndex @o
				return @o

		"?"

	doRandomMove: =>
		playingOptions = @cells()
			.filter (cell) => @get(cell) is @_

		random = Math.floor Math.random() * options.length
		@set playingOptions[random], @o

	knowledgeData: =>
		input:
			@
				.cells()
				.map((cell) =>
					value = @get cell
					[+(value isnt @_), +(value is @x)]
				).flatten()
		output:
			[1, 0, 0, 0.5, 1, 1, 1, 1]

	learn: (oldRows) =>
		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

		@data.push
			input: oldRows
			output: @values()