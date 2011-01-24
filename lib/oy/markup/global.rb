#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module OY
  module Markup

    class Global < Markup

      # from instiki:
      # https://github.com/parasew/instiki/blob/master/lib/wiki_words.rb
      I18N_HIGHER_CASE_LETTERS =
        "ÀÁÂÃÄÅĀĄĂÆÇĆČĈĊĎĐÈÉÊËĒĘĚĔĖĜĞĠĢĤĦÌÍÎÏĪĨĬĮİĲĴĶŁĽĹĻĿÑŃŇŅŊÒÓÔÕÖØŌŐŎŒŔŘŖŚŠŞŜȘŤŢŦȚÙÚÛÜŪŮŰŬŨŲŴŶŸȲÝŹŽŻ" + 
        "ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ" + 
        "ЀЁЂЃЄЅІЇЈЉЊЋЌЍЎЏАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯѠѢѤѦѨѪѬѮѰѲѴѶѸѺѼѾҀҊҌҎҐҒҔҖҘҚҜҞҠҢҤҦҨҪҬҮҰҲҴҶҸҺҼҾӀӁӃӅӇӉӋӍӐӒӔӖӘӚӜӞӠӢӤӦӨӪӬӮӰӲӴӶӸӺӼӾԀԂԄԆԈԊԌԎԐԒԔԖԘԚԜԞԠԢ" +
        "ԱԲԳԴԵԶԷԸԹԺԻԼԽԾԿՀՁՂՃՄՅՆՇՈՉՊՋՌՍՎՏՐՑՒՓՔՕՖ"
      I18N_LOWER_CASE_LETTERS =
        "àáâãäåāąăæçćĉċčďđèéêëēęěĕėƒĝğġģĥħìíîïīĩĭįıĳĵķĸłľĺļŀñńňņŉŋòóôõöøōŏőœŕřŗśŝšşșťţŧțùúûüūůűŭũųŵýÿŷžżźÞþßſð" +
        "άέήίΰαβγδεζηθικλμνξοπρςστυφχψωϊϋόύώΐ" +
        "абвгдежзийклмнопрстуфхцчшщъыьэюяѐёђѓєѕіїјљњћќѝўџѡѣѥѧѩѫѭѯѱѳѵѷѹѻѽѿҁҋҍҏґғҕҗҙқҝҟҡңҥҧҩҫҭүұҳҵҷҹһҽҿӂӄӆӈӊӌӎӏӑӓӕӗәӛӝӟӡӣӥӧөӫӭӯӱӳӵӷӹӻӽӿԁԃԅԇԉԋԍԏԑԓԕԗԙԛԝԟԡԣ" +
        "աբգդեզէըթժիլխծկհձղճմյնշոչպջռսվտրցւփքօֆև"      

      self.extension = "*"

      def self.is_virtual?
        true
      end
      
      def to_html
        parse_result(data)
      end

      def parse_result(result)
        r = result.gsub(/\[{2}([\/0-9A-Za-z0-9#{I18N_HIGHER_CASE_LETTERS}#{I18N_LOWER_CASE_LETTERS}]+)([A-Za-z0-9#{I18N_LOWER_CASE_LETTERS}#{I18N_HIGHER_CASE_LETTERS}\s]+)?\]{2}/u){|match|
          url = $1.downcase
          cls = begin
                  r=repos.find_by_fragments(url)
                  raise NotFound if r.kind_of?(WikiDir)
                  "x"
                rescue NotFound
                  "o"
                end
          "<a href='/#{url}' class='oy-link #{cls}'>#{($2 || $1).strip}</a>"
        }
        r
      end
    end
    
  end
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
