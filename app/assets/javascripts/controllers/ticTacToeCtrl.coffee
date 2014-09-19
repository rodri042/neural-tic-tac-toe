class TicTacToeCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	initialize: =>
		window.ctrl = @

		@_ = "-"
		@x = "x"
		@o = "o"

		@knowledgeBase = []

		@botStarts = false
		@reset()

	reset: =>
		@s.playing = true

		@moves = { x: [], o: [] }
		@s.rows = [
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
		]

		if @botStarts and @emptyGame()
			@moveO

	end: =>
		@s.playing = false
		@botStarts = !@botStarts
		@storeWinData()

	moveO: =>
		if @knowledgeBase.isEmpty()
			selectedCell = @getRandomMove()
		else
			selectedCell = @getNeuralMove()

		@storeMoveData @o, selectedCell
		@set selectedCell, @o
		@checkWin()

	moveX: (cell) =>
		if @get(cell) isnt @_ or not @s.playing
			return

		@storeMoveData @x, cell
		@set cell, @x
		win = @checkWin()
		if not win then @moveO()

	get: (cell) => cell[0]
	set: (cell, value) => cell[0] = value ; cell

	#---

	cells: => _.flatten @s.rows, true
	values: => @cells().map @get

	emptyGame: =>
		@values().every (cell) => cell is @_

	fullGame: =>
		@values().none (cell) => cell is @_

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

	checkWin: =>
		@s.winner = @winner()
		if @s.winner isnt "?" or @fullGame()
			@end()

	getRandomMove: =>
		playingOptions = @cells()
			.filter (cell) => @get(cell) is @_

		random = Math.floor Math.random() * playingOptions.length
		playingOptions[random]

	storeMoveData: (player, cell) =>
		@moves[player].push
			i: @cells().indexOf cell
			snapshot: @values()

	storeWinData: =>
		winner = @winner()
		if winner is "?" then return

		@moves[winner].forEach (moveData) =>
			input = _.flatten moveData.snapshot.map (value) =>
				[+(value isnt @_), +(value is @x)]
			#^ [1 si está usada la celda, 1 si jugó el jugador humano]

			output = [0, 0, 0, 0, 0, 0, 0, 0, 0]
			output[moveData.i] = 3 / @moves[winner].length
			#^ cuánto conviene jugar en esta posición dado este input

			@knowledgeBase.push input: input, output: output

		@learn()

	learn: =>
		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

		@net.train @knowledgeBase