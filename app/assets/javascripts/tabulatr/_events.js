function tabulatrInitialize() {
  $('th.tabulatr-sortable').click(function(){
    const th = $(this);
    const sort_by = th.data('tabulatr-column-name');
    let dir = th.attr('data-sorted');
    const table = th.parents('table');
    const table_id = table.attr('id');
    const table_instance = TabulatrInstances.instance.table(table_id);
    
    table.find('th.tabulatr-sortable.sorted').removeClass('sorted').removeAttr('data-sorted');
    dir = (dir === 'asc') ? 'desc' : 'asc';
    th.addClass('sorted').attr('data-sorted', dir);
    $('.tabulatr_filter_form[data-table='+ table_instance.id +'] input[name='+ table_instance.name +'_sort]').val(sort_by + ' '+  dir);
    if(!table_instance.moreResults){
      table_instance.moreResults = true;
      if(table_instance.hasInfiniteScrolling){
        $('.pagination_trigger[data-table='+ table_instance.id +']').bind('inview', cbfn);
      }
    }
    $($(this).parents('table').find('tbody tr')).remove();

    $('.tabulatr_mark_all[data-table='+ table_instance.name +']').prop('checked', false).prop('indeterminate', false);
    table_instance.updateTable({});
  });


  $('.tabulatr_table').each(function(ix, el){
    if($('.pagination[data-table="'+ $(el).attr('id') +'"]').length === 0){
      $('.pagination_trigger[data-table="'+ $(el).attr('id') +'"]').bind('inview', cbfn);
    }
  });

  $('.batch-action-inputs').click(function(){
    const a = $(this);
    const name = a.data('do-batch-action-name');
    const key = a.data('do-batch-action');
    const table_id = a.data('table-id');
    const table_instance = TabulatrInstances.instance.table(table_id);
    const params = {page: 1};
    const use_ajax = !a.data('download');
    params[name] = key;
    params.tabulatr_checked = {checked_ids: jQuery.map($('#'+ tableId +' .tabulatr-checkbox:checked'), function(el){return $(el).val();}).join(',')};
    let confirmation = true;
    if(params.tabulatr_checked.checked_ids === '') {
      confirmation = window.confirm(a.parents('ul').data('confirm-text'));
    }
    if(confirmation) {
      $('.tabulatr_mark_all[data-table='+ table_instance.id +']').prop('indeterminate', false).prop('checked', false);
      $('#'+ table_instance.id +' .tabulatr-wrench').addClass('disabled');
      if (use_ajax)
        table_instance.updateTable(params, true);
      else
        table_instance.sendRequestWithoutAjax(params, a.data('extension'));
    }
  });

  $('form.tabulatr-fuzzy-search').submit(function(){
    const table_id = $(this).data('table');
    const table_instance = TabulatrInstances.instance.table(table_id);
    if(table_instance.hasInfiniteScrolling) {
      $('.pagination_trigger[data-table='+ table_instance.id +']').unbind('inview', cbfn);
      $('.pagination_trigger[data-table='+ table_instance.id +']').bind('inview', cbfn);
    }
    table_instance.updateTable({page: 1, append: false}, true);
    return false;
  });

  $('form.tabulatr_filter_form input, form.tabulatr_filter_form select').change(function(){
    $(this).parents('form.tabulatr_filter_form').submit();
  });

  $('form.tabulatr_filter_form').submit(function(){
    const table_id = $(this).data('table');
    const table_instance = TabulatrInstances.instance.table(table_id);
    table_instance.submitFilterForm();
    return false;
  });

  $('.tabulatr_mark_all').click(function(){
    const table_id = $(this).parents('table').prop('id');
    const table_instance = TabulatrInstances.instance.table(table_id);
    if($(this).is(':checked')){
      $('#'+ table_instance.id +' tr[data-page]:visible input[type=checkbox]').prop('checked', true);
      $('#'+ table_instance.id +' .tabulatr-wrench').removeClass('disabled');
    }else{
      $('#'+ table_instance.id +' tr[data-page]:visible input[type=checkbox]').prop('checked', false);
      if(table_instance.checkIfCheckboxesAreMarked()){
        $('#'+ table_instance.id +' .tabulatr-wrench').removeClass('disabled');
      }else{
        $('#'+ table_instance.id +' .tabulatr-wrench').addClass('disabled');
      }
    }
  });

  $('.tabulatr_table').on('click', 'input.tabulatr-checkbox', function(){
    const $table = $(this).closest('.tabulatr_table');
    const table_id = $table.attr('id');
    const table_instance = TabulatrInstances.instance.table(table_id);
    const $markAllCheckbox = $table.find('.tabulatr_mark_all');
    if($(this).is(':checked')){
      if($('#'+ table_instance.id +' tr[data-page]:visible input[type=checkbox]').not(':checked').length > 0){
        $markAllCheckbox.prop("indeterminate", true);
      }else{
        $markAllCheckbox.prop('indeterminate', false);
        $markAllCheckbox.prop('checked', true);
      }
      $('#'+ table_instance.id +' .tabulatr-wrench').removeClass('disabled');
    }else{
      if($('#'+ table_instance.id +' tr[data-page]:visible input[type=checkbox]:checked').length > 0){
        $markAllCheckbox.prop('indeterminate', true);
        $('#'+ table_instance.id +' .tabulatr-wrench').removeClass('disabled');
      }else{
        $markAllCheckbox.prop('indeterminate', false);
        $markAllCheckbox.prop('checked', false);
        if(table_instance.checkIfCheckboxesAreMarked()){
          $('#'+ table_instance.id +' .tabulatr-wrench').removeClass('disabled');
        }else{
          $('#'+ table_instance.Id +' .tabulatr-wrench').addClass('disabled');
        }
      }
    }
  });

  $('.tabulatr-per-page a').click(function(){
    if($(this).hasClass('active')) { return false; }
    $(this).closest('div').find('a').removeClass('active');
    $(this).addClass('active');
    const table_id = $(this).closest('div').data('table');
    const table_instance = TabulatrInstances.instance.table(table_id);
    table_instance.moreResults = true;
    if(table_instance.hasInfiniteScrolling){
      $('.pagination_trigger[data-table='+ table_instance.id +']').bind('inview', cbfn);
    }
    if(typeof(Storage) !== undefined){
      try {
        localStorage.tabulatr_page_display_count = $(this).data('items-per-page');
      } catch(e) {}
    }
    table_instance.updateTable({page: 1}, true);
  });

  $(document).on('click', 'a[data-tabulatr-reset]',function(){
    const a = $(this);
    const table_id = a.data('tabulatrReset');
    const table_instance = TabulatrInstances.instance.table(table_id);
    a.parents('.tabulatr-outer-wrapper').removeClass('filtered');
    TabulatrStorage.resetTable(table_instance);
  });

  if($('.tabulatr_table:not(".tabulatr_static_table")').length > 0){
    if(typeof(Storage) !== undefined) {
      try {
        const count = localStorage.tabulatr_page_display_count;
        if(count !== undefined) {
          $('.tabulatr-per-page a').removeClass('active');
          $('.tabulatr-per-page a[data-items-per-page='+ count +']').
            addClass('active');
        }
      } catch(e) {}
    }
    var tableObj, tableId, tabulatrTable;
    $('.tabulatr_table:not(".tabulatr_static_table")').each(function(ix, el) {
      table_id = $(el).attr('id');
      table_instance = TabulatrInstances.instance.table(table_id);
      if($(el).data('persistent')) {
        try {
          localStorage._tabulatr_test = 1;
          table_instance.isAPersistedTable = true;
        } catch(e) {}
      }
      if($('.pagination[data-table='+ tableId +']').length === 0) {
        table_instance.hasInfiniteScrolling = true;
      }
      table_instance.updateTable({}, false);
    });
  }

  $(document).on('click', 'a[data-show-filters-for]', function() {
    $(this).parents('.tabulatr-outer-wrapper').addClass('filtered');
  });
}

$(tabulatrInitialize);
$(document).on('page:load', tabulatrInitialize);
$(document).on('turbolinks:load', tabulatrInitialize);

$(document).on('click', '.pagination a[data-page]', function() {
  const a = $(this);
  if(a.parent().hasClass('active') ||
     a.parent().hasClass('disabled')) {
    return false;
  }
  const tableId = $(a).closest('.pagination').data('table');
  $('.tabulatr_mark_all[data-table='+ tableId +']').prop('checked', false);
  $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false);
  const tabulatr_instance = TabulatrInstances.instance.table(tableId);
  table_instance.updateTable({append: false, page: a.data('page')});
  return false;
});


$(document).on('change', 'select[data-tabulatr-date-filter]', function() {
  const select = $(this);
  const val = select.find('option:selected').val();
  if (val === 'from_to') {
    select.parents('.tabulatr-filter-row').find(".from_to").show().removeClass('hidden');
  } else {
    select.parents('.tabulatr-filter-row').find(".from_to").hide().val('');
  }
});
