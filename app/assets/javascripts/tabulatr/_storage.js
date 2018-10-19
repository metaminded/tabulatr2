class TabulatrStorage {
  static retrieveTableFromLocalStorage(table, response) {
    try {
      const currentStorage = JSON.parse(localStorage[table.id]);
      if(currentStorage !== undefined) {
        $('.pagination[data-table='+ table.id +'] a[data-page='+ response.meta.page +']');
        const $table = $('#' + table.id);
        const sortParam = currentStorage[table.name +'_sort'];
        if(sortParam && sortParam != '') {
          const header = $table.find('th.tabulatr-sortable[data-tabulatr-column-name="'+ sortParam.split(' ')[0] +'"]');
          header.attr('data-sorted', sortParam.split(' ')[1]);
          header.addClass('sorted');
          $('.tabulatr_filter_form[data-table='+ table.id +'] input[name="'+ tableName +'_sort"]').val(sortParam);
        }
        $('input#'+ table.id +'_fuzzy_search_query').val(currentStorage[tableName +'_search']);
        const objKeys = Object.keys(currentStorage);
        let elem, formParent;
        for(let i = 0; i < objKeys.length; i++) {
          elem = $('[name="'+ objKeys[i] +'"]');
          if(elem.length > 0) {
            var val = currentStorage[objKeys[i]];
            elem.val(val).trigger('change');
            formParent = elem.parents('.tabulatr-filter-row');
            if(formParent.length > 0 && val && val.length > 0) {
              $('.tabulatr-outer-wrapper[data-table-id="'+table.id+'"]').addClass('filtered')
            }
          }
        }
      }
    } catch(e) {}
  }

  static resetTable(table) {
    localStorage.removeItem(table.id);
    $('table#'+ table.id).find('th.sorted').removeClass('sorted').removeAttr('data-sorted');
    $('form[data-table='+ table.id +'] input.search').val('');
    $('.tabulatr_filter_form[data-table="'+ table.id +'"]').find('input[type=text], input[type=hidden], select').val('');
    $('.tabulatr_filter_form[data-table='+ table.id +'] input[name="'+ table.name +'_sort"]').val('');
    table.updateTable({ page: 1 }, true);
  }
}
