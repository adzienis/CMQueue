module Exportable
  extend ActiveSupport::Concern

  included do
    def self.to_csv(hash, records)
      asses = hash.keys.filter { |v| hash[v].is_a? Hash }
      full_asses = asses.collect { |u| {u => hash[u].keys.filter { |x| hash[u][x] == "1" }} }.flatten
      attribs = hash.keys.filter { |v| !hash[v].is_a?(Hash) && hash[v] == "1" }.sort

      names = attribs + full_asses.collect { |x| x.values.first.collect { |v| "#{x.keys.first}_#{v}" } }.flatten

      full_asses_dict = full_asses.inject(:merge)

      CSV.generate(headers: true) do |csv|
        csv << names

        records
          .as_json(
            include: [:has_and_belongs_to_many, :belongs_to, :has_one, :has_many]
                       .collect { |s| reflect_on_all_associations(s) }
                       .flatten
                       .collect(&:name)
                       .map { |s| {s => {only: full_asses_dict[s.to_s]}} }
          ).each do |x|
          attrib_values = x.values_at(*attribs.sort)

          ass_values = full_asses.map do |z|
            k = z.keys.first
            if x.key? k
              if x[k].is_a? Array

                if x[k].empty?
                  full_asses_dict[k].map { |_| [nil] }
                else
                  entries = x[k].flat_map(&:entries).sort_by { |a| a[0] }
                  injected = entries.group_by(&:first).map { |k, v| {k => v.map(&:last)} }
                  injected.map { |v| v.values.join(",") }.flatten
                end
              else
                values = x[k].sort.to_h.values
              end
            elsif full_asses_dict[k].is_a? Array
              entries = full_asses_dict[k].sort_by { |a| a[0] }
              injected = entries.group_by(&:first).map { |k, v| {k => v.map(&:last)} }
              injected.map { |v| v.values.join(",") }.flatten

            else
              values = full_asses_dict[k].sort.to_h.values
            end
          end.flatten

          csv << (attrib_values + ass_values)
        end
      end
    end
  end
end
