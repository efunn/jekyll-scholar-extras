module Jekyll
  class Scholar

    class BibliographyTagYear < Liquid::Tag
      include Scholar::Utilities

      def initialize(tag_name, arguments, tokens)
        super

        @config = Scholar.defaults.dup
        
        optparse(arguments)

      end

      def initialize_type_counts()
        @type_counts = Hash[{
                         :article => 0,
                         :inproceedings => 0,
                         :incollection=> 0,
                         :techreport => 0,
                         :book => 0
                       }]

        @type_counts.keys.each { |t|
          bib = bibliography.query('@*') { |b|
            (b.public == 'yes' and b.type == t)
          }
          @type_counts[t] = bib.size
        }
      end

      def initialize_type_order()
        @type_order = Hash[{
                         :article => 0,
                         :book => 0,
                         :incollection=> 0,
                         :inproceedings => 0,
                         :techreport => 0
                       }]
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

      def get_entries_by_type(year, type)
        b = bibliography.query('@*') { |item|
          (item.year == year and item.type == type)
        }
      end

      def render_year(y)
        ys = content_tag "h2 class=\"csl-year-header\"", y
        ys = content_tag "div class=\"csl-year-icon\"", ys
#        content_tag "h2", y
      end

      def render_index(item, ref)
        si = '[' + @prefix_defaults[item.type].to_s + @type_counts[item.type].to_s + ']'
        @type_counts[item.type] = @type_counts[item.type].to_i - 1
        
        idx_html = content_tag "div class=\"csl-index\"", si
        return idx_html + ref
      end

      def entries_year(year)
        b = bibliography.query('@*') { 
                |a| (a.year == year and a.public == 'yes')
        }
      end

      def initialize_unique_years()
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
                if entry.field?(:award)
                  # TODO: Awkward -- Find position to insert it. Before the last </div>
                  ts = content_tag "div class=\"csl-award\"", entry.award.to_s
#                  puts ts
#                  puts ts.to_s
                  refPos = reference.rindex('</div>')
                  if refPos.nil? 
#                    puts "NILL"
                  else 
#                    puts "INSERT\n"
#                    puts ts
                    reference.insert( reference.rindex('</div>'), ts.to_s )
                  end
                end
                # Render links if repository specified
                if repository?
                  if not repository_link_for(entry).nil?
                    puts "link is not null"
                    puts repository_link_for(entry)
                    reference << "<a class=\"pure-button\" href=\"" + repository_link_for(entry) + "\">PDF</a>"
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
