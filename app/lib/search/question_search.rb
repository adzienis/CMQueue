module Search
  class QuestionSearch
    def initialize(**params)
      @params = params
    end

    def search
    end

    private

    attr_reader :params
  end
end
