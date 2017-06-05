##
# Classe per la stampa del DatePicker con bootstrap
#
#
class BsDatepickerInput < BsDatetimepickerInput


  def default_javascript_options
    {
        server_format: 'YYYY-MM-DD',
        server_match: '/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/',
        format: 'DD/MM/YYYY'
    }
  end

end
