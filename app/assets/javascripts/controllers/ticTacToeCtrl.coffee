class TicTacToeCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	initialize: =>
		window.ctrl = @

		@_ = "-"
		@x = "x"
		@o = "o"
		@data = { x: [], o: [] }
		@botStarts = false

		@reset()

	reset: =>
		@s.playing = true

		@s.rows = [
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
		]

		@update (@botStarts and @emptyGame())

	end: =>
		@s.playing = false
		@botStarts = !@botStarts

	update: (move = true) =>
		if @fullGame() then return @end()

		if move
			selectedCell = @getRandomMove()
			@storeMoveData @o, selectedCell
			@set selectedCell, @o

		@s.winner = @winner()
		if @s.winner isnt "?" then @end()

	click: (cell) =>
		if @get(cell) isnt @_ or not @s.playing
			return

		@storeMoveData @x, cell
		@set cell, @x
		@update()

	get: (cell) => cell[0]
	set: (cell, value) => cell[0] = value ; cell

	#---

	cells: => _.flatten @s.rows, true
	values: => @cells().map @get

	emptyGame: =>
		@values().every (cell) => cell is @_

	fullGame: =>
		@values().every (cell) => cell isnt @_

	winner: =>
		winnerMoves = [
			[0, 1, 2], [3, 4, 5], [6, 7, 8] #horizontal
			[0, 3, 6], [1, 4, 7], [2, 5, 8] #vertical
			[0, 4, 8], [2, 4, 6]            #diagonal
		]

		for i in [0...winnerMoves.length]
			win = winnerMoves[i]

			verifyIndex = (player) =>
				win.every (i) => @values()[i] is player

			if verifyIndex @x
				return @x

			if verifyIndex @o
				return @o

		"?"

	storeMoveData: (player, cell) =>
		@data[player].push
			i: @cells().indexOf cell
			snapshot: @values()

	getRandomMove: =>
		playingOptions = @cells()
			.filter (cell) => @get(cell) is @_

		random = Math.floor Math.random() * playingOptions.length
		playingOptions[random]

	knowledgeInputs: =>
		inputs = @
			.cells()
			.map((cell) =>
				value = @get cell
				[+(value isnt @_), +(value is @x)]
			)

		_.flatten inputs

	learn: (oldRows) =>
		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

		@data.push
			input: oldRows
			output: @values()