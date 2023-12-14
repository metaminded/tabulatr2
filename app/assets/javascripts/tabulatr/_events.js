function tabulatrInitialize() {
  tabulatr_tables = [];

  $('th.tabulatr-sortable').click(function(){
    var th = $(this);
    var sort_by = th.data('tabulatr-column-name');
    var dir = th.attr('data-sorted');
    var table = th.parents('table');
    var tableId = table.attr('id');
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    var tableName = table_obj.id.split('_')[0];
    table.find('th.tabulatr-sortable.sorted').removeClass('sorted').removeAttr('data-sorted');
    dir = (dir === 'asc') ? 'desc' : 'asc';
    th.addClass('sorted').attr('data-sorted', dir);
    $('.tabulatr_filter_form[data-table='+ tableId +'] input[name='+ tableName +'_sort]').val(sort_by + ' '+  dir);
    if(!table_obj.moreResults){
      table_obj.moreResults = true;
      if(table_obj.hasInfiniteScrolling){
        $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
      }
    }
    $($(this).parents('table').find('tbody.tabulatr-main-tbody tr')).remove();

    $('.tabulatr_mark_all[data-table='+ tableName +']').prop('checked', false).prop('indeterminate', false);
    table_obj.updateTable({});
  });


  $('.tabulatr_table').each(function(ix, el){
    if($('.pagination[data-table="'+ $(el).attr('id') +'"]').length === 0){
      $('.pagination_trigger[data-table="'+ $(el).attr('id') +'"]').bind('inview', cbfn);
    }
  });

  $('.batch-action-inputs').click(function(){
    var a = $(this);
    var name = a.data('do-batch-action-name');
    var key = a.data('do-batch-action');
    var tableId = a.data('table-id');
    var params = {page: 1};
    var use_ajax = !a.data('download');
    params[name] = key;
    params.tabulatr_checked = {checked_ids: jQuery.map($('#'+ tableId +' .tabulatr-checkbox:checked'), function(el){return $(el).val();}).join(',')};
    var confirmation = true;
    if(params.tabulatr_checked.checked_ids === ''){
      confirmation = window.confirm(a.parents('ul').data('confirm-text'));
    }
    if(confirmation){
      $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false).prop('checked', false);
      $('#'+ tableId +' .tabulatr-wrench').addClass('disabled');
      var table_obj;
      for(var i = 0; i < tabulatr_tables.length; i++){
        if(tabulatr_tables[i].id === tableId){
          table_obj = tabulatr_tables[i];
        }
      }
      if (use_ajax)
        table_obj.updateTable(params, true);
      else
        table_obj.sendRequestWithoutAjax(params, a.data('extension'));
    }
  });

  $('form.tabulatr-fuzzy-search').submit(function(){
    var tableId = $(this).data('table');
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    if(table_obj.hasInfiniteScrolling){
      $('.pagination_trigger[data-table='+ tableId +']').unbind('inview', cbfn);
      $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
    }
    table_obj.updateTable({page: 1, append: false}, true);
    return false;
  });

  $('form.tabulatr_filter_form input, form.tabulatr_filter_form select').change(function(){
    $(this).parents('form.tabulatr_filter_form').submit();
  });

  $('form.tabulatr_filter_form input').on('dp.change', function(){
    $(this).parents('form.tabulatr_filter_form').submit();
  });

  $('form.tabulatr_filter_form').submit(function(){
    var tableId = $(this).data('table');
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    table_obj.submitFilterForm();
    return false;
  });

  $('.tabulatr_mark_all').click(function(){
    var tableId = $(this).parents('table').prop('id');
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    if($(this).is(':checked')){
      $('#'+ tableId +' tr[data-page]:visible input[type=checkbox]').prop('checked', true);
      $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
    }else{
      $('#'+ tableId +' tr[data-page]:visible input[type=checkbox]').prop('checked', false);
      if(table_obj.checkIfCheckboxesAreMarked()){
        $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
      }else{
        $('#'+ tableId +' .tabulatr-wrench').addClass('disabled');
      }
    }
  });

  $('.tabulatr_table').on('click', 'input.tabulatr-checkbox', function(){
    var $table = $(this).closest('.tabulatr_table');
    var tableId = $table.attr('id');
    var $markAllCheckbox = $table.find('.tabulatr_mark_all');
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    if($(this).is(':checked')){
      if($('#'+ tableId +' tr[data-page]:visible input[type=checkbox]').not(':checked').length > 0){
        $markAllCheckbox.prop("indeterminate", true);
      }else{
        $markAllCheckbox.prop('indeterminate', false);
        $markAllCheckbox.prop('checked', true);
      }
      $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
    }else{
      if($('#'+ tableId +' tr[data-page]:visible input[type=checkbox]:checked').length > 0){
        $markAllCheckbox.prop('indeterminate', true);
        $('#'+ tableId +' .tabulatr-wrench').removeClass('disabled');
      }else{
        $markAllCheckbox.prop('indeterminate', false);
        $markAllCheckbox.prop('checked', false);
        if(table_obj.checkIfCheckboxesAreMarked()){
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
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    table_obj.moreResults = true;
    if(table_obj.hasInfiniteScrolling){
      $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
    }
    if(typeof(Storage) !== undefined){
      try {
        localStorage.tabulatr_page_display_count = $(this).data('items-per-page');
      } catch(e) {}
    }
    table_obj.updateTable({page: 1}, true);
  });

  $(document).on('click', 'a[data-tabulatr-reset]',function(){
    var a = $(this);
    var tableObj;
    var tableId = a.data('tabulatrReset');
    a.parents('.tabulatr-outer-wrapper').removeClass('filtered');
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        tableObj = tabulatr_tables[i];
        tableObj.resetTable();
        return false;
      }
    }
  });

  if($('.tabulatr_table:not(".tabulatr_static_table")').length > 0){
    if(typeof(Storage) !== undefined){
      try {
        var count = localStorage.tabulatr_page_display_count;
        if(count !== undefined){
          $('.tabulatr-per-page a').removeClass('active');
          $('.tabulatr-per-page a[data-items-per-page='+ count +']').
            addClass('active');
        }
      } catch(e) {}
    }
    var tableObj, tableId, tabulatrTable;
    $('.tabulatr_table:not(".tabulatr_static_table")').each(function(ix, el){
      tableId = $(el).attr('id');
      tabulatrTable = new Tabulatr(tableId);
      if($(el).data('persistent')){
        try {
          localStorage._tabulatr_test = 1;
          tabulatrTable.isAPersistedTable = true;
        } catch(e) {}
      }
      if($('.pagination[data-table='+ tableId +']').length === 0){
        tabulatrTable.hasInfiniteScrolling = true;
      }
      tabulatr_tables.push(tabulatrTable);
      for(var i = 0; i < tabulatr_tables.length; i++){
        if(tabulatr_tables[i].id === tableId){
          tableObj = tabulatr_tables[i];
        }
      }
      tableObj.updateTable({}, false);
    });
  }

  $(document).on('click', 'a[data-show-filters-for]', function(){
    var a = $(this);
    a.parents('.tabulatr-outer-wrapper').addClass('filtered');
  });

}

$(tabulatrInitialize);
$(document).on('page:load', tabulatrInitialize);

$(document).on('click', '.pagination a[data-page]', function(){
  var a = $(this);
  if(a.parent().hasClass('active') ||
     a.parent().hasClass('disabled')){
    return false;
  }
  var tableId = $(a).closest('.pagination').data('table');
  $('.tabulatr_mark_all[data-table='+ tableId +']').prop('checked', false);
  $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false);
  var table_obj;
  for(var i = 0; i < tabulatr_tables.length; i++){
    if(tabulatr_tables[i].id === tableId){
      table_obj = tabulatr_tables[i];
    }
  }
  table_obj.updateTable({append: false, page: a.data('page')});
  return false;
});


$(document).on('change', 'select[data-tabulatr-date-filter]', function() {
  var select = $(this);
  var option = select.find('option:selected');
  var val = option.val();
  if (val === 'from_to') {
    select.parents('.form-group').find(".from_to").show().removeClass('hidden');
  } else {
    select.parents('.form-group').find(".from_to").hide().val('');
  }
});
