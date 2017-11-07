function Tabulatr(id){
  this.id = id;
  this.name = '';
  this.moreResults = true;
  this.currentData = null;
  this.locked = false;
  this.isAPersistedTable = false;
  this.initialRequest = true;
  this.hasInfiniteScrolling = false;
}

var tabulatr_tables;

var cbfn = function(event, isInView, visiblePartX, visiblePartY) {
  if (isInView && visiblePartY !== 'top' && visiblePartY !== 'bottom') {
    var tableId = $(event.currentTarget).data('table');
    var table_obj;
    for(var i = 0; i < tabulatr_tables.length; i++){
      if(tabulatr_tables[i].id === tableId){
        table_obj = tabulatr_tables[i];
      }
    }
    table_obj.updateTable({append: true});
  }
};

Tabulatr.prototype = {
  constructor: Tabulatr,

  updateTable: function(hash, forceReload) {
    var $table = $('#'+ this.id);
    this.storePage = this.pageShouldBeStored(hash.page, forceReload);
    if((this.storePage && this.retrievePage($table, hash)) || this.locked){ return; }
    this.locked = true;
    this.showLoadingSpinner();
    this.loadDataFromServer(hash);
  },

  sendRequestWithoutAjax: function(hash) {
    var data = this.getDataForAjax(hash);
    var url;
    if ($('table#'+ this.id).data('path') == '#')
      url = $(location).attr("pathname") + ".pdf?" + $.param(data)
    else
      url = $('table#'+ this.id).data('path') + ".pdf?" + $.param(data);
    window.open(url);
  },

  pageShouldBeStored: function(page, forceReload){
    return page !== undefined && !forceReload;
  },

  retrievePage: function(table, hash){
    table.find('tbody tr').hide();
    if(table.find('tbody tr[data-page='+ hash.page +']').length > 0){
      table.find('tbody tr[data-page='+ hash.page +']').show();

      var tabulatrPagination = new TabulatrPagination(
        $('.pagination[data-table='+ this.id +'] a:last').data('page'), this.id);
      tabulatrPagination.updatePagination(hash.page);
      if(this.isAPersistedTable){
        var data = this.createParameterString(hash, this.id);
        try {
          localStorage[this.id] = JSON.stringify(data);
        } catch(e) {}
      }
      return true;
    }
    return false;
  },

  getDataForAjax: function(hash){
    var data;
    if(this.initialRequest && this.isAPersistedTable && localStorage[this.id]){
      data = JSON.parse(localStorage[this.id]);
    }else{
      data = this.createParameterString(hash, this.id);
      if(this.isAPersistedTable) {
        try {
          var storableData = jQuery.extend(true, {}, data);
          var batch_key = this.id.split('_')[0] + '_batch';
          if (batch_key in storableData)
            delete storableData[batch_key];
          localStorage[this.id] = JSON.stringify(storableData);
        } catch(e) {}
      }
    }
    return data;
  },

  loadDataFromServer: function(hash){
    var data = this.getDataForAjax(hash)
    // deparse existing params http://stackoverflow.com/a/8649003/673826
    var search = location.search.substring(1);
    if (search.length){
      var query = JSON.parse('{"' + decodeURI(search).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
      data = $.extend(query, data);
    }
    $.ajax({
      context: this,
      type: 'GET',
      url: $('table#'+ this.id).data('path'),
      accepts: {
        json: 'application/json'
      },
      data: data,
      success: this.handleResponse,
      complete: this.hideLoadingSpinner,
      error: this.handleError
    });
  },

  checkIfCheckboxesAreMarked: function(){
    return $('tr[data-page] input[type=checkbox]:checked').length > 0;
  },

  currentCount: function(){
    return $('#'+ this.id +' tbody tr.tabulatr-row').length;
  },

  handleResponse: function(response) {
    if (typeof response === "string")
      response = JSON.parse(response);

    this.insertTabulatrData(response);
    var tabulatrPagination = new TabulatrPagination(
      response.meta.pages, response.meta.table_id);
    tabulatrPagination.updatePagination(response.meta.page);
    if($('.pagination[data-table='+ response.meta.table_id +']').length > 0){
      if(response.meta.page > response.meta.pages){
        this.updateTable({page: response.meta.pages});
      }
    }
  },

  handleError: function(){
    if(this.isAPersistedTable && this.initialRequest){
      this.initialRequest = false;
      this.locked = false;
      this.resetTable();
    }
  },

  insertTabulatrData: function(response){
    if (typeof response === "string")
      response = JSON.parse(response);

    var tableId = response.meta.table_id;
    var table = $('#'+ tableId);
    var tbody = table.find('tbody');
    var ndpanel = $('#no-data-' + tableId);

    this.prepareTableForInsert(tableId, response.meta.append, response.data.length, response.meta.count);

    if (ndpanel.length > 0 && response.data.length == 0) {
      table.hide();
      ndpanel.show();
    } else {
      table.show();
      ndpanel.hide();
    }

    // insert the actual data
    for(var i = 0; i < response.data.length; i++){
      var data = response.data[i];
      var id = data.id;
      var tr = $('#'+ tableId +' tr.empty_row').clone();
      tr.removeClass('empty_row');
      if(data._row_config.data){
        tr.data(data._row_config.data);
        delete data._row_config.data;
      }
      tr.attr(data._row_config);
      tr.attr('data-page', response.meta.page);
      tr.attr('data-id', id);
      tr.find('td').each(function(index,element) {
        var td = $(element);
        var coltype = td.data('tabulatr-type');
        var name = td.data('tabulatr-column-name');
        var cont = data[name];
        if(coltype === 'checkbox') {
          cont = $("<input>").attr('type', 'checkbox').val(id).addClass('tabulatr-checkbox');
        }
        td.html(cont);
      });
      tbody.append(tr);
    }
    this.updateInfoString(tableId, response);

    if(this.isAPersistedTable){
      this.retrieveTableFromLocalStorage(response);
    }
  },


  replacer: function(match, attribute){
    return this.currentData[attribute];
  },


  makeAction: function(action, data){
    this.currentData = data;
    return decodeURI(action).replace(/{{([\w:]+)}}/g, this.replacer);
  },

  submitFilterForm: function(){
    if(this.hasInfiniteScrolling){
      $('.pagination_trigger[data-table='+ this.id +']').unbind('inview', cbfn);
      $('.pagination_trigger[data-table='+ this.id +']').bind('inview', cbfn);
    }
    this.updateTable({page: 1, append: false}, true);
    return false;
  },

  createParameterString: function(hash){
    var tableName = this.id.split('_')[0];
    if(hash === undefined){
      hash = {append: false};
    }
    hash = this.getPageParams(hash);
    hash.arguments = $.map($('#'+ this.id +' th'), function(n){
      return $(n).data('tabulatr-column-name');
    }).filter(function(n){return n; }).join();
    hash.table_id = this.id;
    hash[tableName + '_search'] = $('input#'+ this.id +'_fuzzy_search_query').val();
    return this.readParamsFromForm(hash);
  },

  localDate: function(value){
    return new Date(value).toLocaleString();
  },

  showLoadingSpinner: function(){
    $('.tabulatr-spinner-box[data-table="'+ this.id +'"]').show();
  },

  hideLoadingSpinner: function(){
    this.initialRequest = false;
    this.locked = false;
    $('.tabulatr-spinner-box[data-table="'+ this.id +'"]').hide();
  },

  updateInfoString: function(tableId, response){
    var count_string = $('.tabulatr_count[data-table='+ tableId +']').data('format-string');
    count_string = count_string.replace(/%\{current\}/, response.meta.count);
    count_string = count_string.replace(/%\{total\}/, response.meta.total);
    count_string = count_string.replace(/%\{per_page\}/,
      response.meta.pagesize);
    $('.tabulatr_count[data-table='+ tableId +']').html(count_string);
  },

  readParamsFromForm: function(hash){
    var form_array = $('.tabulatr_filter_form[data-table="'+ this.id +'"]')
      .find('input:visible,select:visible,input[type=hidden]').serializeArray();
    for(var i = 0; i < form_array.length; i++){
      if(hash[form_array[i].name] !== undefined){
        if(!Array.isArray(hash[form_array[i].name])){
          hash[form_array[i].name] = [hash[form_array[i].name]];
        }
        hash[form_array[i].name].push(form_array[i].value);
      }else{
        hash[form_array[i].name] = form_array[i].value;
      }
    }
    return hash;
  },

  getPageParams: function(hash){
    var pagesize = hash.pagesize;
    if(pagesize === undefined){
      pagesize = $('table#'+ this.id).data('pagesize');
    }
    if(hash.page === undefined){
      if(this.hasInfiniteScrolling){
        hash.page = Math.floor($('#'+ this.id +' tbody tr[class!=empty_row]').length/pagesize) + 1;
      }
      if(!isFinite(hash.page)){
        hash.page = 1;
      }
    }
    hash.pagesize = pagesize;
    return hash;
  },

  prepareTableForInsert: function(tableId, append, dataCount, actualCount){
    if(!append){
      if(this.storePage){
        $('#'+ tableId +' tbody tr').hide();
      }else{
        $('#'+ tableId +' tbody').html('');
      }
    }
    if(dataCount === 0 || this.currentCount() + dataCount >= actualCount){
      this.moreResults = false;
      $('.pagination_trigger[data-table='+ tableId +']').unbind('inview');
    }
  }

};
