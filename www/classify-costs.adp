<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context_bar">@context_bar;literal@</property>
<property name="main_navbar_label">projects</property>

<h2>@page_title@</h2>

<if @message@ not nil>
  <div class="general-message">@message@</div>
</if>


<form method=get action='classify-costs-2'>
<%= [export_vars -form {return_url}] %>

@expense_ids_html;noquote@

<table>
<tr>
    <td colspan='2' class=rowtitle align="center">
      <%= [lang::message::lookup "" intranet-expenses.Assign_Expenses_to_a_Project "Assign Expenses to a Project"] %>
    </td>
</tr>
<tr>
    <td class=form-label><%= [lang::message::lookup "" intranet-expenses.Project "Project"] %></td>
    <td class=form-widget><%= [im_project_select -exclude_subprojects_p 0 -exclude_status_id [im_project_status_closed] project_id $project_id] %></td>
  </tr>
  <tr>
    <td class=form-label></td>
    <td class=form-widget><input type="submit"></td>
</tr>
</table>
</form>


<h2>Assign These Expenses</h2>


<listtemplate name="@list_id@"></listtemplate>

