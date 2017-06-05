class BsTimepickerInput < BsDatetimepickerInput

  def icon
    fa_icon("clock-o".to_sym)
  end

  def default_javascript_options
    {
        server_format: 'YYYY-MM-DD HH:mm:ss UTC',
        server_match: '/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} UTC$/',
        format: 'HH:mm'
    }
  end
end
