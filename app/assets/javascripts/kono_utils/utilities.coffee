#= require underscore
#= require EventEmitter
#= require moment
#= require bootstrap-datetimepicker
#= require moment/it
#= require bootstrap-treeview


@Kono = @Kono || {};

@Kn = @Kono

##
# http://stackoverflow.com/questions/8730859/classes-within-coffeescript-namespace
# Funzione che si occupa di costruire il namespace se non presente e passarlo come risultato
# la funzione si aspetta una stringa divisa da punti che identificano i vari livelli di namespace
# Es: @Kn.ns 'Kn.admin.iseeprices', (exports)->
#         exports.Form = Form
#         exports.attributi_vari = 'ciao'
# ovviamente senza cancellare i precedenti livelli

@Kn.ns = (target, name, block) ->
  if arguments.length < 3
    tmp = (if typeof exports isnt 'undefined' then exports else window)
    [target, name, block] = [tmp, arguments...]
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top


###
  Si occupa di eseguire il blocco nel caso in cui siamo nel namespace di vista,
  o che sia presente tale namespace.
  eseguo ovviamente il tutto all'interno di un $-> per essere sicuro che la pagina sia caricata
  Viene attaccanto anche un evento per ascoltare i possibili eventi di hashchange di jquery ui
  per ascoltare se una nuova pagina viene inserita.
  ES:
    @Kn.view_ns '.Alim.Admin.IseepricesController.edit', (namespace)->
      fai qualcosa solo se esiste tale namespace

###
@Kn.view_ns = (selector, block) ->
  $ ->
    if $(selector).length > 0
      block(selector)
    else
#      attacco ascoltatore event haschanged
      $(window).on 'hashchange', ->
        block(selector)


###
  Singleton per avere una modal da utilizzare
   funziona attraverso helper bootstrap_please_wait
###
@Kn.show_wait = ->
  $('#processing_wait').modal()

@Kn.hide_wait = ->
  $('#processing_wait').modal('hide')
  #forzo eliminazione di tutti i fade
  $('.modal-backdrop.fade.in').remove()


##
# A tutte le form aggiungo l'autocomplete ad off
$ ->
  $('form').prop('autocomplete', 'off')


##
# picker = new Kn.utilities.DateTimePicker(
#    selector: _.map(view_namespace, (cls)-> "#{cls} #date_time_picker_documents_search_data").join(",")
#    server_format: "YYYY-MM-DDTHH:mm:ss+Z"
#  )
#  picker.initialize()
#
class DateTimePicker

  defaults = server_format: "YYYY-MM-DD HH:mm:ss Z",
  format: 'DD/MM/YYYY',
  server_match: /^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} .$/,
  locale: 'it'

  constructor: (options = {}) ->
    {@selector, @server_format, @format, @server_match, @locale} = _.extend defaults, options
    @input_date = @parse_input_value()

  initialize: ->
    if @input_date
      val = @input_date
      val = @input_date.format(@format) if _.isFunction(@input_date.format)
      $(@selector).find("input").val(val)

    $(@selector).datetimepicker(@picker_configs())

  picker_configs: ->
    {
      format: @format,
      locale: @locale
    }

  parse_input_value: ->
    value = $(@selector).find("input").attr('value')
    unless value == '' or _.isUndefined(value)
      if @server_match.test(value)
        return moment(value, @server_format)
      else
        return value
    false


##
# Definisce l'elemento associato alla data finale di un range di date
  set_end: (@end_pick)->
    $(@selector).data("DateTimePicker").maxDate(@end_pick.input_date) if @end_pick.input_date

    $("#{@end_pick.selector}").on "dp.change", (e) =>
      $(@selector).data("DateTimePicker").maxDate(e.date)

##
# Definisce l'elemento associato alla data iniziale di un range di date
  set_start: (@start_pick)->
    $(@selector).data("DateTimePicker").minDate(@start_pick.input_date) if @start_pick.input_date

    $("#{@start_pick.selector}").on "dp.change", (e) =>
      $(@selector).data("DateTimePicker").minDate(e.date)


@Kn.ns 'Kn.utilities', (exports)->
  exports.DateTimePicker = DateTimePicker

class TimePicker extends DateTimePicker
  defaults = server_format: "HH:mm",
  format: 'HH:mm',
  server_match: /[0-9]{2}:[0-9]{2} .$/

  picker_configs: ->
    _.extend super(), {format: 'HH:mm'}


@Kn.ns 'Kn.utilities', (exports)->
  exports.TimePicker = TimePicker


##
# Eventi generali Jquery
$ ->
  $('.collapse_search').click (e) ->
    e.preventDefault();
    $('.search_panel .collapsible_panel').slideToggle()
  $('.search_panel .collapsible_panel').slideUp() unless $('.search_panel .collapsible_panel.uncollapsed').length > 0


## Trasformare form bootstrap da label posizionate sopra a input a sinistra
# Default:
# label_cls: 'col-sm-2'
# wrapp_cls: 'col-sm-10'
$.fn.extend
  bs3_form_inline: (options)->
    settings =
      label_cls: 'col-sm-2'
      wrapp_cls: 'col-sm-10'

    settings = $.extend settings, options
    return @each () ->
      $(this).find('.form-group .form-label').addClass settings.label_cls
      $(this).find('.form-group .form-wrapper').addClass settings.wrapp_cls


duplicate_button_toggle = (btn)->
  if $(btn.parentNode).find('.remove_row,.add_one_more').length == 1
    if $(btn.parentNode).find('.remove_row').length == 0
      rem_class = 'add_one_more'
      add_class = 'remove_row'
      ico_rem_class = 'fa-plus'
      ico_add_class = 'fa-minus'
    if $(btn.parentNode).find('.add_one_more').length == 0
      rem_class = 'remove_row'
      add_class = 'add_one_more'
      ico_rem_class = 'fa-minus'
      ico_add_class = 'fa-plus'

    $(btn).clone().appendTo(btn.parentNode).
    removeClass(rem_class).
    addClass(add_class).
    find('.fa').
    removeClass(ico_rem_class).
    addClass(ico_add_class)

elaborate_buttons = (tabella)->
#  numero_elementi = $(tabella).find('.add_one_more').length
  $(tabella).find('.add_one_more').each (index, ele)->
    duplicate_button_toggle(ele)
  if $(tabella).find('tr:not(.multiple_table_remove_row) .remove_row').length == 1
    $(tabella).find('tr:not(.multiple_table_remove_row) .remove_row').first().remove()


## Gestione elementi multipli
# Eventi sulla tabella:
# - row_append  : lanciato quando viene appeso una nuova riga, parametri: tabella,riga appena aggiunta
# - row_removed : lanciato quando viene rimossa una nuova riga, parametri: tabella,riga appena rimossa
$.fn.extend
  multiple_table: (options) ->
#    settings =
#      label: ".form-label"
#      content: ".form-wrapper"
#
#    settings = $.extend settings, options
    return @each () ->
      tabella = @
      elaborate_buttons(tabella)


      $(tabella).on 'click', '.remove_row', (e)->
        e.preventDefault()
        row = $(@).closest('tr')
        row.hide().addClass('multiple_table_remove_row')
        $(@).find('[type="hidden"]').val('true')
        elaborate_buttons(tabella)
        $(tabella).trigger("row_removed", [tabella, row]);

      $(tabella).on 'click', '.add_one_more', (e)->
        e.preventDefault()
        row = $(@).closest('tr').clone(false, true)
        uid = $(@).closest('tbody').find('tr').length
        $(row).find('input,select').val('').each ->
          name = $(@).attr('name').replace(/\[[0-9]+\]/, "[#{uid}]")
          $(@).attr('name', name)
          $(@).removeAttr('disabled')

        row.appendTo($(@).closest('tbody'))
        elaborate_buttons(tabella)
        $(tabella).trigger("row_append", [tabella, row]);

##fine

## Gestione bottone di cancellazione
# Precedentemente alla rimozione dell'elemento viene
# lanciato un evento che notifica tale cancellazione "component_removed"
$.fn.extend
  kono_delete_button: ()->
    return @each () ->
      $(this).on 'submit', (e) ->
        e.preventDefault()
        form = $(this)
        form.closest('.modal').modal('hide')
        $.ajax
          url: form.prop('action')
          data: form.serialize()
          method: 'DELETE'
          success: (data)->
            $('.modal-backdrop').remove() #rimuovo la modal
            $('body').removeClass('modal-open') #rimuovo la classe che blocca
            if data.success
              base_component = $(form.data('callbackRemove'))
              base_component.trigger('component_removed', [form.data('callbackRemove'), data]);
              base_component.hide('fast').remove()


##
# Classe per la gestione delle form Modal
#
# Eventi:
#   close_modal             -> self
#   rescue_invalid_content  -> self,response,jquery(dom modal)
#   success                 -> ajax_response

class ModalForm extends EventEmitter

  defaults = {success: (->)}

  constructor: (@modal, options = {}) ->
    super
    {@success} = _.extend defaults, options
    @form = $(@modal).find('form').get(0)
    @modal_id = $(@modal).attr('id')
    @initialize_callbacks()

  inject_format: (format = 'json')->
    $(@form).append("<input type='hidden' value='#{format}' name='format'>")

  close_modal: ->
    $(@modal).modal('hide')
    $('.modal-backdrop').remove()
    $('body').removeClass('modal-open')
    $(@form).get(0).reset()
    @emitEvent('close_modal', [@]);

  rescue_invalid_content: (response)->
# ricevendo in risposta la modal sostituirò la modal attuale,
# attacco tutte le opzioni di questa classe.
    @close_modal()
    mod = $(response.partial).appendTo($('body'))
    id = Date.now()
    $(mod).prop('id', id).modal('show')
    modal = new @.__proto__.constructor(mod)
    @propagate_events_on_child(modal)
    @emitEvent('rescue_invalid_content', [@, response, modal])
    return {response: response, modal: modal}


# Si occupa di propagare gli eventi attaccati sul padre pannello sui vari figli
  propagate_events_on_child: (child)->
    events = @_getEvents()
    _.each events, (v, k) =>
      child.on k, =>
        @emitEvent(k, arguments)


  initialize_callbacks: ->
    @inject_format()
    $(@form).on 'submit', (e) =>
      Kn.show_wait()
      e.preventDefault()
      $.ajax
        url: $(@form).prop('action')
        method: $(@form).prop('method')
        data: $(@form).serialize()
        success: =>
          @_on_success(arguments)
        error: (xhr) =>
          @_on_error(xhr)

##
# funzione privata eseguita al success
  _on_success: (args)->
    @close_modal()
    Kn.hide_wait()
    @emitEvent('success', args);

  _on_error: (xhr)->
    Kn.hide_wait()
    switch parseInt(xhr.status/100)*100
      when 400 then @rescue_invalid_content(xhr.responseJSON)
      when 500 then alert("Attenzione, problemi nello svolgimento dell'operazione contattare amministratore")


@Kn.ns 'Kn.utilities', (exports)->
  exports.ModalForm = ModalForm


class ModalNewButton extends ModalForm

  ##
  # Funzione per ricaricare la modal
  # Esegue un'ajax alla pagina corrente, ricercando l'elemento con l'id uguale a quello di se stesso,
  # rimpiazza quindi la precedente modal di creazione e riattacca tutti gli eventi al modal appena creato.
  # sucessivamente rimuove l'elemento iniziale e lancia l'evento "self_reloaded" per poter far eventualemnte ulteriori
  # modifiche sul modal appena generato
  self_reload: ()->
    @_self_reload(@)

  _self_reload: ()->
    Kn.show_wait()
    id = "tmp#{(new Date()).getTime()}"
    $('body').append("<div id='#{id}'></div>")
    $("##{id}").load "#{window.location.href} ##{@modal_id}", ()=>
      ele = $("##{id}>*")
      $(ele).attr('generated_id', id)
      pre_modal = $("##{@modal_id}")
      pre_modal.after(ele)
      modal = new @__proto__.constructor(ele)
      @propagate_events_on_child(modal)
      @emitEvent('self_reloaded', [modal, @])
      pre_modal.remove()
      Kn.hide_wait()


@Kn.ns 'Kn.utilities', (exports)->
  exports.ModalNewButton = ModalNewButton


###
Classe che gestisce la UI per il bottone edit

###
class ModalEditButton extends ModalForm

  constructor: (@btn_blk, options = {}) ->
    @updatable_content = $(@btn_blk).data('updatableContent')
    if $(@btn_blk).hasClass('kono_modal_form')
      super(@btn_blk, options)
    else
      super($(@btn_blk).find('.kono_modal_form').get(0), options)

  _on_success: (args)->
    super
    data = args[0]
    if @updatable_content
      $(@updatable_content).replaceWith(data.partial)
      #seleziono il nuovo pannello
      panel = $(@updatable_content)
      panel.find('.kono_edit_button').each (index,ele) =>
        new_panel = new @.__proto__.constructor(ele)
        new_panel.modal.updatable_content = @updatable_content
        #rillacciamo gli eventi del vecchio pannello su quello nuovo
        @propagate_events_on_child(new_panel)
        @emitEvent('rendered', [@, panel, new_panel])

  rescue_invalid_content: (response)->
    res = super
    res.modal.updatable_content = @updatable_content


  initial_classes: ->
    _.reduce _.compact($(@btn_blk).prop('class').split(' ')), (memo, str)->
      "#{memo}.#{str}"
    , ''


@Kn.ns 'Kn.utilities', (exports)->
  exports.ModalEditButton = ModalEditButton


class BasePannel

  form_inline_settings:
    label_cls: 'col-xs-12 col-sm-4',
    wrapp_cls: 'col-xs-12 col-sm-8'

  constructor: (@blk) ->
    $(@blk).bs3_form_inline @form_inline_settings
    @initialize_events()

  initialize_events: ->
    ele = $(@blk).find('.kono_edit_button').get(0)
    if(ele)
      panel = new Kn.utilities.ModalEditButton ele
      panel.on 'rendered', (button, panel)->
        $(panel).bs3_form_inline @form_inline_settings
      panel.on 'rescue_invalid_content', (a, b, c)->
        $(c.modal).bs3_form_inline @form_inline_settings

@Kn.ns 'Kn.utilities', (exports)->
  exports.BasePannel = BasePannel

## Gestione Generazione Mappa google per Input LocationPicker
#
$.fn.extend
  kono_util_location_picker: (options)->
    settings =
      center: {lat: 42.908, lng: 12.303}
      selector_field_lat: 'input[name="lat"]'
      selector_field_lng: 'input[name="lat"]'
      zoom_level: 5

    settings = $.extend settings, options

    return @each () ->
      map = new google.maps.Map(@, {
        zoom: settings.zoom_level,
        center: settings.center
      })
      marker = new google.maps.Marker({
        position: settings.center,
        draggable: true,
        map: map
      })
      marker.addListener 'drag', (data) ->
        $(settings.selector_field_lat).val(data.latLng.lat())
        $(settings.selector_field_lng).val(data.latLng.lng())
