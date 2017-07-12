# encoding: utf-8
class Session < BaseService
  attr_reader :tenant, :status, :active, :logged

  attribute :email, String
  attribute :password, String

  delegate :id, to: :user, prefix: true, allow_nil: true

  validates_presence_of :email, :password

  def authenticate?
    return false unless validated?
    puts "current password: #{password}"
    puts "user #{user.inspect}"
    puts "user.valid_password?(password): #{user.valid_password?(password)}"
    puts "user.update_attributes...: #{user.update_attributes(last_sign_in_at: Time.zone.now)}"
    #user.valid_password?(password) && 
    user.update_attributes(last_sign_in_at: Time.zone.now)
  end

  def user
    @user ||= User.active.find_by(email: email)
  end

  def tenant
    @tenant ||= user.organisations.order("id").first.tenant
  end

  private

    def validated?
      valid? && user.present? && user.active_links?
    end
end
