module FormHelper


  def form_wrapper
    tag.div class: "card card-body" do
      yield
    end
  end
end