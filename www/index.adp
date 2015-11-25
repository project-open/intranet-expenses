<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="main_navbar_label">@main_navbar_label;literal@</property>
<property name="sub_navbar">@sub_navbar;literal@</property>
<property name="left_navbar">@left_navbar_html;literal@</property>
<property name="show_context_help">@show_context_help_p;literal@</property>

<%= [im_box_header $page_title] %>
<listtemplate name="@list_id@"></listtemplate>
<%= [im_box_footer] %>


<%= [im_box_header [lang::message::lookup "" intranet-expenses.Expense_Bundles "Expense Bundles"]] %>
<listtemplate name="@list2_id@"></listtemplate>
<%= [im_box_footer] %>
