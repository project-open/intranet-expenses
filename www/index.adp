<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="main_navbar_label">@main_navbar_label;literal@</property>
<property name="sub_navbar">@sub_navbar;literal@</property>
<property name="left_navbar">@left_navbar_html;literal@</property>
<property name="show_context_help">@show_context_help_p;literal@</property>

<script type="text/javascript" <if @::__csp_nonce@ not nil>nonce="@::__csp_nonce;literal@"</if>>
window.addEventListener('load', function() { 
     document.getElementById('start_date_calendar').addEventListener('click', function() { showCalendar('start_date', 'y-m-d'); });
     document.getElementById('end_date_calendar').addEventListener('click', function() { showCalendar('end_date', 'y-m-d'); });

     document.getElementById('list_check_all').addEventListener('click', function() { acs_ListCheckAll('expenses_list', this.checked) });
});
</script>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr>
  <td colspan="3">
    <%= [im_component_bay top] %>
  </td>
</tr>
<tr>
<td>


<%= [im_box_header $page_title] %>
<listtemplate name="@list_id@"></listtemplate>
<%= [im_box_footer] %>


<%= [im_box_header [lang::message::lookup "" intranet-expenses.Expense_Bundles "Expense Bundles"]] %>
<listtemplate name="@list2_id@"></listtemplate>
<%= [im_box_footer] %>


</td>
</tr>
<tr>
  <td colspan="3">
    <%= [im_component_bay bottom] %>
  </td>
</tr>
</table>
