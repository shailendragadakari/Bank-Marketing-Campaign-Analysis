-- ===========================================================
-- Bank Marketing Campaign Analysis - SQL EDA
-- Database: bank_marketing | Table: bank_campaigns
-- ===========================================================

-- ===========================================================
-- 1. DATASET OVERVIEW
-- ===========================================================

-- Total records and conversion split
select
	count (*) as total_records,
	sum(case when y='yes' then 1 else 0 end) as total_converted,
	sum(case when y='no' then 1 else 0 end) as total_not_converted,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns;

-- ===========================================================
-- 2. CONVERSION RATE BY JOB TYPE
-- ===========================================================
select
	job,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by job order by conversion_rate_pct desc;

-- ===========================================================
-- 3. CONVERSION RATE BY MONTH
-- ===========================================================

select
	month,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by month order by conversion_rate_pct desc;

-- ===========================================================
-- 4. CONTACT FREQUENCY - DIMINISHING RETURNS
-- ===========================================================

select
	campaign as num_contacts,
	count(*) as total_customers,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by campaign order by campaign;

-- ===========================================================
-- 5. CONVERSION BY CONTACT CHANNEL
-- ===========================================================

select
	contact as channel,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by contact order by conversion_rate_pct desc;

-- ===========================================================
-- 6. PREVIOUS CAMPAIGN OUTCOME
-- ===========================================================

select
	poutcome as previous_outcome,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by poutcome order by conversion_rate_pct desc;

-- ===========================================================
-- 7. CUSTOMER PROFILE - AGE SEGMENTS
-- ===========================================================

select
	case
		when age < 25 then 'Under 25'
		when age between 25 and 34 then '25-34'
		when age between 35 and 44 then '35-44'
		when age between 45 and 54 then '45-54'
		when age between 55 and 64 then '55-64'
		else '65+'
	end as age_group,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by age_group order by conversion_rate_pct desc;

-- ===========================================================
-- 8. CONVERSION BY EDUCATION LEVEL
-- ===========================================================

select
	education,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
group by education order by conversion_rate_pct desc;

-- ===========================================================
-- 9. HIGH VALUE SEGMENT - MULTI-FACTOR FILTER
-- 	  Customers most likely to convert based on EDA findings
-- ===========================================================

select
	job,
	education,
	contact,
	marital,
	count(*) as total_contacts,
	sum(case when y='yes' then 1 else 0 end) as conversions,
	round(sum(case when y='yes' then 1 else 0 end) * 100 / count(*), 2) as conversion_rate_pct
from bank_campaigns
where
	contact = 'cellular'
	and campaign <= 3
	and poutcome in ('success', 'nonexistent')
	and job in ('student', 'retired', 'admin.', 'unemployes')
group by job, education, contact, marital having count(*) >= 20 order by conversion_rate_pct desc;

-- ===========================================================
-- 10. ECONOMIC INDICATORS VS CONVERSION
-- 	   Average economic conditions when customers converted vs not
-- ===========================================================

select
	y as subscribed,
	round(avg("emp.var.rate")::numeric, 3) as avg_emp_var_rate,
	round(avg("cons.price.idx")::numeric, 3) as avg_cons_price_idx,
	round(avg("cons.conf.idx")::numeric, 3) as avg_cons_conf_idx,
	round(avg(euribor3m)::numeric, 3) as avg_euribor3m,
	round(avg("nr.employed")::numeric, 1) as avg_nr_employed
from bank_campaigns
group by y;
	