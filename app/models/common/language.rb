class Language

  include DataMapper::Resource

  # properties

  property :id,   Serial

  property :code, String, :required => true, :unique => true
  property :name, String, :required => true

  # locale string like 'en-US'
  validates_format_of :code, :with => /^[a-z]{2}-[A-Z]{2}$/


  def self.[](code)
    return nil if code.nil?
    first :code => code.to_s.gsub('_', '-')
  end

end
