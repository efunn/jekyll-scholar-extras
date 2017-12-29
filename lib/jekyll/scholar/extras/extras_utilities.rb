module Jekyll
  class ScholarExtras

    module Utilities

    # Generate the publication type images.
    def render_ref_img(item)
      css_points = Hash[{
                          "neurofeedback" => "csl-point-neurofeedback-icon",
                          "clinical" => "csl-point-clinical-icon",
                          "bci" => "csl-point-bci-icon",
                          "review" => "csl-point-review-icon",
                          "methods" => "csl-point-methods-icon"
                        }]

      # s = css_points[item.type]
      s = css_points[item.application]
      return s
    end

    # Look at the defaults for prefixes.
    # TODO: Should move this to defaults.
    def initialize_prefix_defaults() 
      @prefix_defaults = Hash[{
                                :article => "J",
                                :inproceedings => "C",
                                :incollection=> "BC",
                                :techreport => "TR",
                                :book => "B"
                              }]
    end

    # Generate a link if an ACM PDF link exists.
    def render_acmpdf_link(entry)
      pdflink =""
      if entry.field?(:acmpdflink)
        pdflink = "<div class=\"pure-button csl-pdf\"><a href=\"" + entry.acmpdflink.to_s + "\">PDF</a></div>"
      end
      
      return pdflink
    end

    # Generate a SLIDES link. 
    def repository_slides_link_for(entry, base = base_url)
      links = repository[entry.key + "_slides"]
      url = links['pdf'] || links['pptx']
      return unless url

      File.join(base, url)
    end

    def split_reference(reference)
      puts "## " + reference.to_s
#      puts "\n"
      if !reference.nil? 
        xml = Nokogiri::HTML(reference.to_s)
        puts "====B======"
 #       puts xml.css("div.csl-index")
        xml.css("div.csl-block.csl-title").each do |node|
          puts "==> " + node.text
        end
        puts "====E====="
      end
    end

  end 

end
end 
