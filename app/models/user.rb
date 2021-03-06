class User < ActiveRecord::Base

  has_one :lead

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_save :create_update_lead

  def name
    first_name.concat(" #{last_name}")
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  def create_update_lead
    if (self.changed & ["first_name", "last_name", "company", "email", "phone"]).present?
      Delayed::Job.enqueue(SalesforceLeadJob.new(id))
    end
  end

end
