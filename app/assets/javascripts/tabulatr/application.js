$(document).on('ready page:load', function(){
  Tabulatr = {
    moreResults: true,
    storePage: false,
    foo: function(v, td, tr){
      td.html(v.toUpperCase());
    },

    updatePagination: function(currentPage, numPages){
      var ul = $('div.pagination ul');
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

    updateTable: function(hash) {
      if(hash.page !== undefined){
        //old page should be stored
        Tabulatr.storePage = true;
        // check if this page was already loaded
        if($('.tabulatr_table tbody tr[data-page='+ hash.page +']').length > 0){
          $('.tabulatr_table tbody tr').hide();
          $('.tabulatr_table tbody tr[data-page='+ hash.page +']').show();

          Tabulatr.updatePagination(hash.page, $('div.pagination a:last').data('page'));
          return;
        }
      }else{
        Tabulatr.storePage = false;
      }
      jQuery.get(window.location + '.json',
          Tabulatr.createParameterString(hash),
          Tabulatr.handleResponse
        );
    },

    checkIfCheckboxesAreMarked: function(){
      return $('tr[data-page] input[type=checkbox]:checked').length > 0;
    },

    handleResponse: function(response) {
      Tabulatr.insertTabulatrData(response);
      Tabulatr.updatePagination(response.meta.page, response.meta.pages);
    },

    insertTabulatrData: function(response){
      columns = [];
      if(!response.meta.append){
        if(Tabulatr.storePage){
          $('.tabulatr_table tbody tr').hide();
        }else{
          $('.tabulatr_table tbody').html('');
        }
      }
      if(response.data.length == 0){
        Tabulatr.moreResults = false;
        $('#new_article_link').unbind('inview');
      }else{
        if(response.data.length < 10){
          Tabulatr.moreResults = false;
          $('#new_article_link').unbind('inview');
        }else{
          Tabulatr.moreResults = true;
        }
        $('.tabulatr_table th').each(function(ix,el){
          var column_name = $(el).data('tabulatr-column-name');
          var association = $(el).data('tabulatr-association');
          var column_type = $(el).data('tabulatr-column-type');
          var callback_method = $(el).data('tabulatr-format-method');
          columns.push({ name: column_name,
                         method: callback_method,
                         type: column_type,
                         association: association });
        });
        $('.empty_row').remove();


        for(var i = 0; i < response.data.length; i++){
          $tr = $('<tr data-page="'+ response.meta.page +'"></tr>');
          var td = '';
          for(var c = 0; c < columns.length; c++){
            var column = columns[c];
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
            var fn = Tabulatr[column.method];
            $td = $('<td></td>');
            if(column.type == 'checkbox'){
              $td.html(Tabulatr.makeCheckboxFor(response.data[i]));
            }else if(column.type == 'action'){
              $td.html(Tabulatr.makeActionFor(response.data[i]));
            }else{
              if(value === false){
                value = "false"; // because false won't be displayed
              }
              $td.html(value);
              if(typeof fn === 'function'){
                try{
                  fn(value, $td, $tr);
                }catch(e){
                  $td.html('<span class="error">#ERROR</span>');
                }
              }
            }
            td += $td[0].outerHTML;
          }
          $tr.append(td);
          $('.tabulatr_table tbody').append($tr);
        }
      }
      var tab_count = "Showing "+ response.meta.count +", total: "+ response.meta.total;
      $('#tabulatr_count').html(tab_count);

    },

    makeCheckboxFor: function(data){
      return "<input type='checkbox' value='"+ data.id +
      "' class='tabulatr-checkbox' />";
    },

    makeActionFor: function(data){

    },

    createParameterString: function(hash){
      if(hash === undefined){
        hash = {};
        hash.append = false;
      }
      if($('img.sorted').length == 1){
        hash.sort_by = $('img.sorted').closest('th').data('tabulatr-column-name');
        if($('img.sorted').data('sort') == 'asc'){
          hash.orientation = 'desc';
        }else{
          hash.orientation = 'asc';
        }
      }
      if(hash.page === undefined){
        hash.page = Math.floor($('tbody tr').length/10) + 1;
        // if(hash.page < 1){
        //   hash.page = 1;
        // }
      }
      hash.pagesize = 10;
      var form_array = $('#tabulatr_filter_form').serializeArray();
      for(var i = 0; i < form_array.length; i++){
        hash[form_array[i].name] = form_array[i].value;
      }
      return hash;
    }
  }

  $('.tabulatr-sort').click(function(){
    orientation = $(this).data('sort');
    $('.tabulatr-sort').removeClass('sorted');
    $(this).addClass('sorted');
    $('tbody tr').remove();
    $('#tabulatr_filter_form input[name=orientation]').val(orientation);
    $('#tabulatr_filter_form input[name=sort_by]').val($(this).closest('th').data('tabulatr-column-name'));
    if(orientation == 'asc'){
      $(this).removeClass('icon-arrow-down').addClass('icon-arrow-up');
      $(this).data('sort', 'desc');
    }else{
      $(this).addClass('icon-arrow-up').addClass('icon-arrow-down');
      $(this).data('sort', 'asc');
    }
    if(!Tabulatr.moreResults){
      Tabulatr.moreResults = true;
      // $('#new_article_link').bind('inview', cbfn);
    }

    $('#tabulatr_mark_all').prop('checked', false).prop('indeterminate', false);
    Tabulatr.updateTable({});
  });

  var cbfn = function(event, isInView, visiblePartX, visiblePartY) {
    if (isInView) {
      // element is now visible in the viewport
      if (visiblePartY == 'top') {
        // top part of element is visible
      } else if (visiblePartY == 'bottom') {
        // bottom part of element is visible
      } else {
        Tabulatr.updateTable({append: true});
      }
    } else {

    }
  };

  // $('#new_article_link').bind('inview', cbfn);

  $('.batch-action-inputs').click(function(){
    params = {};
    params[$(this).attr('name')] = $(this).val();
    params[$('.tabulatr_checked_ids').attr('name')] = jQuery.map($('.tabulatr-checkbox:checked'), function(el){return $(el).val();}).join(',');
    $('#tabulatr_mark_all').prop('indeterminate', false).prop('checked', false);
    Tabulatr.updateTable(params);
  });

  $('form#tabulatr_filter_form').submit(function(ev){
    Tabulatr.updateTable({});
    var ary = $(this).serializeArray();
    $('.tabulatr_table th').removeClass('tabulatr_filtered_column');
    $('i.icon-remove-sign').remove();
    for(var i = 0; i < ary.length; i++){
      if(ary[i].value != ""){
        var name = ary[i].name.replace(/(:|\.|\[|\])/g,'\\$1');
        // var attr = $(this).find("input[name="+ name +"]").data('tabulatr-attribute');
        var $col = $('th[data-tabulatr-form-name='+ name +']');
        if($col.length > 0){
          $col.addClass('tabulatr_filtered_column');
          // icon-remove-sign
          $col.append('<i class="icon-remove-sign '+
            'tabulatr_remove_filter" ></i>');
        }
      }
    }
    $('#tabulatr_filter_dialog').modal('hide');
    return false;
  });

  $('.tabulatr_table').on('click', 'i.tabulatr_remove_filter', function(){
    var $th = $(this).closest('th');
    var name = $th.data('tabulatr-form-name').replace(/(:|\.|\[|\])/g,'\\$1');
    $th.removeClass('tabulatr_filtered_column');
    if($('[name='+ name +']').is(':checkbox')){
      $('[name='+ name +']').prop('checked', false);
    }else{
      $('[name='+ name +']').val('');
    }
    $(this).remove();
    Tabulatr.updateTable({});
    return false;
  });

  $('#tabulatr_mark_all').click(function(){
    if($(this).is(':checked')){
      $('tr[data-page]:visible input[type=checkbox]').prop('checked', true);
      $('#tabulatr-wrench').show();
    }else{
      $('tr[data-page]:visible input[type=checkbox]').prop('checked', false);
      if(Tabulatr.checkIfCheckboxesAreMarked()){
        $('#tabulatr-wrench').show();
      }else{
        $('#tabulatr-wrench').hide();
      }
    }
  });

  $('.tabulatr_table').on('click', 'input.tabulatr-checkbox', function(){
    if($(this).is(':checked')){
      if($('tr[data-page]:visible input[type=checkbox]').not(':checked').length > 0){
        $('#tabulatr_mark_all').prop("indeterminate", true);
      }else{
        $('#tabulatr_mark_all').prop('indeterminate', false);
        $('#tabulatr_mark_all').prop('checked', true);
      }
      $('#tabulatr-wrench').show();
    }else{
      if($('tr[data-page]:visible input[type=checkbox]:checked').length > 0){
        $('#tabulatr_mark_all').prop('indeterminate', true);
        $('#tabulatr-wrench').show();
      }else{
        $('#tabulatr_mark_all').prop('indeterminate', false);
        $('#tabulatr_mark_all').prop('checked', false);
        if(Tabulatr.checkIfCheckboxesAreMarked()){
          $('#tabulatr-wrench').show();
        }else{
          $('#tabulatr-wrench').hide();
        }
      }
    }
  });

  if($('.tabulatr_table').length > 0){
    Tabulatr.updateTable({});
  }
});

$(document).on('click', '.pagination a', function(){
  console.log($(this));
  console.log('update pagination');
  var a = $(this);
  if(a.parent().hasClass('active') ||
     a.parent().hasClass('disabled')){
    return;
  }
  $('#tabulatr_mark_all').prop('checked', false);
  $('#tabulatr_mark_all').prop('indeterminate', false);
  Tabulatr.updateTable({append: false, page: a.data('page')});
  return false;
});
