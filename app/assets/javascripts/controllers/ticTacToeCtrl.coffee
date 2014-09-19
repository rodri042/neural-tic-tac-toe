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

		@reset()

	reset: =>
		@s.playing = true

		@s.rows = [
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
		]

		@update()

	update: =>
		@doRandomMove()

		@s.winner = @winner()
		fullGame = @cells().map(@get).every (cell) => cell isnt @_
		if @s.winner isnt "?" or fullGame
			@s.playing = false


	click: (cell) =>
		if @get(cell) isnt @_ or not @s.playing
			return

		@set cell, @x
		@update()

	get: (cell) => cell[0]
	set: (cell, value) => cell[0] = value

	#---

	cells: => _.flatten @s.rows, true

	winner: =>
		values = @cells().map @get

		winnerMoves = [
			[0, 1, 2], [3, 4, 5], [6, 7, 8] #horizontal
			[0, 3, 6], [1, 4, 7], [2, 5, 8] #vertical
			[0, 4, 8], [2, 4, 6]            #diagonal
		]

		for i in [0...winnerMoves.length]
			win = winnerMoves[i]

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

		random = Math.floor Math.random() * playingOptions.length
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