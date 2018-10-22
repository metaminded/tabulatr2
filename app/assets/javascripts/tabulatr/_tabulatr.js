var cbfn = function(event, isInView, visiblePartX, visiblePartY) {
  if (isInView && visiblePartY !== 'top' && visiblePartY !== 'bottom') {
    const tableId = $(event.currentTarget).data('table');
    TabulatrInstances.instance.table(tableId).updateTable({append: true});
  }
};

class TabulatrTable {
  constructor(id) {
    this.id = id;
    this.name = id.split('_')[0];
    this.moreResults = true;
    this.currentData = null;
    this.locked = false;
    this.isAPersistedTable = false;
    this.initialRequest = true;
    this.hasInfiniteScrolling = false;
    this.dom_table_cache = null;
  }

  getDOMTable() {
    if (!this.dom_table_cache)
      this.dom_table_cache = $('table#' + this.id);
    return this.dom_table_cache;
  }

  updateTable(hash, forceReload) {
    this.storePage = this.pageShouldBeStored(hash.page, forceReload);
    if((this.storePage && this.retrievePage(hash)) || this.locked) { return; }
    this.locked = true;
    this.showLoadingSpinner();
    this.loadDataFromServer(hash);
  }

  sendRequestWithoutAjax(hash, extension) {
    const data = this.getDataForAjax(hash);
    if (!extension || extension.length == 0)
      extension = 'txt';
    const url = (() => {
      if (this.getDOMTable().data('path') == '#')
	return $(location).attr("pathname");
      else
	return this.getDOMTable().data('path');
    }).replace(/\/+$/, "") + '.' + extension + '?' + $.param(data);
    window.open(url);
  }

  pageShouldBeStored(page, forceReload) {
    return page !== undefined && !forceReload;
  }

  retrievePage(hash) {
    const table = this.getDOMTable();
    table.find('tbody tr').hide();
    if(table.find('tbody tr[data-page='+ hash.page +']').length > 0){
      table.find('tbody tr[data-page='+ hash.page +']').show();

      const tabulatrPagination = new TabulatrPagination(
        $('.pagination[data-table='+ this.id +'] a:last').data('page'), this);
      tabulatrPagination.updatePagination(hash.page);
      if(this.isAPersistedTable){
        const data = this.createParameterString(hash, this.id);
        try {
          localStorage[this.id] = JSON.stringify(data);
        } catch(e) {}
      }
      return true;
    }
    return false;
  }

  getDataForAjax(hash) {
    let data;
    if(this.initialRequest && this.isAPersistedTable && localStorage[this.id]) {
      data = JSON.parse(localStorage[this.id]);
    } else {
      data = this.createParameterString(hash, this.id);
      if(this.isAPersistedTable) {
        try {
          const storableData = jQuery.extend(true, {}, data);
          const batch_key = this.name + '_batch';
          if (batch_key in storableData)
            delete storableData[batch_key];
          localStorage[this.id] = JSON.stringify(storableData);
        } catch(e) {}
      }
    }
    return data;
  }

  loadDataFromServer(hash) {
    let data = this.getDataForAjax(hash)
    // deparse existing params http://stackoverflow.com/a/8649003/673826
    const search = location.search.substring(1);
    if (search.length){
      const query = JSON.parse('{"' + decodeURI(search).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}');
      data = $.extend(query, data);
    }
    $.ajax({
      context: this,
      type: 'GET',
      url: this.getDOMTable().data('path'),
      accepts: {
        json: 'application/json'
      },
      data: data,
      success: this.handleResponse,
      complete: this.hideLoadingSpinner,
      error: this.handleError
    });
  }

  checkIfCheckboxesAreMarked() {
    return $('tr[data-page] input[type=checkbox]:checked').length > 0;
  }

  currentCount() {
    return this.getDOMTable().find('tbody tr.tabulatr-row').length;
  }

  handleResponse(response) {
    if (typeof response === "string")
      response = JSON.parse(response);

    this.insertTabulatrData(response);
    const tabulatrPagination = new TabulatrPagination(
      response.meta.pages, TabulatrInstances.instance.table(response.meta.table_id));
    tabulatrPagination.updatePagination(response.meta.page);
    if($('.pagination[data-table='+ response.meta.table_id +']').length > 0){
      if(response.meta.page > response.meta.pages){
        this.updateTable({page: response.meta.pages});
      }
    }
  }

  handleError() {
    if(this.isAPersistedTable && this.initialRequest){
      this.initialRequest = false;
      this.locked = false;
      TabulatrStorage.resetTable(this);
    }
  }

  insertTabulatrData(response) {
    if (typeof response === "string")
      response = JSON.parse(response);

    const table = this.getDOMTable();
    const tbody = table.find('tbody');
    const ndpanel = $('#no-data-' + this.id);

    this.prepareTableForInsert(response.meta.append, response.data.length, response.meta.count);

    if (ndpanel.length > 0 && response.data.length == 0) {
      table.hide();
      ndpanel.show();
    } else {
      table.show();
      ndpanel.hide();
    }

    // insert the actual data
    for(let i = 0; i < response.data.length; i++){
      const data = response.data[i];
      const id = data.id;
      const tr = this.getDOMTable().find('tr.empty_row').clone();
      tr.removeClass('empty_row');
      if(data._row_config.data){
        tr.data(data._row_config.data);
        delete data._row_config.data;
      }
      tr.attr(data._row_config);
      tr.attr('data-page', response.meta.page);
      tr.attr('data-id', id);
      tr.find('td').each(function(index,element) {
        const td = $(element);
        const coltype = td.data('tabulatr-type');
        const name = td.data('tabulatr-column-name');
        const cont = data[name];
        if(coltype === 'checkbox') {
          cont = $("<input>").attr('type', 'checkbox').val(id).addClass('tabulatr-checkbox');
        }
        td.html(cont);
      });
      tbody.append(tr);
    }
    this.updateInfoString(response);

    if(this.isAPersistedTable){
      TabulatrStorage.retrieveTableFromLocalStorage(this, response);
    }
  }

  replacer(match, attribute) {
    return this.currentData[attribute];
  }

  makeAction(action, data) {
    this.currentData = data;
    return decodeURI(action).replace(/{{([\w:]+)}}/g, this.replacer);
  }

  submitFilterForm() {
    if(this.hasInfiniteScrolling) {
      $('.pagination_trigger[data-table='+ this.id +']').unbind('inview', cbfn);
      $('.pagination_trigger[data-table='+ this.id +']').bind('inview', cbfn);
    }
    this.updateTable({page: 1, append: false}, true);
    return false;
  }

  createParameterString(hash) {
    hash = hash || {append: false};
    hash = this.getPageParams(hash);
    hash.arguments = $.map($('#'+ this.id +' th'), function(n){
      return $(n).data('tabulatr-column-name');
    }).filter(function(n){return n; }).join();
    hash.table_id = this.id;
    hash[this.name + '_search'] = $('input#'+ this.id +'_fuzzy_search_query').val();
    return this.readParamsFromForm(hash);
  }

  localDate(value) {
    return new Date(value).toLocaleString();
  }

  showLoadingSpinner() {
    $('.tabulatr-spinner-box[data-table="'+ this.id +'"]').show();
  }

  hideLoadingSpinner() {
    this.initialRequest = false;
    this.locked = false;
    $('.tabulatr-spinner-box[data-table="'+ this.id +'"]').hide();
  }

  updateInfoString(response) {
    let count_string = $('.tabulatr_count[data-table='+ this.id +']').data('format-string');
    count_string = count_string.replace(/%\{current\}/, response.meta.count);
    count_string = count_string.replace(/%\{total\}/, response.meta.total);
    count_string = count_string.replace(/%\{per_page\}/,
      response.meta.pagesize);
    $('.tabulatr_count[data-table='+ this.id +']').html(count_string);
  }

  readParamsFromForm(hash) {
    const form_array = $('.tabulatr_filter_form[data-table="'+ this.id +'"]')
      .find('input:visible,select:visible,input[type=hidden]').serializeArray();
    for(let i = 0; i < form_array.length; i++) {
      if(hash[form_array[i].name] !== undefined) {
        if(!Array.isArray(hash[form_array[i].name])){
          hash[form_array[i].name] = [hash[form_array[i].name]];
        }
        hash[form_array[i].name].push(form_array[i].value);
      } else {
        hash[form_array[i].name] = form_array[i].value;
      }
    }
    return hash;
  }

  getPageParams(hash) {
    let pagesize = hash.pagesize || this.getDOMTable().data('pagesize');
    if(hash.page === undefined) {
      if(this.hasInfiniteScrolling) {
        hash.page = Math.floor(this.getDOMTable().find('tbody tr[class!=empty_row]').length/pagesize) + 1;
      }
      if(!isFinite(hash.page)) {
        hash.page = 1;
      }
    }
    hash.pagesize = pagesize;
    return hash;
  }

  prepareTableForInsert(append, dataCount, actualCount) {
    if(!append) {
      if(this.storePage) {
        this.getDOMTable().find('tbody tr').hide();
      } else {
        this.getDOMTable().find('tbody').html('');
      }
    }
    if(dataCount === 0 || this.currentCount() + dataCount >= actualCount) {
      this.moreResults = false;
      $('.pagination_trigger[data-table='+ this.id +']').unbind('inview');
    }
  }
}
