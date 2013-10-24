//  Copyright (c) 2010-2014 Peter Horn & Florian Thomas, Provideal GmbH
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
    var columns = [];
    var tableId = response.meta.table_id;
    var tableName = tableId.split('_')[0];
    var tbody = $('#'+ tableId +' tbody');
    if(!response.meta.append){
      if(Tabulatr.storePage){
        $('#'+ tableId +' tbody tr').hide();
      }else{
        $('#'+ tableId +' tbody').html('');
      }
    }
    if(response.data.length == 0){
      Tabulatr.moreResults = false;
      $('.pagination_trigger[data-table='+ tableId +']').unbind('inview');
    }else{
      if(response.data.length < response.meta.pagesize){
        Tabulatr.moreResults = false;
        $('.pagination_trigger[data-table='+ tableId + ']').unbind('inview');
      }else{
        Tabulatr.moreResults = true;
      }

      // insert the actual data
      for(var i = 0; i < response.data.length; i++){
        var data = response.data[i];
        var id = data.id;
        var tr = $('tr.empty_row').clone();
        tr.removeClass('empty_row');
        tr.attr('data-page', response.meta.page);
        tr.attr('data-id', id);
        tr.find('td').each(function(i,td_raw) {
          var td = $(td_raw);
          var coltype = td.data('tabulatr-type');
          var name = td.data('tabulatr-column-name');
          var cont = data[name]
          if(coltype === 'checkbox') {
            cont = $("<input>").attr('type', 'checkbox').val(id).addClass('tabulatr-checkbox');
          }
          td.html(cont);

        });
        tbody.append(tr);
      }
    }
    var count_string = $('.tabulatr_count[data-table='+ tableId +']').data('format-string');
    count_string = count_string.replace(/%\{current\}/, response.meta.count);
    count_string = count_string.replace(/%\{total\}/, response.meta.total);
    count_string = count_string.replace(/%\{per_page\}/,
      response.meta.pagesize);
    $('.tabulatr_count[data-table='+ tableId +']').html(count_string);
  },

  replacer: function(match, attribute, offset, string){
    return Tabulatr.currentData[attribute];
  },


  makeAction: function(action, data){
    Tabulatr.currentData = data;
    return unescape(action).replace(/{{([\w:]+)}}/g, Tabulatr.replacer);
  },

  createParameterString: function(hash, tableId){
    var tableName = tableId.split('_')[0];
    if(hash === undefined){
      hash = {};
      hash.append = false;
    }
    if($('#'+ tableId +' i.sorted').length == 1){
      hash[tableName + '_sort'] = $('#'+ tableId +' i.sorted').closest('th').data('tabulatr-sorting-name');
      if($('#'+ tableId +' i.sorted').data('sort') == 'asc'){
        hash[tableName + '_sort'] += ' desc';
      }else{
        hash[tableName + '_sort'] += ' asc';
      }
    }
    if(hash.pagesize === undefined){
      var pagesize = $('table#'+ tableId).data('pagesize');
      if(pagesize == null) {
        console.log('Tabulatr: No pagesize specified')
      }
    }
    if(hash.page === undefined){
      hash.page = Math.floor($('#'+ tableId +' tbody tr[class!=empty_row]').length/pagesize) + 1;
      if(!isFinite(hash.page)){
        hash.page = 1;
      }
    }
    hash.pagesize = pagesize;
    hash.arguments = $.map($('#'+ tableId +' th'), function(n){
      return $(n).data('tabulatr-column-name')
    }).filter(function(n){return n}).join();
    hash.table_id = tableId;
    hash[tableName + '_search'] = $('input#'+ tableName +'_fuzzy_search_query').val();
    var form_array = $('.tabulatr_filter_form[data-table="'+ tableId +'"]')
      .find('input:visible,select:visible').serializeArray();
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
    direction = {
      desc: {
        opposite: 'asc', ownClasses: 'glyphicon-arrow-down icon-arrow-down', oppositeClasses: 'glyphicon-arrow-up icon-arrow-up'
      },
      asc: {
        opposite: 'desc', ownClasses: 'glyphicon-arrow-up icon-arrow-up', oppositeClasses: 'glyphicon-arrow-down icon-arrow-down'
      }
    };
    var tableId = $(this).parents('table').attr('id');
    var tableName = tableId.split('_')[0];
    var sort_by = $(this).closest('th').data('tabulatr-sorting-name');
    var isSorted = $(this).hasClass('sorted');
    var $sortedColumn = $('.tabulatr-sort.sorted:first');
    $($(this).parents('tr').find('.tabulatr-sort')).removeClass('sorted');
    $(this).addClass('sorted');
    if(isSorted){
      $(this).removeClass(direction[orientation].oppositeClasses).addClass(direction[orientation].ownClasses);
    }else{
      if($sortedColumn.length > 0){
        $sortedColumn.data('sort', 'asc');
        $sortedColumn.removeClass(direction['asc'].oppositeClasses).addClass(direction['asc'].ownClasses);
      }
    }
    $(this).data('sort', direction[orientation].opposite);
    $('.tabulatr_filter_form[data-table='+ tableId +'] input[name='+ tableName+'_sort]').val(sort_by + ' '+  orientation);
    $($(this).parents('table').find('tbody tr')).remove();

    $('.tabulatr_filter_form[data-table='+ tableId +'] input[name=orientation]').val(orientation);
    if(!Tabulatr.moreResults){
      Tabulatr.moreResults = true;
      if($('.pagination[data-table='+ tableId +']').length == 0){
        $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
      }
    }

    $('.tabulatr_mark_all[data-table='+ tableName +']').prop('checked', false).prop('indeterminate', false);
    Tabulatr.updateTable({}, tableId);
    $(this).data('sort', direction[orientation].opposite);
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
      $('.pagination_trigger[data-table='+ $(el).attr('id') +']').bind('inview', cbfn);
    }
  });

  $('.batch-action-inputs').click(function(){
    var a = $(this);
    var name = a.data('do-batch-action-name');
    var key = a.data('do-batch-action');
    var tableId = a.data('table-id');
    var params = {page: 1};
    params[name] = key;
    params['tabulatr_checked'] = {checked_ids: jQuery.map($('#'+ tableId +' .tabulatr-checkbox:checked'), function(el){return $(el).val();}).join(',')};
    $('.tabulatr_mark_all[data-table='+ tableId +']').prop('indeterminate', false).prop('checked', false);
    $('#'+ tableId +' .tabulatr-wrench').addClass('disabled');
    Tabulatr.updateTable(params, tableId, true);
  });

  $('form.tabulatr-fuzzy-search').submit(function(){
    var tableId = $(this).data('table');
    if($('.pagination[data-table='+ tableId +']').length == 0){
      $('.pagination_trigger[data-table='+ tableId +']').unbind('inview', cbfn);
      $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
    }
    Tabulatr.updateTable({page: 1, append: false}, tableId, true);
    return false;
  });

  $('form.tabulatr_filter_form').submit(function(ev){
    var tableId = $(this).data('table');
    if($('.pagination[data-table='+ tableId +']').length == 0){
      $('.pagination_trigger[data-table='+ tableId +']').unbind('inview', cbfn);
      $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
    }
    Tabulatr.updateTable({page: 1, append: false}, tableId, true);
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
    if($('.pagination[data-table='+ tableId +']').length == 0){
      $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
    }
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
      $('.pagination_trigger[data-table='+ tableId +']').bind('inview', cbfn);
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


// TODO: We absolutely need to clean that up!

$(document).on('click', 'a[data-show-table-filter]', function(){
  var a = $(this);
  var nam = a.data('show-table-filter');
  $('div[data-filter-column-name="'+nam+'"]').show('blind');
  $('div[data-filter-column-name="_submit"]').show('blind');

  a.hide();
  return false;
})

$(document).on('click', 'a[data-hide-table-filter]', function(){
  var a = $(this);
  var nam = a.data('hide-table-filter');
  var t = $('div[data-filter-column-name="'+nam+'"]');
  t.hide('blind');
  t.find('input[type=text]').val("");
  $('a[data-show-table-filter="'+nam+'"]').show();
  if ($('div[data-filter-column-name]:visible').length <= 2)
    $('div[data-filter-column-name="_submit"]').hide('blind');
  return false;
})

$(document).on('change', 'select[data-tabulatr-date-filter]', function() {
  var select = $(this);
  var option = select.find('option:selected');
  var val = option.val();
  console.log(val);
  if (val === 'from_to') {
    select.parents('.controls').find(".from_to").show().removeClass('hidden');
  } else {
    select.parents('.controls').find(".from_to").hide().val('');
  }
});
