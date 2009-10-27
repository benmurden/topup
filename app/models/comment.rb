class Comment < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  
  validates_presence_of :name, :message, :unsubscription_code
  validates_format_of :email_address, :with => /\A[\w\.\-]+\@[\w\.\-]+\.[\w]+\Z/i
  validates_uniqueness_of :unsubscription_code
  
  before_create :generate_unsubscription_code
  before_save :sanitize_message
  after_create :deliver_notification
  
  def generate_unsubscription_code
    self.unsubscription_code = random_hex(28)
  end
  
  def sanitize_message
    self.message = sanitize self.message, :tags => %w(a abbr acronym blockquote code i strike strong u), :attributes => %w(href title)
  end
  
  def deliver_notification
    Mailer.deliver_new_comment(self)
  end
  
end
