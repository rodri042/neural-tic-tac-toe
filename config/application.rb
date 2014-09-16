require File.expand_path('../boot', __FILE__)

# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

Bundler.require(:default, Rails.env)

module NeuralTicTacToe
	class Application < Rails::Application
		#Include all folders to AutoLoad
		Dir["#{config.root}/app/**/*"]
			.select { |f| File.directory? f }
			.each do |path|
				config.autoload_paths += [path]
			end

		# Add Middleware to catch JSON parse errors
		config.middleware.insert_before ActionDispatch::ParamsParser, "CatchJsonParseErrors"

		# Add Bower components to assets pipeline
		config.assets.paths << Rails.root.join("vendor", "assets", "components")

		# --------------------------------
		# Precompiler things for Heroku...
		# --------------------------------

		# We don't want the default of everything that isn't js or css, because it pulls too many things in
		config.assets.precompile.shift

		# Explicitly register the extensions we are interested in compiling
		config.assets.precompile.push(Proc.new do |path|
			File.extname(path).in? [
				".html", ".erb", ".haml",                 # Templates
				".png",  ".gif", ".jpg", ".jpeg", ".svg", # Images
				".eot",  ".otf", ".svc", ".woff", ".ttf", # Fonts
			]
		end)
	end
end
