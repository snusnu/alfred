class Language

  include DataMapper::Resource

  # properties

  property :id,   Serial

  property :code, String, :required => true, :unique => true, :format => /\A[a-z]{2}-[A-Z]{2}\z/
  property :name, String, :required => true

  def self.[](code)
    return nil if code.nil?
    first :code => code.to_s.tr('_', '-')
  end

end
