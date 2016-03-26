module Jekyll
  class Scholar
    
    class BibliographyTagYear < Liquid::Tag
      include Scholar::Utilities
      include ScholarExtras

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup

        puts @config
        
        optparse(arguments)

      end

      def initialize_type_counts()
        @type_counts = Hash[{ :article => 0,
                              :inproceedings => 0,
                              :incollection=> 0,
                              :techreport => 0,
                              :book => 0
                            }]

        @type_counts.keys.each { |t|
          bib = bibliography.query('@*') { |b|
            (b.public == 'yes' && b.type == t)
          }
          @type_counts[t] = bib.size
        }
      end

      def initialize_type_order()
        @type_order = Hash[{ :article => 0,
                             :book => 0,
                             :incollection=> 0,
                             :inproceedings => 0,
                             :techreport => 0
                           }]
      end


      def get_entries_by_type(year, type)
        b = bibliography.query('@*') { |item|
          (item.year == year && item.type == type)
        }
      end

      def render_year(y)
        ys = content_tag "h2 class=\"csl-year-header\"", y
        ys = content_tag "div class=\"csl-year-icon\"", ys
      end


      def entries_year(year)
        b = bibliography.query('@*') { 
          |a| (a.year == year && a.public == 'yes')
        }
      end

      def initialize_unique_years
        # Get an array of years and then uniquify them.
        items = entries
        arr = Array.new
        items.each { |i| arr.push(i.year.to_s)  }
        @arr_unique = arr.uniq
      end

      def render(context)
        set_context_to context

        # Initialize the number of each type of interest.
        initialize_type_counts()
        initialize_type_order()
        initialize_prefix_defaults()
        initialize_unique_years()

        # Iterate over unique years, and produce the bib.
        bibliography =""
        @arr_unique.each { |y|
          bibliography << render_year(y)
          @type_order.keys.each { |o|
            items = entries_year(y).select { |e| e.type == o }
            bibliography << items.each_with_index.map { |entry, index|
              if entry.type == o then 
                reference = render_index(entry, bibliography_tag(entry, nil))

#                split_reference reference
                
                if entry.field?(:award)
                  # TODO: Awkward -- Find position to insert it. Before the last </div>
                  ts = content_tag "div class=\"csl-award\"", entry.award.to_s
                  reference_position = reference.rindex('</div>')
                  if reference_position.nil? 
                  else 
                    reference.insert( reference.rindex('</div>'), ts.to_s )
                  end
                end

                # There are multiple ways to have PDFs associated.
                # Priority is suggested as below.
                # 1. ACM links to PDF through authorizer
                # 2. Repository links
                # 3. Just web links to somewhere else.
                #

                # Check if there are ACM PDF links
                reference.insert(reference.rindex('</div>'),render_acmpdf_link(entry))

                # Render links if repository specified but not acmpdflink
                if repository? && !entry.field?(:acmpdflink) 
                  if not repository_link_for(entry).nil?
#                    puts "link is not null"
#                    puts repository_link_for(entry)
                    pdflink = "<div class=\"pure-button csl-pdf\"><a href=\"" + repository_link_for(entry) + "\">PDF</a></div>"
                    reference.insert(reference.rindex('</div>'), pdflink.to_s )
                  end

                  # Check for SLIDES PDF.
                  if not repository_link_for(entry).nil?
                    link = repository_slides_link_for(entry)
#                    puts link.to_s
                    if link.to_s.include?("_slides")
                      pdflink = "<div class=\"pure-button csl-slides\"><a href=\"" + repository_slides_link_for(entry) + "\">SLIDES</a></div>"
                      reference.insert(reference.rindex('</div>'), pdflink.to_s )                      
                    end
                  end
                  
                end

                # Content tag is dependent on type of article.
                content_tag "li class=\"" + render_ref_img(entry) + "\"", reference
              end
            }.join("\n")
          }.join("\n")
        }.join("")
        return content_tag config['bibliography_list_tag'], bibliography, :class => config['bibliography_class']
      end
    end
  end
end

Liquid::Template.register_tag('bibliography_year', Jekyll::Scholar::BibliographyTagYear)
