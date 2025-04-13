require_relative '../../src/task_2/user_profile'

RSpec.shared_examples 'invalid profile' do |error_message|
  it 'is invalid' do
    result = subject.valid?
    expect(result).to be_failure
    errors = result.failure
    if error_message.is_a?(Regexp)
      expect(errors.first).to match(error_message)
    else
      expect(errors).to include(error_message)
    end
  end
end

RSpec.describe UserProfile do
  include Dry::Monads[:result]

  let(:valid_params) do
    {
      username: 'valid_user',
      email: 'user@example.com',
      password: 'Secr3t!@#',
      age: 25,
      bio: 'This is my bio.',
      interests: %w[coding music]
    }
  end

  subject { described_class.new(params) }

  context 'with valid attributes' do
    let(:params) { valid_params }
    it 'is valid' do
      result = subject.valid?
      expect(result).to be_success
    end
  end

  context 'with an invalid username' do
    context 'when username is empty' do
      let(:params) { valid_params.merge(username: '') }
      include_examples 'invalid profile', 'must be filled'
    end

    context 'when username contains invalid characters' do
      let(:params) { valid_params.merge(username: 'invalid!user') }
      include_examples 'invalid profile', 'Username contains invalid special characters!'
    end

    context 'when username is too long' do
      let(:params) { valid_params.merge(username: 'a' * 21) }
      include_examples 'invalid profile', 'Username is too long!'
    end
  end

  context 'with an invalid email' do
    context 'when email is empty' do
      let(:params) { valid_params.merge(email: '   ') }
      include_examples 'invalid profile', 'Email cannot be empty!'
    end

    context 'when email does not contain @' do
      let(:params) { valid_params.merge(email: 'userexample.com') }
      include_examples 'invalid profile', 'Email must contain the @ symbol!'
    end

    context 'when email is too short' do
      let(:params) { valid_params.merge(email: 'a@b') }
      include_examples 'invalid profile', 'Email is too short to be valid!'
    end
  end

  context 'with an invalid password' do
    context 'when password is empty' do
      let(:params) { valid_params.merge(password: '') }
      include_examples 'invalid profile', 'must be filled'
    end

    context 'when password is too short' do
      let(:params) { valid_params.merge(password: 'abc!') }
      include_examples 'invalid profile', 'Password must be at least 7 characters long!'
    end

    context 'when password lacks a special character' do
      let(:params) { valid_params.merge(password: 'Secret12') }
      include_examples 'invalid profile', 'Password should contain at least one special character (!@#$%^&*)!'
    end
  end

  context 'with an invalid age' do
    context 'when age is nil' do
      let(:params) { valid_params.merge(age: nil) }
      include_examples 'invalid profile', 'must be filled'
    end

    context 'when age is non numeric' do
      let(:params) { valid_params.merge(age: 'twenty') }
      include_examples 'invalid profile', 'Age must be a number!'
    end

    context 'when age is below 13' do
      let(:params) { valid_params.merge(age: 10) }
      include_examples 'invalid profile', 'User must be at least 13 years old!'
    end
  end

  context 'with an invalid bio' do
    context 'when bio is empty' do
      let(:params) { valid_params.merge(bio: '') }
      include_examples 'invalid profile', 'must be filled'
    end

    context 'when bio is too long' do
      let(:params) { valid_params.merge(bio: 'a' * 301) }
      include_examples 'invalid profile', 'Bio is too long (max 300 characters)!'
    end

    context 'when bio contains profanity' do
      let(:params) { valid_params.merge(bio: 'This bio contains badword in it.') }
      include_examples 'invalid profile', /Bio contains profanity:/
    end

    context 'when bio starts with a space' do
      let(:params) { valid_params.merge(bio: ' starts with space') }
      include_examples 'invalid profile', 'Bio should not start with a space!'
    end
  end

  context 'with invalid interests' do
    context 'when interests is nil' do
      let(:params) { valid_params.merge(interests: nil) }
      include_examples 'invalid profile', 'must be filled'
    end

    context 'when interests is an empty array' do
      let(:params) { valid_params.merge(interests: []) }
      include_examples 'invalid profile', 'must be filled'
    end

    context 'when there are too many interests' do
      let(:params) { valid_params.merge(interests: Array.new(11, 'interest')) }
      include_examples 'invalid profile', 'Too many interests! Maximum is 10.'
    end

    context 'when an interest is not a string' do
      let(:params) { valid_params.merge(interests: ['coding', 123]) }
      it 'is invalid' do
        result = subject.valid?
        expect(result).to be_failure
        errors = result.failure
        expect(errors.join).to include('Invalid data type in interests: 123')
      end
    end
  end
end
