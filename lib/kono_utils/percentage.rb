require 'action_view'
module KonoUtils
##
# Classe che si occupa di rappresentare un numero percentuale
# ES:
# p = Percentage.new(100,20)
# p.percentage -> ritorna il valore percentuale float
# p.to_i -> ritorna percentuale intera con relativi arrotondamenti
# p.to_percentage -> si comporta come l'helper number_to_percentage
  class Percentage

    include ActionView::Helpers::NumberHelper

    attr_accessor :total, :partial

    def initialize(total=0, partial=0)
      @total = total
      @partial = partial
    end

    ##
    #
    # * *Args*    :
    #   - options -> Hash :
    #                 :locale - Sets the locale to be used for formatting (defaults to current locale).
    #
    #                 :precision - Sets the precision of the number (defaults to 3).
    #
    #                 :significant - If true, precision will be the # of significant_digits. If false, the # of fractional digits (defaults to false).
    #
    #                 :separator - Sets the separator between the fractional and integer digits (defaults to “.”).
    #
    #                 :delimiter - Sets the thousands delimiter (defaults to “”).
    #
    #                 :strip_insignificant_zeros - If true removes insignificant zeros after the decimal separator (defaults to false).
    #
    #                 :format - Specifies the format of the percentage string The number field is %n (defaults to “%n%”).
    #
    #                 :raise - If true, raises InvalidNumberError when the argument is invalid.
    # * *Returns* :
    #   - String
    #
    def to_percentage(options = {})
      number_to_percentage(percentage, options)
    end

    def percentage
      return 0 if @partial==0
      return 0 if @total<@partial
      @partial.to_f/@total.to_f*100.0
    end

    def to_i
      return 100 if @total.to_s == @partial.to_s
      percentage.to_i
    end


  end
end