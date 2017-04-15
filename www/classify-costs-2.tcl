# /packages/intranet-expenses/www/classify-costs-2.tcl
#
# Copyright (C) 2003 - 2009 ]project-open[
# 060427 avila@digiteix.com
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Assign several expense items to a specific project

    @author frank.bergmann@project-open.com
} {
    return_url
    project_id:integer
    expense_ids:integer,multiple
}


# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

# No ExpenseItems specified? => Go back
if {![info exists expense_ids]} { ad_returnredirect $return_url }

# User id already verified by filters
set current_user_id [auth::require_login]
set add_expense_bundles_p [im_permission $current_user_id "add_expense_bundle"]

if {!$add_expense_bundles_p} {
    ad_return_complaint 1 [lang::message::lookup "" intranet-expenses.No_perms "You don't have permission to see this page:"]
    ad_script_abort
}


# Add a "0" expense to avoid syntax error if the list was empty.
lappend epense_ids 0




# ---------------------------------------------------------------
# Check security
# ---------------------------------------------------------------

set debug_html ""
foreach id $expense_ids {
    set view_p 0
    set read_p 0
    set write_p 0
    set admin_p 0
    im_expense_permissions $current_user_id $id view_p read_p write_p admin_p
    if {!$write_p} {
	append debug_html "<li>You don't have permissions to modify expense item #$id"
    }
}
if {"" ne $debug_html} {
    ad_return_complaint 1 "<b>Classifying Expenses</b>:<br><ul>$debug_html</ul>"
    ad_script_abort
}



# ---------------------------------------------------------------
# assign items to project
# ---------------------------------------------------------------


db_dml update_items "
	update	im_costs
	set	project_id = :project_id
	where	cost_id in ([join $expense_ids ", "])
"


# Audit the action
foreach id $expense_ids {
    im_audit -object_type im_expense -action after_update -object_id $id
}


ad_returnredirect $return_url
