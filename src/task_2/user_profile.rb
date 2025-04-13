class UserProfile
  attr_reader :username, :email, :password, :age, :bio, :interests, :errors

  def initialize(params = {})
    @username  = params[:username]
    @email     = params[:email]
    @password  = params[:password]
    @age       = params[:age]
    @bio       = params[:bio]
    @interests = params[:interests]
    @errors = []
    @data = params
  end

  def valid?
    validate_username
    validate_email
    validate_password
    validate_age
    validate_bio
    validate_interests

    @errors.empty?
  end

  private

  def validate_username
    if @username.nil? || @username.empty?
      @errors << 'Username cannot be empty!'
    elsif @username =~ /[^a-zA-Z0-9_]/
      @errors << 'Username contains invalid special characters!'
    elsif @username.size > 20
      @errors << 'Username is too long!'
    end
  end

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
