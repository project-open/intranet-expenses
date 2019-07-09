<if @enable_master_p@>
<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="main_navbar_label">timesheet</property>
</if>

<if @message@ not nil>
  <div class="general-message">@message@</div>
</if>

<table width="100%">
  <tr valign="top">
    <td>

	<h2>@page_title@</h2>
	<table>
	<tr valign=top>
	<td>
	<formtemplate id=form></formtemplate>
	</td>
	<td align=right>
	@payment_list_html;noquote@
	</td>
	</tr>
	<tr>
	<td colspan=2>
	<h2>@included_expenses_msg@</h2>
<!--	@modify_bundle_link;noquote@-->
	<listtemplate name=@list_id@></listtemplate>
	</td>
	</tr>
	</table>

<if @form_mode@ eq "display" >
      <%= [im_component_bay left] %>
</if>

    </td>
    <td>

<if @form_mode@ eq "display" >
      <%= [im_component_bay right] %>
</if>


    </td>
  </tr>
</table>

<if @form_mode@ eq "display" >
      <%= [im_component_bay bottom] %>
</if>
