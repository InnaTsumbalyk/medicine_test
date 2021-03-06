class Doctor < ActiveRecord::Base
  has_secure_password
  mount_uploader :photo, DoctorUploader

  belongs_to :company

  validates_presence_of :name, :surname, :second_name, :specialization, :photo, :email
  validates :name, :surname, :second_name, length: {in: 2..20}
end