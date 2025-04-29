require "dry/validation"
require "dry/monads"

class UserProfile < Dry::Validation::Contract
  attr_reader :errors

  params do
    required(:username).filled(:string)
    required(:email).filled(:string)
    required(:password).filled(:string)
    required(:age).filled(:integer)
    required(:bio).filled(:string)
    required(:interests).filled(:string)
    required(:errors).filled(:string)
  end

  rule(:username) do
    key.failure('contains invalid special characters!') if value =~ /[^a-zA-Z0-9_]/
    key.failure('is too long!') if value.size > 20
  end

  def initialize(params = {})
    @errors = []
    @data = params
  end

  def valid?
    call(@data)
  end

  private

  def validate_email
    if @email.nil? || @email.strip.empty?
      @errors << 'Email cannot be empty!'
    elsif !@email.include?('@')
      @errors << 'Email must contain the @ symbol!'
    elsif @email.size < 5
      @errors << 'Email is too short to be valid!'
    end
  end

  def validate_password
    if @password.nil? || @password.empty?
      @errors << 'Password cannot be empty!'
    elsif @password.size < 7
      @errors << 'Password must be at least 7 characters long!'
    elsif !@password.match?(/[!@#$%^&*]/)
      @errors << 'Password should contain at least one special character (!@#$%^&*)!'
    end
  end

  def validate_age
    if @age.nil?
      @errors << 'Age must be provided!'
    elsif !(@age.is_a?(Integer) || (@age.to_s =~ /^\d+$/))
      @errors << 'Age must be a number!'
    elsif @age.to_i < 13
      @errors << 'User must be at least 13 years old!'
    end
  end

  def validate_bio
    if @bio.nil? || @bio.empty?
      @errors << 'Bio cannot be empty!'
    elsif @bio.size > 300
      @errors << 'Bio is too long (max 300 characters)!'
    else
      bad_words = %w[badword anotherbadword yetanotherbadword]
      bad_words.each do |word|
        if @bio.downcase.include?(word)
          @errors << "Bio contains profanity: #{word}"
          break
        end
      end
      @errors << 'Bio should not start with a space!' if @bio.start_with?(' ')
    end
  end

  def validate_interests
    if @interests.nil?
      @errors << 'Interests list cannot be empty!'
    elsif !@interests.is_a?(Array)
      @errors << 'Interests must be an array!'
    else
      if @interests.empty?
        @errors << 'Interests list is empty!'
      elsif @interests.size > 10
        @errors << 'Too many interests! Maximum is 10.'
      end
      @interests.each do |interest|
        @errors << "Invalid data type in interests: #{interest.inspect}" unless interest.is_a?(String)
      end
    end
  end
end
