class Language

  include DataMapper::Resource

  # properties

  property :id,   Serial

  property :code, String, :required => true, :unique => true, :format => /\A[a-z]{2}-[A-Z]{2}\z/
  property :name, String, :required => true

  def self.[](code)
    codes[code]
  end

  class << self
    private

    def codes
      @codes ||= Hash.new do |codes, code|
        codes[code] = first(:code => code.to_s.tr('_', '-')).freeze
      end
    end
  end

end
