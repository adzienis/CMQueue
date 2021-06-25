# frozen_string_literal: true

module Foo
  class CustomInput
    include Formtastic::Inputs::Base

    def to_html
      puts 'this is my modified version of StringInput'
      super
    end

    def input_html_options
      super.merge(class: 'flexible-text-area')
    end
  end
end
