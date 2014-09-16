# The main angular application
@app = angular
	.module "neural-tic-tac-toe", [
		"ngRoute"
	]

	.config ($routeProvider) ->
		$routeProvider.otherwise redirectTo: "/"