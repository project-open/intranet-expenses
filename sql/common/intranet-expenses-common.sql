-- /packages/intranet-expenses/sql/common/intranet-expenses-create.sql
--
-- Project/Open Expenses Core
-- 060419 avila@digiteix.com
--
-- Copyright (C) 2004 Project/Open
--
-- All rights including reserved. To inquire license terms please 
-- refer to http://www.project-open.com/modules/<module-key>

-- set escape \

-------------------------------------------------------------
-- Setup the status and type im_categories

-- 4000-4099	Intranet Expense Type
-- 4100-4199	Intranet Expense Payment Type
-- 4200-4599    (reserved)

-- prompt *** intranet-expenses: Creating URLs for viewing/editing expenses
delete from im_biz_object_urls where object_type='im_expense';
insert into im_biz_object_urls (
	object_type, 
	url_type, 
	url
) values (
	'im_expense',
	'view',
	'/intranet-expenses/new?form_mode=display\&expense_id='
);

insert into im_biz_object_urls (
	object_type, 
	url_type, 
	url
) values (
	'im_expense',
	'edit',
	'/intranet-expenses/new?form_mode=edit\&expense_id='
);


-- prompt *** intranet-expenses: Creating Expense categories
-- Intranet Expense Type
delete from im_categories where category_id >= 4000 and category_id < 4100;

-- !!! Google "project-open travel costs"

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4000,'Meals','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4001,'Fuel','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4002,'Tolls','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4003,'Km own car','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4004,'Parking','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4005,'Taxi','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4006,'Hotel','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4007,'Airfare','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4008,'Train','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4009,'Copies','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4010,'Office Material','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4011,'Telephone','Intranet Expense Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4012,'Other','Intranet Expense Type');



-- commit;
-- reserved until 4099


-- Intranet Expense Payment Type
delete from im_categories where category_id >= 4100 and category_id < 4200;

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4100,'Company Visa 1','Intranet Expense Payment Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4101,'Company Visa 2','Intranet Expense Payment Type');

INSERT INTO im_categories (CATEGORY_ID, CATEGORY, CATEGORY_TYPE)
VALUES (4102,'PayPal tigerpond@tigerpond.com','Intranet Expense Payment Type');


-- commit;
-- reserved until 4199


-- prompt *** intranet-expenses: Creating status and type views
create or replace view im_expense_type as
select
	category_id as expense_type_id,
	category as expense_type
from 	im_categories
where	category_type = 'Intranet Expense Type';

create or replace view im_expense_payment_type as
select	category_id as expense_payment_type_id, 
	category as expense_payment_type
from 	im_categories
where 	category_type = 'Intranet Expense Payment Type';


