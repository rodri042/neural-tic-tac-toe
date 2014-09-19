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
		win = @s.winner isnt "?" or @fullGame()
		if win then @end()
		win

	getRandomMove: =>
		playingOptions = @cells()
			.filter (cell) => @get(cell) is @_

		random = Math.floor Math.random() * playingOptions.length
		playingOptions[random]

	getNeuralMove: =>
		playingOptions = @net.run(@getInputNeurons(@values()))
			.map (weight, i) => i: i, weight: weight
		playingOptions = _.sortBy(playingOptions, "weight")

		for i in [0 ... playingOptions.length]
			cell = @cells()[playingOptions[i].i]
			if @get(cell) is @_ then return cell

	#[1 si está usada la celda, 1 si jugó el jugador humano]
	getInputNeurons: (values) =>
		_.flatten values.map (value) =>
			[+(value isnt @_), +(value is @x)]
			
	#cuánto conviene jugar en esta posición
	getOutputNeurons: (i, totalMoves) =>
		output = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		output[i] = 3 / totalMoves
		output

	storeMoveData: (player, cell) =>
		@moves[player].push
			i: @cells().indexOf cell
			snapshot: @values()

	storeWinData: =>
		winner = @winner()
		if winner is "?" then return

		if winner is @x
			###si gana el usuario, invierto los valores
			para que el bot aprenda eso y crea que ganó###
			@moves[winner] = @moves[winner].map (moveData) =>
				moveData.snapshot = moveData.snapshot.map (value) =>
					if value is @x then @o
					else if value is @o then @x
					else @_
				moveData

		@moves[winner].forEach (moveData) =>
			@knowledgeBase.push
				input: @getInputNeurons moveData.snapshot
				output: @getOutputNeurons moveData.i, @moves[winner].length

		@learn()

	#vuelvo a instanciar / entrenar la red neuronal con el conocimiento
	learn: =>
		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

		@net.train @knowledgeBase