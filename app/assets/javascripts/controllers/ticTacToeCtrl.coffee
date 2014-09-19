class TicTacToeCtrl extends BaseCtrl
	@route "/tictactoe",
		templateUrl: "templates/tictactoe"
	@inject()

	#inicializa el juego
	initialize: =>
		window.ctrl = @

		@_ = "-"
		@x = "x"
		@o = "o"

		@knowledgeBase = []

		@botStarts = false
		@reset()

		@net = new brain.NeuralNetwork
			hiddenLayers: [9]
			learningRate: 0.3

	#comienza una nueva partida
	reset: =>
		@s.playing = true

		@moves = { x: [], o: [] }
		@s.rows = [
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
			[["-"], ["-"], ["-"]]
		]

		if @botStarts and @emptyGame()
			@moveO()

	#termina la partida y muestra el ganador
	end: =>
		@s.playing = false
		@botStarts = !@botStarts
		@storeWinData()

	#mueve al bot
	moveO: =>
		if @knowledgeBase.isEmpty()
			selectedCell = @getRandomMove()
		else
			selectedCell = @getNeuralMove()

		@storeMoveData @o, selectedCell
		@set selectedCell, @o
		@checkWin()

	#mueve al jugador (la celda seleccionada)
	moveX: (cell) =>
		if @get(cell) isnt @_ or not @s.playing
			return

		@storeMoveData @x, cell
		@set cell, @x
		win = @checkWin()
		if not win then @moveO()

	#el contenido de una celda
	get: (cell) => cell[0]

	#asigna el contenido de una celda
	set: (cell, value) => cell[0] = value ; cell

	#---

	#todas las celdas
	cells: => _.flatten @s.rows, true

	#todos los contenidos de todas las celdas
	values: => @cells().map @get

	#si el juego está recién empezado
	emptyGame: =>
		@values().every (cell) => cell is @_

	#si el tablero está completo
	fullGame: =>
		@values().none (cell) => cell is @_

	#el ganador
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

	#comprueba que el juego haya terminado
	checkWin: =>
		@s.winner = @winner()
		win = @s.winner isnt "?" or @fullGame()
		if win then @end()
		win

	#selecciona una celda al azar
	getRandomMove: =>
		playingOptions = @cells()
			.filter (cell) => @get(cell) is @_

		random = Math.floor Math.random() * playingOptions.length
		playingOptions[random]

	#selecciona una celda usando la red neuronal
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
			
	#cuánto conviene jugar en cada posición
	getOutputNeurons: (i, totalMoves) =>
		output = [0, 0, 0, 0, 0, 0, 0, 0, 0]
		output[i] = 3 / totalMoves
		output

	#almacena la información del movimiento
	storeMoveData: (player, cell) =>
		@moves[player].push
			i: @cells().indexOf cell
			snapshot: @values()

	#almacena las jugadas ganadoras en la red neuronal
	storeWinData: =>
		winner = @winner()
		if winner is "?" then return

		if winner is @x
			###si gana el usuario, invierte los valores
			para que el bot aprenda eso y crea que ganó###
			@moves[winner] = @moves[winner].map (moveData) =>
				moveData.snapshot = moveData.snapshot.map (value) =>
					if value is @x then @o
					else if value is @o then @x
					else @_
				moveData

		@moves[winner].forEach (moveData) =>
			newRule =
				input: @getInputNeurons moveData.snapshot
				output: @getOutputNeurons moveData.i, @moves[winner].length

			@knowledgeBase.push newRule
			@train newRule

	#entrena la red neuronal basandose en una regla
	train: (rule) => @net.train rule