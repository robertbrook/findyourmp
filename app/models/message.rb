class Message < ActiveRecord::Base

  belongs_to :constituency

  validates_presence_of :recipient
  validates_presence_of :sender
  validates_presence_of :sender_email
  validates_presence_of :address
  validates_presence_of :postcode
  validates_presence_of :subject
  validates_presence_of :message
  validates_inclusion_of :sent, :in => [true, false]

end
