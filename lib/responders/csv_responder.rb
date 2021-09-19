module Responders
  module CsvResponder
    def to_csv
      @controller.send_data @request.model.to_csv(@request.params[:resource], @resource),
                filename: @controller.helpers.csv_download_name(@controller.controller_name.classify.constantize)
    end
  end
end