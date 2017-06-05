module KonoUtils
  module FiscalCode
    class ControllaCF
      LT = [[1, '0'], [0, '1'], [5, '2'], [7, '3'], [9, '4'], [13, '5'], [15, '6'], [17, '7'], [19, '8'], [21, '9'], [1, 'A'], [0, 'B'], [5, 'C'], [7, 'D'], [9, 'E'], [13, 'F'], [15, 'G'], [17, 'H'], [19, 'I'], [21, 'J'], [2, 'K'], [4, 'L'], [18, 'M'], [20, 'N'], [11, 'O'], [3, 'P'], [6, 'Q'], [8, 'R'], [12, 'S'], [14, 'T'], [16, 'U'], [10, 'V'], [22, 'W'], [25, 'X'], [24, 'Y'], [23, 'Z']]
      Z9 = ('0'..'9').to_a
      AZ = ('A'..'Z').to_a
      class EmptyString < Exception;
      end
      class InvalidLength < Exception;
      end
      class CaseError < Exception;
      end

      def self.valid?(cf, strict = false)
        cf = cf.to_s
        raise EmptyString.new("codice fiscale non può essere lasciato in bianco") if cf.empty?
        raise InvalidLength.new("codice fiscale dev'essere composto da 16 caratteri alfanumerici") if cf.size != 16
        if strict==true && cf != cf.upcase;
          raise CaseError.new("i caratteri del codice fiscale devono essere maiuscoli");
        else
          cf.upcase!
        end;
        s = (0..14).collect { |i| (i&1)!=0 ? ([Z9.include?(cf[i, 1]) ? cf[i, 1].to_i : AZ.index(cf[i, 1]), cf[i, 1]]) : LT.rassoc(cf[i, 1]) }
        s.include?(nil) ? false : AZ.at((s.transpose[0].inject(0) { |t, n| t+n })%26) == cf[-1, 1]
      end


    end

    class ControllaPI
      NU = ('0'..'9').to_a
      class EmptyString < Exception;
      end
      class InvalidLength < Exception;
      end

      def self.valid?(pi)
        pi = pi.to_s
        raise EmptyString.new("partita iva non può essere lasciata in bianco") if pi.empty?
        raise InvalidLength.new("partita iva dev'essere composta da 11 cifre") if pi.size != 11
        s = (0..9).collect { |i| NU.include?(pi[i, 1]) ? ((i&1)!=0 ? (pi[i, 1].to_i > 4 ? ((pi[i, 1].to_i*2) - 9) : pi[i, 1].to_i * 2) : pi[i, 1].to_i) : nil }
        r = s.include?(nil) ? false : ((s.inject(0) { |t, n| t+n }) % 10)
        r != false && (r==0 ? r : 10-r) == pi[-1, 1].to_i
      end
    end
  end
end