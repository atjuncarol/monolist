Amazon::Ecs.configure do |options|
  options[:AKIAJHB3J77GYW3JADVQ] = Rails.application.secrets.aws_access_key_id
  options[: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] = Rails.application.secrets.aws_secret_key
  options[:athasjp-22] = Rails.application.secrets.associate_tag
end
