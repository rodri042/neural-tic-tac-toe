# Generates errors in JSON from exceptions
module ExceptionFilter
	extend ActiveSupport::Concern

	def catch_exceptions
		yield
	rescue ActionController::ParameterMissing
		errors! [
			{ json: [ "is missing" ] }
		]
	rescue ValidationException => e
		errors! e.messages
	end

	def catch_unhandled_errors(e)
		summary = {
			errors: {
				:exception => "#{e.class.name} : #{e.message}"
			}
		}
		summary[:trace] = e.backtrace[0, 10] if Rails.env.development?

		render json: summary, status: :internal_server_error
	end

	#------
	private
	#------

	def errors!(errors)
		summary = { errors: errors }
		render json: summary, status: :bad_request
	end
end
