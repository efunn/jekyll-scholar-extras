module Jekyll
  module ScholarExtras
    @extra_defaults = {
      'slides'                 => '_slides',
      'parse_extra_fields' => {
        'award' => "award",
        'errata' => "_errata"}
    }.freeze

    class << self
      attr_reader :extra_defaults
    end
  end
end
