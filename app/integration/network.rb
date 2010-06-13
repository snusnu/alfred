module Alfred
  class Network

    include Github::API

    attr_reader :user, :repo, :ecosystems



  private

    def initialize(user, repo, ecosystems)
      @user, @repo, @ecosystems = owner, repo, ecosystems
      @network = network(@user, @repo)
    end

  end
end
