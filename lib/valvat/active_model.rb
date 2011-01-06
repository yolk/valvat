class ValvatValidator < ::ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Valvat::Syntax.validate(value)
      record.errors.add(attribute, options[:message])
    end
  end
end