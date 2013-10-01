Tabulatr = {
  moreResults: true,
  storePage: false,
  currentData: null,
  locked: false,

  updatePagination: function(currentPage, numPages, tableId){
    var ul = $('.pagination[data-table='+ tableId +'] > ul');
    if(ul.length == 0){
      // bootstrap 3
      ul = $('.pagination[data-table='+ tableId +']');
    }
    ul.html('');
    if(numPages < 13){
      for(var i = 1; i <= numPages; i++){
        var cls = '';
        if(i == currentPage){
          cls = 'active';
        }
        ul.append('<li class="'+ cls +'"><a href="#" data-page="'+ i+'">'+
          i +'</a></li>');
      }
    }else{
      if(currentPage > 1){
        ul.append('<li><a href="#" data-page="1">1</a></li>');
      }

      var between = Math.floor((1 + currentPage) / 2);
      if(between > 1 && between < currentPage - 2){
        ul.append('<li><span>...</span></li>');
        ul.append('<li><a href="#" data-page="'+ between +'">'+ between +'</a></li');
      }

      if(currentPage > 4){
        ul.append('<li><span>...</span></li>');
      }

      if(currentPage > 3){
        ul.append('<li><a href="#" data-page="'+ (currentPage - 2) +'">'+
          (currentPage-2) +'</a></li>');
        ul.append('<li><a href="#" data-page="'+ (currentPage - 1) +'">'+
          (currentPage-1) +'</a></li>');
      }

      ul.append('<li class="active"><a href="#" data-page="'+ currentPage +'">'+
        currentPage +'</a></li>');

      if(currentPage < numPages - 1){
        ul.append('<li><a href="#" data-page="'+ (currentPage+1) +'">'+
          (currentPage+1) +'</a></li>');
      }

      if(currentPage < numPages - 2){
        ul.append('<li><a href="#" data-page="'+ (currentPage+2) +'">'+
          (currentPage+2) +'</a></li>');
      }

      if(currentPage < numPages - 3){
        ul.append('<li><span>...</span></li>');
      }

      between = Math.floor((currentPage + numPages) / 2);

      if(between > currentPage + 3 && between < numPages - 1){
        ul.append('<li><a href="#" data-page="'+ between +'">'+
          between +'</a></li>');
        ul.append('<li><span>...</span></li>');
      }
      if(currentPage < numPages){
        ul.append('<li><a href="#" data-page="'+ numPages +'">'+
          numPages +'</a></li>');
      }
    }

  },

  updateTable: function(hash, tableId, forceReload) {
    if(hash.page !== undefined && !forceReload){
      //old page should be stored
      Tabulatr.storePage = true;
      // check if this page was already loaded
      if($('#'+ tableId + ' tbody tr[data-page='+ hash.page +']').length > 0){
        $('#'+ tableId + ' tbody tr').hide();
        $('#'+ tableId + ' tbody tr[data-page='+ hash.page +']').show();

        Tabulatr.updatePagination(hash.page,
          $('.pagination[data-table='+ tableId +'] a:last').data('page'),
          tableId);
        return;
      }
    }else{
      Tabulatr.storePage = false;
    }
    if(Tabulatr.locked){ return; }
    Tabulatr.locked = true;
    jQuery.get($('table#'+ tableId).data('path') + '.json',
        Tabulatr.createParameterString(hash, tableId),
        Tabulatr.handleResponse
      );
  },

  checkIfCheckboxesAreMarked: function(){
    return $('tr[data-page] input[type=checkbox]:checked').length > 0;
  },

  handleResponse: function(response) {
    Tabulatr.insertTabulatrData(response);
    Tabulatr.updatePagination(response.meta.page, response.meta.pages, response.meta.table_id);
    Tabulatr.locked = false;
  },

  insertTabulatrData: function(response){
    columns = [];
    tableId = response.meta.table_id;
    tableName = tableId.split('_')[0];
    if(!response.meta.append){
      if(Tabulatr.storePage){
        $('#'+ tableId +' tbody tr').hide();
      }else{
        $('#'+ tableId +' tbody').html('');
      }
    }
    if(response.data.length == 0){
      Tabulatr.moreResults = false;
      $('.tabulatr_count[data-table='+ tableId +']').unbind('inview');
    }else{
      if(response.data.length < response.meta.pagesize){
        Tabulatr.moreResults = false;
        $('.tabulatr_count[data-table='+ tableId + ']').unbind('inview');
      }else{
        Tabulatr.moreResults = true;
      }
      $('#'+ tableId +' th').each(function(ix,el){
        var column_name = $(el).data('tabulatr-column-name');
        var association = $(el).data('tabulatr-association');
        var column_type = $(el).data('tabulatr-column-type');
        var action = $(el).data('tabulatr-action');
        var callback_methods = $(el).data('tabulatr-methods').split(',');
        columns.push({ name: column_name,
                       methods: callback_methods,
                       type: column_type,
                       association: association,
                       action: action });
      });
      $('.empty_row').remove();


      for(var i = 0; i < response.data.length; i++){
        $tr = $('<tr data-page="'+ response.meta.page +'"></tr>');
        var td = '';
        var column;
        for(var c = 0; c < columns.length; c++){
          column = columns[c];
          if(column.association === undefined){
            var value = response.data[i][column.name];
          }else{
            try{
              var assoc = response.data[i][column.association];
              if(Array.isArray(assoc)){
                var arry = [];
                for(var j = 0; j < assoc.length; j++){
                  arry.push(assoc[j][column.name]);
                }
                var value = arry.join(', ');
              }else{
                var value = response.data[i][column.association][column.name];
              }
            }catch(e){
              var value = '';
            }
          }
          var formatters = column.methods;
          $td = $('<td></td>');
          if(column.type == 'checkbox'){
            $td.html(Tabulatr.makeCheckboxFor(response.data[i]));
          }else if(column.type == 'action'){
            $td.html(Tabulatr.makeAction(column.action, response.data[i]));
          }else{
            if(value === false){
              value = "false"; // because false won't be displayed
            }
            $td.html(value);
            for(var j = 0; j < formatters.length; j++){
              var fn = Tabulatr[formatters[j]];
              if(typeof fn === 'function'){
                try{
                  var result = fn(value, $td, $tr, response.data[i]);
                  if(result != null && result !== undefined){
                    $td.html(result);
                    value = result;
                  }
                }catch(e){
                  $td.html('<span class="error">#ERROR</span>');
                }
              }
            }
          }
          td += $td[0].outerHTML;
        }
        $tr.append(td);
        $('#'+ tableId +' tbody').append($tr);
      }
    }
    var count_string = $('.tabulatr_count[data-table='+ tableId +']').data('format-string');
    count_string = count_string.replace(/%\{current\}/, response.meta.count);
    count_string = count_string.replace(/%\{total\}/, response.meta.total);
    count_string = count_string.replace(/%\{per_page\}/,
      response.meta.pagesize);
    $('.tabulatr_count[data-table='+ tableId +']').html(count_string);

  },

  makeCheckboxFor: function(data){
    return "<input type='checkbox' value='"+ data.id +
    "' class='tabulatr-checkbox' />";
  },

  replacer: function(match, attribute, offset, string){
    return Tabulatr.currentData[attribute];
  },


  makeAction: function(action, data){
    Tabulatr.currentData = data;
    return unescape(action).replace(/{{([\w:]+)}}/g, Tabulatr.replacer);
  },

  createParameterString: function(hash, tableId){
    tableName = tableId.split('_')[0];
    if(hash === undefined){
      hash = {};
      hash.append = false;
    }
    if($('#'+ tableId +' i.sorted').length == 1){
      hash.sort_by = $('#'+ tableId +' i.sorted').closest('th').data('tabulatr-sorting-name');
      if($('#'+ tableId +' i.sorted').data('sort') == 'asc'){
        hash.orientation = 'desc';
      }else{
        hash.orientation = 'asc';
      }
    }
    if(hash.pagesize === undefined){
      var pagesize = $('.tabulatr-per-page[data-table='+ tableId +'] a.active').data('items-per-page');
      if(pagesize == null){ pagesize = 10; }
    }
    if(hash.page === undefined){
      hash.page = Math.floor($('#'+ tableId +' tbody tr[class!=empty_row]').length/pagesize) + 1;
      if(!isFinite(hash.page)){
        hash.page = 1;
      }
    }
    hash.pagesize = pagesize;
    hash.arguments = $.map($('#'+ tableId +' th'), function(n){ return $(n).data('tabulatr-column-name') })
                      .filter(function(n){return n}).join();
    hash.hash = $('#tabulatr_security_'+ tableName).data('hash');
    hash.salt = $('#tabulatr_security_'+ tableName).data('salt');
    hash.table_id = tableId;
    var form_array = $('.tabulatr_filter_form[data-table='+ tableId +']').serializeArray();
    for(var i = 0; i < form_array.length; i++){
      hash[form_array[i].name] = form_array[i].value;
    }
    return hash;
  },

  localDate: function(value, $td, $tr, obj){
    return new Date(value).toLocaleString();
  }
}

$(document).on('ready page:load', function(){

  $('.tabulatr-sort').click(function(){
    orientation = $(this).data('sort');
    $($(this).parents('tr').find('.tabulatr-sort')).removeClass('sorted');
    $(this).addClass('sorted');
    var tableId = $(this).parents('table').attr('id');
    var tableName = tableId.split('_')[0];
    $($(this).parents('table').find('tbody tr')).remove();
    $('.tabulatr_filter_form[data-table='+ tableId +'] input[name=orientation]').val(orientation);
    var sort_by = $(this).closest('th').data('tabulatr-sorting-name');
    $('.tabulatr_filter_form[data-table='+ tableId +'] input[name=sort_by]').val(sort_by);
    if(orientation == 'asc'){
      $(this).removeClass('icon-arrow-down').addClass('icon-arrow-up');
      $(this).data('sort', 'desc');
    }else{
      $(this).addClass('icon-arrow-up').addClass('icon-arrow-down');
      $(this).data('sort', 'asc');
    }
    if(!Tabulatr.moreResults){
      Tabulatr.moreResults = true;
      if($('.pagination[data-table='+ tableId +']').length == 0){
        $('.tabulatr_count[data-table='+ tableId +']').bind('inview', cbfn);
      }
    }

    $('.tabulatr_mark_all[data-table='+ tableName +']').prop('checked', false).prop('indeterminate', false);
    Tabulatr.updateTable({}, tableId);
  });

  var cbfn = function(event, isInView, visiblePartX, visiblePartY) {
    if (isInView) {
      // element is now visible in the viewport
      if (visiblePartY == 'top') {
        // top part of element is visible
      } else if (visiblePartY == 'bottom') {
        // bottom part of element is visible
      } else {
        Tabulatr.updateTable({append: true}, $(event.currentTarget).data('table'));
      }
    }
  };

  $('.tabulatr_table').each(function(ix, el){
    if($('.pagination[data-table='+ $(el).attr('id') +']').length == 0){
      $('.tabulatr_count[data-table='+ $(el).attr('id') +']').bind('inview', cbfn);
    }
  });

  $('.batch-action-inputs').click(function(){
    params = {page: 1};
    params[$(this).attr('name')] = $(this).val();
    var tableId = $(this).closest('table').attr('id');
    params['tabulatr_checked'] = {checked_ids: jQuery.map($('#'+ tableId +' .tabulatr-checkbox:checked'), function(el){return $(el).val();}).join(',')};
    $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false).prop('checked', false);
    $('#'+ tableId +' .tabulatr-wrench').addClass('disabled');
    Tabulatr.updateTable(params, tableId, true);
  });

  $('form.tabulatr_filter_form').submit(function(ev){
    var tableId = $(this).data('table');
    Tabulatr.updateTable({page: 1, append: false}, tableId, true);
    var ary = $(this).serializeArray();
    $('#'+ tableId +' th').removeClass('tabulatr_filtered_column');
    $('#'+ tableId +' i.icon-remove-sign').remove();
    for(var i = 0; i < ary.length; i++){
      if(ary[i].value != ""){
        var name = ary[i].name.replace(/\[(like|checkbox|from|to)\]/, '');
        name = name.replace(/(:|\.|\[|\])/g,'\\$1');
        // var attr = $(this).find("input[name="+ name +"]").data('tabulatr-attribute');
        var $col = $('#'+ tableId +' th[data-tabulatr-form-name^='+ name +']');
        if($col.length > 0){
          $col.addClass('tabulatr_filtered_column');
          // icon-remove-sign
          $col.append('<i class="icon-remove-sign '+
            'tabulatr_remove_filter" ></i>');
        }
      }
    }
    $('#tabulatr_filter_dialog_'+ tableId.split('_')[0]).modal('hide');
    return false;
  });

  $('.tabulatr_table').on('click', 'i.tabulatr_remove_filter', function(){
    var $th = $(this).closest('th');
    var name = $th.data('tabulatr-form-name').
                  replace(/\[(like|checkbox|from|to)\]/, '');
    name = name.replace(/(:|\.|\[|\])/g,'\\$1');
    $th.removeClass('tabulatr_filtered_column');
    if($('[name^='+ name +']').is(':checkbox')){
      $('[name^='+ name +']').prop('checked', false);
    }else{
      $('[name^='+ name +']').val('');
    }
    var tableId = $(this).closest('.tabulatr_table').attr('id');
    $(this).remove();
    Tabulatr.updateTable({}, tableId);
    return false;
  });

  $('.tabulatr_mark_all').click(function(){
    var tableId = $(this).data('table');
    if($(this).is(':checked')){
      $('#'+ tableId +' tr[data-page]:visible input[type=checkbox]').prop('checked', true);
      $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
    }else{
      $('#'+ tableId +' tr[data-page]:visible input[type=checkbox]').prop('checked', false);
      if(Tabulatr.checkIfCheckboxesAreMarked()){
        $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
      }else{
        $('#'+ tableId +' .tabulatr-wrench').addClass('disabled');
      }
    }
  });

  $('.tabulatr_table').on('click', 'input.tabulatr-checkbox', function(){
    var tableId = $(this).closest('.tabulatr_table').attr('id');
    if($(this).is(':checked')){
      if($('#'+ tableId +' tr[data-page]:visible input[type=checkbox]').not(':checked').length > 0){
        $('.tabulatr_mark_all[data-table='+ tableId +']').prop("indeterminate", true);
      }else{
        $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false);
        $('.tabulatr_mark_all[data-table='+ tableId +']').prop('checked', true);
      }
      $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
    }else{
      if($('#'+ tableId +' tr[data-page]:visible input[type=checkbox]:checked').length > 0){
        $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', true);
        $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
      }else{
        $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false);
        $('.tabulatr_mark_all[data-table='+ tableId +']').prop('checked', false);
        if(Tabulatr.checkIfCheckboxesAreMarked()){
          $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
        }else{
          $('#'+ tableId +' .tabulatr-wrench').addClass('disabled');
        }
      }
    }
  });

  $('.tabulatr-per-page a').click(function(){
    if($(this).hasClass('active')){ return false; }
    $(this).closest('div').find('a').removeClass('active');
    $(this).addClass('active');
    var tableId = $(this).closest('div').data('table');
    Tabulatr.moreResults = true;
    if($('.pagination[data-table='+ tableId +']').length == 0){
      $('.tabulatr_count[data-table='+ tableId +']').bind('inview', cbfn);
    }
    if(typeof(Storage) !== undefined){
      localStorage.tabulatr_page_display_count = $(this).data('items-per-page');
    }
    Tabulatr.updateTable({page: 1}, tableId, true);
  });

  if($('.tabulatr_table').length > 0){
    if(typeof(Storage) !== undefined){
      var count = localStorage.tabulatr_page_display_count;
      if(count !== undefined){
        $('.tabulatr-per-page a').removeClass('active');
        $('.tabulatr-per-page a[data-items-per-page='+ count +']').
          addClass('active');
      }
    }
    $('.tabulatr_table').each(function(ix, el){
      Tabulatr.updateTable({}, $(el).attr('id'));
    });
  }
});

$(document).on('click', '.pagination a', function(){
  var a = $(this);
  if(a.parent().hasClass('active') ||
     a.parent().hasClass('disabled')){
    return;
  }
  var tableId = $(a).closest('.pagination').data('table');
  $('.tabulatr_mark_all[data-table='+ tableId +']').prop('checked', false);
  $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false);
  Tabulatr.updateTable({append: false, page: a.data('page')}, tableId);
  return false;
});
