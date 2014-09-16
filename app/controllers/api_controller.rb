# Generic controller for a REST Api
class ApiController < ActionController::Base
	include ExceptionFilter
	around_filter :catch_exceptions
	rescue_from Exception do |e| catch_unhandled_errors(e) end
		
	protect_from_forgery with: :null_session
	skip_before_filter :verify_authenticity_token

	#--------
	protected
	#--------

	def json!(json, code)
		render json: json, status: code
	end

	def id
		params[:id]
	end
end
