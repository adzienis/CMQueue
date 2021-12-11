Array.class_eval do
  def collect_entries
    h = {}
    each do |k,v|
      if h[k].present?
        h[k] += [v]
      else
        h[k] = [v]
      end
    end
    h
  end
end
