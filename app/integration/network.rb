module Alfred
  class Network

    include Github::API

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def import

    end

  end
end
