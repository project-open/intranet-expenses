# /packages/intranet-expenses/www/expense-del.tcl
#
# Copyright (C) 2003 - 2009 ]project-open[
# 060427 avila@digiteix.com
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# 1. Page Contract
# ---------------------------------------------------------------
ad_page_contract { 
    delete expenses

    @param project_id
           project on expense is going to create

    @author avila@digiteix.com
} {
    return_url
    expense_id:multiple
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set user_id [auth::require_login]
set current_user_id $user_id
set user_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]

set debug_html ""
foreach id $expense_id {
    set view_p 0
    set read_p 0
    set write_p 0
    set admin_p 0

    im_expense_permissions $current_user_id $id view_p read_p write_p admin_p
    if {$write_p} {
	# Audit the action
	im_audit -object_type im_expense -action before_nuke -object_id $id

	# delete expense
	db_transaction {
	    db_string del_expense {}
	}
    } else {
	append debug_html "<li>You don't have permissions to delete expense item #$id"
    }
}

if {"" ne $debug_html} {
    ad_return_complaint 1 "<b>Deleting Expenses</b>:<br><ul>$debug_html</ul>"
} else {
    ad_returnredirect $return_url
}
