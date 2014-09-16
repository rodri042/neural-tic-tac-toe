# Generates errors in JSON from JSON parse errors
class CatchJsonParseErrors
	def initialize(app)
		@app = app
	end

	def call(env)
		begin
			@app.call env
		rescue ActionDispatch::ParamsParser::ParseError
			[
				400, { "Content-Type" => "application/json" },
				[ { errors: [ { json: "is wrong" } ] }.to_json ]
			]
		end
	end
end