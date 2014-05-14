$(function(){
  Tabulatr.prototype.retrieveTableFromLocalStorage = function(response){
    var currentStorage = JSON.parse(localStorage[this.id]);
    if(currentStorage !== undefined){
      $('.pagination[data-table='+ this.id +'] a[data-page='+ response.meta.page +']'); 
      var $table = $('#' + this.id);
      var tableName = this.id.split('_')[0];
      if(currentStorage[tableName +'_sort'] != ''){
        var sortParam = currentStorage[tableName +'_sort'];
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
          elem.val(currentStorage[objKeys[i]]);
          formParent = elem.parents('.form-group[data-filter-column-name]');
          if(formParent.length > 0){
            formParent.show();
            formParent.siblings('[data-filter-column-name="_submit"]').show();
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
    $('[data-table-id="'+ this.id +'"] [data-filter-column-name]').hide().find('input[type=text], input[type=hidden], select').val('');
    $('.tabulatr_filter_form[data-table='+ this.id +'] input[name="'+ tableName +'_sort"]').val('');
    this.updateTable({page: 1}, true);
  };
});