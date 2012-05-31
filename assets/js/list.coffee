$('document').ready ->
  $('a.delete').click (ev) ->
    ev.preventDefault()
    $.ajax
      url:  $(@).attr('href')
      type: "DELETE"
    .done (data, textStatus, jqXHR) =>
      # Remove the delete item from the DOM tree too
      $(@).parent().remove()
    .fail ->
      console.log 'fail'
