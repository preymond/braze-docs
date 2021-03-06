# https://github.com/dimitri-koenig/jekyll-plugins
# modified to allow variable url
require 'net/http'
require 'uri'

module Jekyll

  class AlloyPartner < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @url = markup.strip
      super
    end

    def render(context)
      site = context.registers[:site]
      # partnerembed = context.config['partner_api']
      partnerembed = site.config['partner_api']

      if partnerembed
        url = context[@url.strip]
        if context['site']['data'].include?(url)
          puts 'Using cache for: ' + url
          return context['site']['data'][url]
        else
          puts 'Fetching content of url: ' + url
          if url =~ URI::regexp
            @results = fetchContent(url)
          else
            puts 'Error fetching: ' + url
          end

          if @results.code != '200'
            puts 'Error returning results: ' + url
            return '{}'
          else
            if @results.body
              context['site']['data'][url] = @results.body.force_encoding('UTF-8')
              return context['site']['data'][url]
            else
              puts 'Empty content from : ' + url
              return '{}'
            end
          end
        end
      else
        return '{}'
      end
    end

    def fetchContent(url)
      Net::HTTP.get_response(URI.parse(URI.encode(url.strip)))
    end
  end
end

Liquid::Template.register_tag('alloy_partner', Jekyll::AlloyPartner)
