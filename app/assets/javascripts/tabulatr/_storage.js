$(function(){
  Tabulatr.prototype.retrieveTableFromLocalStorage = function(response){
    var currentStorage = JSON.parse(localStorage[this.id]);
    if(currentStorage !== undefined){
      $('.pagination[data-table='+ this.id +'] a[data-page='+ response.meta.page +']');
      var $table = $('#' + this.id);
      var tableName = this.id.split('_')[0];
      var sortParam = currentStorage[tableName +'_sort'];
      if(sortParam && sortParam != ''){
        var header = $table.find('th.tabulatr-sortable[data-tabulatr-column-name="'+ sortParam.split(' ')[0] +'"]');
        header.attr('data-sorted', sortParam.split(' ')[1]);
        header.addClass('sorted');
        $('.tabulatr_filter_form[data-table='+ this.id +'] input[name="'+ tableName +'_sort"]').val(sortParam);
      }
      $('input#'+ this.id +'_fuzzy_search_query').val(currentStorage[tableName +'_search']);
      var objKeys = Object.keys(currentStorage);
      var elem, formParent;
      for(var i = 0; i < objKeys.length; i++){
        elem = $('[name="'+ objKeys[i] +'"]');
        if(elem.length > 0){
          var val = currentStorage[objKeys[i]];
          elem.val(val).trigger('change');
          formParent = elem.parents('.tabulatr-filter-row');
          if(formParent.length > 0 && val && val.length > 0){
            $('.tabulatr-outer-wrapper[data-table-id="'+this.id+'"]').addClass('filtered')
          }
        }
      }
    }
  };

  Tabulatr.prototype.resetTable = function(){
    tableName = this.id.split('_')[0];
    localStorage.removeItem(this.id);
    $('table#'+ this.id).find('th.sorted').removeClass('sorted').removeAttr('data-sorted');
    $('form[data-table='+ this.id +'] input.search').val('');
    $('.tabulatr_filter_form[data-table="'+ this.id +'"]').find('input[type=text], input[type=hidden], select').val('');
    $('.tabulatr_filter_form[data-table='+ this.id +'] input[name="'+ tableName +'_sort"]').val('');
    this.updateTable({page: 1}, true);
  };
});
