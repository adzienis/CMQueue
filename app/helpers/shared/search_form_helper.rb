module Shared
  module SearchFormHelper

    def filter_dropdown(options, model)

      associations = gen_associations(options, model)

      tag.div id: "dropdown-filter", data: {
        base: request.path,
        except: options[:except],
        columns: {
          root: model.columns.map { |v| { v.name => {
            type: v.type,
            label: v.name.humanize
          } } }.inject(:merge),
          associations: associations
        }, queries: params[:q],
        reset: request.path
      }.to_json do
      end
    end

    private

    def gen_associations(options, model)

      other_filters = options[:other_filters]

      other_filters.empty? ? [] :
                       other_filters.keys.map { |e| { e => other_filters[e].map { |ee| { "#{e}_#{ee}" => {
                         type: ApplicationHelper.get_associations(model).map { |v| { v.name => v.klass } }.inject(:merge)[e].columns_hash[ee].type,
                         label: "#{ee.to_s.humanize}"
                       } } } } }
    end

  end
end