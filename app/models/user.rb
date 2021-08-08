class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :alter_email
  before_create :create_activation_digest

  PERMITTED = [:name, :email, :password, :password_confirmation].freeze
  PASSWORD_PERMITTED = [:password, :password_confirmation].freeze

  validates :name, presence: true,
                    length: {maximum: Settings.validation.name.max_length}

  validates :email, presence: true,
                    length: {
                      maximum: Settings.validation.email.max_length,
                      minimum: Settings.validation.email.min_length
                    },
                    format: {with: Settings.validation.email.format_regex},
                    uniqueness: {case_sensitive: false}

  validates :password, presence: true,
                    length: {minimum: Settings.validation.password.min_length},
                    allow_nil: true

  has_secure_password

  def self.digest string
    cost =
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create string, cost: cost
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  # Activates an account.
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.validation.password.expired_time.hours.ago
  end

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  scope :feed, ->(id){Micropost.where "user_id = ?", id}
  private

  def alter_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
