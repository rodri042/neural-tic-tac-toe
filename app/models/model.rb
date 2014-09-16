# A model that will be persisted in the db
class Model
	include ActiveModel::Validations

	def to_dto
		raise "should be implemented"
	end

	def validate
		if self.invalid?
			raise ValidationException.new(self.errors.messages)
		end
	end
end