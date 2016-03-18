module Jekyll
  module ScholarExtras

      def render_index(item, ref)
        si = '[' + @prefix_defaults[item.type].to_s + @type_counts[item.type].to_s + ']'
        @type_counts[item.type] = @type_counts[item.type].to_i - 1
        
        idx_html = content_tag "div class=\"csl-index\"", si
        return idx_html + ref
      end

      def render_ref_img(item)
        css_points = Hash[{
                         :article => "csl-point-journal-icon",
                         :inproceedings => "csl-point-conference-icon",
                         :incollection=> "csl-point-bookchapter-icon",
                         :techreport => "csl-point-techreport-icon",
                         :book => "csl-point-book-icon"
                       }]

        s = css_points[item.type]
        return s
      end

      def initialize_prefix_defaults() 
        @prefix_defaults = Hash[{
                                  :article => "J",
                                  :inproceedings => "C",
                                  :incollection=> "BC",
                                  :techreport => "TR",
                                  :book => "B"
                                }]
      end

    def render_acmpdf_link(entry)
      pdflink =""
      if entry.field?(:acmpdflink)
        pdflink = "<div class=\"pure-button csl-pdf\"><a href=\"" + entry.acmpdflink.to_s + "\">PDF</a></div>"
      end
      return pdflink
    end
  end 

  def split_reference(reference)
    puts "===========================\n"
    puts reference
    puts "===========================\n"
  end
  
end 
