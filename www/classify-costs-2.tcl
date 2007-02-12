# /packages/intranet-expenses/www/classify-costs-2.tcl
#
# Copyright (C) 2003-2007 Project/Open
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
set current_user_id [ad_maybe_redirect_for_registration]
set add_expense_invoices_p [im_permission $current_user_id "add_expense_invoice"]

if {!$add_expense_invoices_p} {
    ad_return_complaint 1 [lang::message::lookup "" intranet-expenses.No_perms "You don't have permission to see this page:"]
    ad_script_abort
}


# Add a "0" expense to avoid syntax error if the list was empty.
lappend epense_ids 0


# ---------------------------------------------------------------
# assign items to project
# ---------------------------------------------------------------


db_dml update_items "
	update	im_costs
	set	project_id = :project_id
	where	cost_id in ([join $expense_ids ", "])
		and project_id is null
"


ad_returnredirect $return_url
