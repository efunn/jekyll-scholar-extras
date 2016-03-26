module Jekyll
  module ScholarExtras
    @extra_defaults = {
      'slides'                 => '_slides'
    }.freeze

    class << self
      attr_reader :extra_defaults
    end
  end
end
