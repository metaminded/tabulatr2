<% module_namespacing do %>
class <%= class_name %>TabulatrData < Tabulatr::Data
  <% attributes = attributes_names %>
  <% if class_name.constantize.table_exists? %>
    <% attributes << class_name.constantize.column_names.map(&:to_sym) %>
  <% end %>
  <% attributes = attributes.flatten.uniq %>
  <% if attributes.any? %>
    search :<%= attributes.last %>
  <% end %>
  <% attributes.each do |a| %>
    column :<%= a %>
  <% end %>
  <% association_names.each do |attribute| %>
    association :<%= attribute %>, :id
  <% end %>
end
<% end %>
