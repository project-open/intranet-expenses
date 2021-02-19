# /packages/intranet-expenses/www/index.tcl
#
# Copyright (C) 2003-2008 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract { 
    @author frank.bergmann@project-open.com
} {
    { project_id:integer ""}
    { expense_type_id:integer ""}
    { start_date ""}
    { end_date ""}
    { provider_id 0}
    { orderby "effective_date,desc" }
    { unassigned ""}
    { user_id_from_search "" }
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set show_context_help_p 0

# User id already verified by filters
set user_id [auth::require_login]
set current_user_id $user_id
set page_focus "im_header_form.keywords"
set date_format "YYYY-MM-DD"
set cur_format [im_l10n_sql_currency_format]
set return_url [im_url_with_query]
set current_url [ns_conn url]
set user_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]

# Check permissions to log hours for other users
# We use the hour logging permissions also for expenses...
set add_hours_all_p [im_permission $current_user_id "add_hours_all"]
if {"" == $user_id_from_search || !$add_hours_all_p} { set user_id_from_search $current_user_id }


# Unassigned Logic
if {"" == $unassigned} {
    if {"" != $project_id} {
	# We are inside a project: Show all expenses
	set unassigned "todo"
    } else {
	# We are not inside a project: Show items without bundle
	set unassigned "unbundeled"
    }
}


set project_nr ""
set user_is_pm_p 0
db_0or1row project_info "
	select	(select project_nr from im_projects where project_id = :project_id) as project_nr,
		(select	count(*) from persons
		 where	person_id = :current_user_id and
		 	person_id in (select * from im_project_managers_enumerator(:project_id))
	       ) as user_is_pm_p
	from dual
"

set page_title "$project_nr [lang::message::lookup "" intranet-expenses.Expenses_List "Expense List"] "
if {"" != $user_id_from_search && $current_user_id != $user_id_from_search} {
    set user_name_from_search [im_name_from_user_id $user_id_from_search]
    append page_title [lang::message::lookup "" intranet-expenses.for_user_id_from_search "for '%user_name_from_search%'"]
}

set context_bar [im_context_bar [list /intranet/projects/ "[_ intranet-core.Projects]"] $page_title]
set org_project_id $project_id
set expense_type_id_default $expense_type_id

set multiple_expense_items_enabled_p [parameter::get_from_package_key -package_key "intranet-expenses" -parameter EnableMultipleExpenseItemsP -default 1] 

if {"" == $start_date} { set start_date [parameter::get_from_package_key -package_key "intranet-cost" -parameter DefaultStartDate -default "2000-01-01"] }
if {"" == $end_date} { set end_date [clock format [clock seconds] -format {%Y-%m-%d}] }

# Check that Start & End-Date have correct format
if {"" != $start_date && ![regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]} $start_date]} {
    ad_return_complaint 1 "Start Date doesn't have the right format.<br>
    Current value: '$start_date'<br>
    Expected format: 'YYYY-MM-DD'"
}

if {"" != $end_date && ![regexp {[0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9]} $end_date]} {
    ad_return_complaint 1 "End Date doesn't have the right format.<br>
    Current value: '$end_date'<br>
    Expected format: 'YYYY-MM-DD'"
}


set main_navbar_label "projects"
if {"" == $project_id | 0 == $project_id} { set main_navbar_label "expenses" }


set unassigned_p_options [list \
        "todo" [lang::message::lookup "" intranet-expenses.ToDo "Without Bundle or Project"] \
        "unassigned" [lang::message::lookup "" intranet-expenses.Without_Project "Without Project"] \
        "unbundeled" [lang::message::lookup "" intranet-expenses.Unbundeled "Without Bundle"] \
        "all" [lang::message::lookup "" intranet-expenses.All "All Expenses"] \
]

set ttt {
        "bundeled" [lang::message::lookup "" intranet-expenses.Bundeled "Bundeled Expenses"] \
        "assigned" [lang::message::lookup "" intranet-expenses.With_Project "With Projects"] \
	}


# ---------------------------------------------------------------
# Admin Links
# ---------------------------------------------------------------

set add_expense_p [im_permission $current_user_id "add_expenses"]
set create_bundle_p [im_permission $current_user_id "add_expense_bundle"]
set view_expenses_all_p [im_permission $current_user_id "view_expenses_all"]


set admin_links ""
set action_list [list]
set bulk_action_list [list]

if {$add_expense_p} {
    append admin_links "<li><a href=\"[export_vars -base new { project_id user_id_from_search return_url}]\">[lang::message::lookup "" intranet-expenses.Add_a_new_Expense_Item "Add new Expense Item"]</a></li>\n"
    if {$multiple_expense_items_enabled_p} {
	append admin_links "<li><a href=\"[export_vars -base "/intranet-expenses/new-multiple" {project_id user_id_from_search return_url}]\">[lang::message::lookup "" intranet-expenses.Add_multiple_new_Expense_Items "Add multiple new Expense Items"]</a></li>\n"
    }
    lappend bulk_action_list "[_ intranet-expenses.Delete]" "expense-del" "[_ intranet-expenses.Delete]"
}

if {$create_bundle_p} {
    lappend bulk_action_list "[lang::message::lookup "" intranet-expenses.Create_Bundle "Create Bundle"]" "[export_vars -base "bundle-create" {project_id}]" "[lang::message::lookup "" intranet-expenses.create_bundle_help "Create Bundle"]"

    lappend bulk_action_list "[lang::message::lookup "" intranet-expenses.Assign_to_a_project {Assign to a Project}]" "[export_vars -base "classify-costs" {project_id}]" "[lang::message::lookup "" intranet-expenses.Assign_to_a_project_help {Assign several expenses to a project}]"
}

set wf_installed_p 0
catch {set wf_installed_p [im_expenses_workflow_installed_p] }
# Only show this button if the user doesn't have the right to create bundles anyway
if {$wf_installed_p && !$create_bundle_p} {
    lappend bulk_action_list "[lang::message::lookup {} intranet-expenses-workflow.Request_Expense_Bundle "Request Expense Bundle"]" "[export_vars -base "bundle-create" {user_id_from_search project_id}]" "[lang::message::lookup "" intranet-expenses.Request_Expense_Bundle_Help "Request Expense Bundle"]"

}

# ---------------------------------------------------------------
# Expenses info
# ---------------------------------------------------------------

# Variables of this page to pass through the expenses_page

set export_var_list [list]

# define list object
set list_id "expenses_list"

template::list::create \
    -name $list_id \
    -multirow expense_lines \
    -key expense_id \
    -has_checkboxes \
    -actions $action_list \
    -bulk_action_method post \
    -bulk_actions $bulk_action_list \
    -bulk_action_export_vars { start_date end_date return_url user_id_from_search} \
    -row_pretty_plural "[_ intranet-expenses.Expenses_Items]" \
    -elements {
	expense_chk {
	    label "<input id=list_check_all type=\"checkbox\" name=\"_dummy\" title=\"Check/uncheck all rows\">"
	    display_template {
		@expense_lines.expense_chk;noquote@
	    }
	}
	effective_date {
	    label "[_ intranet-expenses.Expense_Date]"
	    link_url_eval $expense_new_url
	    display_template { <nobr>@expense_lines.effective_date;noquote@</nobr> }
	    orderby "c.effective_date"
	}
	amount {
	    label "[_ intranet-expenses.Amount]"
	    display_template { <nobr>@expense_lines.amount;noquote@</nobr> }
	    link_url_eval $expense_new_url
	    orderby amount
	}
	provider_name {
	    label "[lang::message::lookup {} intranet-expenses.Submitter Submitter]"
	    link_url_eval $provider_url
	    display_template { <nobr>@expense_lines.provider_name;noquote@</nobr> }
	    orderby provider_name
	}
	vat {
	    label "[_ intranet-expenses.Vat_Included]"
	    orderby vat
	}
	external_company_name {
	    label "[_ intranet-expenses.External_company_name]"
	    orderby external_company_name
	}
	receipt_reference {
	    label "[_ intranet-expenses.Receipt_reference]"
	    orderby receipt_reference
	}
	expense_type {
	    label "[_ intranet-expenses.Expense_Type]"
	    orderby expense_type
	}
	billable_p {
	    label "[_ intranet-expenses.Billable_p]"
	}
	reimbursable {
	    label "[_ intranet-expenses.reimbursable]"
	}
	expense_payment_type {
	    label "[_ intranet-expenses.Expense_Payment_Type]"
	    orderby expense_payment_type
	}
	project_name {
	    label "[_ intranet-expenses.Project_Name]"
	    link_url_eval $project_url
	    orderby project_name
	}
	expense_bundle_nr {
	    label "[lang::message::lookup {} intranet-expenses.Bundle Bundle]"
	    link_url_eval $expense_bundle_url
	}
    } \
    -filters {
 	start_date {}
        end_date {}
        project_id {}
	expense_type_id {}
	unassigned {}
    }

set ttt {
	note {
	    label "[lang::message::lookup {} intranet-expenses.Note {Note}]"
	}
}


set project_where ""
if {"" != $project_id & 0 != $project_id} { 
    set project_where "\tand c.project_id in (
		select	child.project_id
		from	im_projects parent,
			im_projects child
		where	parent.project_id = :org_project_id and
			child.tree_sortkey between parent.tree_sortkey and tree_right(parent.tree_sortkey)
	)
    " 
}

set expense_where ""
if {"" != $expense_type_id  & 0 != $expense_type_id} { 
    set expense_where "\tand e.expense_type_id = :expense_type_id\n" 
}

# Allow accounting guys to see all expense items, not just their own ones...
set personal_only_sql ""
if {!$view_expenses_all_p} { 
    set personal_only_sql "and provider_id = :user_id" 
}

# Check the case that a privileged user has selected a "log-for" user
if {$view_expenses_all_p && "" != $user_id_from_search && $current_user_id != $user_id_from_search} {
    set personal_only_sql "and provider_id = $user_id_from_search" 
}

switch $unassigned {
    "todo" { set unassigned_sql "and (c.project_id is null OR e.bundle_id is null)" }
    "unassigned" { set unassigned_sql "and c.project_id is null" }
    "assigned" { set unassigned_sql "and c.project_id is not null" }
    "unbundeled" { set unassigned_sql "and e.bundle_id is null" }
    "bundeled" { set unassigned_sql "and e.bundle_id is not null" }
    "all" { set unassigned_sql "" }
    default { set unassigned_sql "" }
}


db_multirow -extend {expense_chk project_url expense_new_url expense_bundle_url provider_url} expense_lines expenses_lines "
  select
	c.*,
	e.*,
	acs_object__name(provider_id) as provider_name,
	to_char(effective_date, :date_format) as effective_date,
	im_category_from_id(expense_type_id) as expense_type,
	im_category_from_id(expense_payment_type_id) as expense_payment_type,
	p.project_name,
	(select bun.cost_name from im_costs bun where bun.cost_id = e.bundle_id) as expense_bundle_nr
  from
	im_costs c
	LEFT OUTER JOIN im_projects p on (c.project_id = p.project_id),
	im_expenses e
  where
	c.cost_id = e.expense_id and 
	c.effective_date >= to_date(:start_date, 'YYYY-MM-DD') and
	c.effective_date <= to_date(:end_date, 'YYYY-MM-DD')
	$unassigned_sql
	$personal_only_sql
	$project_where
	$expense_where
  [template::list::orderby_clause -name $list_id -orderby]
" {
    set amount "[format %.2f [expr $amount * [expr 1 + [expr {$vat / 100}]]]] $currency"
    set vat "[format %.1f $vat] %"
    set reimbursable "[format %.1f $reimbursable] %"
    if {(![info exists bundle_id] || $bundle_id eq "")} {
	set expense_chk "<input type=\"checkbox\" 
				name=\"expense_id\" 
				value=\"$expense_id\" 
				id=\"expenses_list,$expense_id\">"
    }
    set expense_new_url [export_vars -base "/intranet-expenses/new" {expense_id return_url}]
    set provider_url [export_vars -base "/intranet/users/view" {{user_id $provider_id} return_url}]
    set project_url [export_vars -base "/intranet/projects/view" {{project_id $project_id} return_url}]
    set expense_bundle_url [export_vars -base "/intranet-expenses/bundle-new" {{form_mode display} bundle_id return_url}]
}

# ----------------------------------------------
# bundles part
# ----------------------------------------------

set list2_id "bundles_list"

set delete_bundle_p [im_permission $current_user_id "add_expense_bundle"]
set bulk2_action_list [list]

# Unconditionally allow to "Delete".
# Security is handled on a per expense_bundle level
# lappend bulk2_action_list "[_ intranet-expenses.Delete]" "bundle-del" "[_ intranet-expenses.Remove_checked_items]"
if {$delete_bundle_p} { }

template::list::create \
    -name $list2_id \
    -multirow bundle_lines \
    -key cost_id \
    -has_checkboxes \
    -bulk_action_method post \
    -bulk_actions $bulk2_action_list \
    -bulk_action_export_vars { user_id_from_search project_id } \
    -row_pretty_plural "[lang::message::lookup "" intranet-expenses.Bundle_Items "Bundle Items"]" \
    -elements {
	cost_name {
	    label "[lang::message::lookup {} intranet-expenses.Name Name]"
	    link_url_eval $bundle_url
	}
	amount {
	    label "[_ intranet-expenses.Amount]"
	}
	effective_date {
	    label "[_ intranet-expenses.Expense_Date]"
	}
	project_name {
	    label "[lang::message::lookup {} intranet-expenses.Project Project]"
	    link_url_eval $project_url
	}
	cost_status {
	    label "[lang::message::lookup {} intranet-expenses.Status Status]"
	}
	owner_name {
	    label "[lang::message::lookup {} intranet-expenses.Owner Owner]"
	    link_url_eval $owner_url
	}
    }

set ttt {
	vat {
	    label "[_ intranet-expenses.Vat_Included]"
	}
	cost_id {
	    label "[_ intranet-expenses.ID]"
	}
	bundle_chk {
	    label "<input type=\"checkbox\" id=list_check_all_bundles_list name=\"_dummy\" title=\"Check/uncheck all rows\">"
	    display_template {
		@bundle_lines.bundle_chk;noquote@
	    }
	}
}


# Allow accounting guys to see all expense items,
# not just their own ones...
set personal_only_sql "and provider_id = :user_id"
if {$view_expenses_all_p} { set personal_only_sql "" }

# Allow the project manager to see all expense bundles
if {1 == $user_is_pm_p} { set personal_only_sql "" }


db_multirow -extend {bundle_chk project_url owner_url bundle_url} bundle_lines bundle_lines "
	select	c.*,
		to_char(c.effective_date,'DD/MM/YYYY') as effective_date,
		acs_object__name(c.project_id) as project_name,
		im_category_from_id(c.cost_status_id) as cost_status,
		o.creation_user as owner_id,
		im_name_from_user_id(o.creation_user) as owner_name
	from 
		im_costs c,
		acs_objects o
	where
		c.cost_id = o.object_id
		and c.cost_type_id = [im_cost_type_expense_bundle]
		$project_where
		$personal_only_sql
" {
    set amount "[format %.2f [expr $amount * [expr 1 + [expr {$vat / 100}]]]] $currency"
    set vat "[format %.1f $vat] %"
    if {$delete_bundle_p || $owner_id == $current_user_id} {
        set bundle_chk "<input type=\"checkbox\" 
				name=\"bundle_id\" 
				value=\"$cost_id\" 
				id=\"bundles_list,$cost_id\">"
    } else {
	set bundle_chk ""
    }

    regsub -all " " $cost_status "_" cost_status_key
    set cost_status [lang::message::lookup "" intranet-core.$cost_status_key $cost_status]

    set project_url [export_vars -base "/intranet/projects/view" {{project_id $project_id} return_url}]
    set owner_url [export_vars -base "/intranet/users/view" {{user_id $owner_id} return_url}]
    set bundle_url [export_vars -base "/intranet-expenses/bundle-new" {{bundle_id $cost_id} {form_mode display} return_url}]
}


# ---------------------------------------------------------------
# Project Menu
# ---------------------------------------------------------------

# Setup the subnavbar
set bind_vars [ns_set create]
ns_set put $bind_vars project_id $project_id
ns_set put $bind_vars user_id_from_search $user_id_from_search
set project_menu_id [im_menu_id_from_label "project"]

set sub_navbar [im_sub_navbar \
    -components \
    -base_url "/intranet/projects/view?project_id=$project_id" \
    $project_menu_id \
    $bind_vars "" "pagedesriptionbar" "project_expenses"] 

if {0 == $org_project_id || "" == $org_project_id} {
    set sub_navbar ""
}


set left_navbar_html "
      <div class='filter-block'>
         <div class='filter-title'>
            [_ intranet-expenses.Filter_Expenses]
         </div>
	<form method=POST action='index'>
	[export_vars -form {orderby}]
	<table>
	<tr>
	    <td class=form-label>[lang::message::lookup "" intranet-expenses.Unassigned_items "Unassigned:"]</td>
	    <td class=form-widget>[im_select -translate_p 0 unassigned $unassigned_p_options $unassigned]</td>
	</tr>
	<tr>
	    <td class=form-label>[lang::message::lookup "" intranet-expenses.Project "Project"]</td>
	    <td class=form-widget>[im_project_select -include_empty_p 1 -exclude_status_id [im_project_status_closed] project_id $org_project_id]</td>
	</tr>
	<tr>
	    <td class=form-label>[lang::message::lookup "" intranet-expenses.Expense_Type "Type"]</td>
	    <td class=form-widget>[im_category_select -translate_p 1 -package_key "intranet-core" -include_empty_p 1  "Intranet Expense Type" expense_type_id $expense_type_id_default]</td>
	</tr>
"

if {$add_hours_all_p} {
    append left_navbar_html "
        <tr>
            <td>[lang::message::lookup "" intranet-timesheet2.Log_hours_for_user "Log Hours<br>for User"]</td>
            <td>[im_user_select -include_empty_p 1 -include_empty_name "" user_id_from_search $user_id_from_search]</td>
        </tr>
    "
}

append left_navbar_html "
	<tr>
	  <td class=form-label>[_ intranet-core.Start_Date]</td>
	  <td class=form-widget>
	    <nobr><input type='textfield' name='start_date' id='start_date' value='$start_date' size='10'> 
		<input type=\"button\" id=start_date_calendar style=\"height:20px; width:20px; background: url('/resources/acs-templating/calendar.gif');\"></nobr>
	  </td>
	</tr>
	<tr>
	  <td class=form-label>[_ intranet-core.End_Date]</td>
	  <td class=form-widget>
       	    <nobr>
	        <input type='textfield' name='end_date' id='end_date' value='$end_date' size='10'>
		<input type=\"button\" id=end_date_calendar style=\"height:20px; width:20px; background: url('/resources/acs-templating/calendar.gif');\">
	    </nobr>
	  </td>
	</tr>

	<tr>
	    <td class=form-label></td>
	    <td class=form-widget><input type=submit></td>
	</tr>
	</table>
	</form>
      </div>
"


if {"" != $admin_links} {
    append left_navbar_html "
         <hr/>
         <div class='filter-block'>
            <div class='filter-title'>
       	       [_ intranet-core.Admin_Links]
            </div>
            <ul>
               $admin_links
            </ul>
         </div>
    "
}
