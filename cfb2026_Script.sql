select * from pg_stat_activity;

SELECT query, calls, total_exec_time, rows
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 50;



INSERT INTO cfb2025.off_ypp_2025wk5_6 (team, conference, classification, rush_ypp,n_rush, pass_ypp,n_pass) 
select a.team, conference, classification, a.rush_ypp, a.n_rush, a.pass_ypp, a.n_pass from cfb2025.all_team_off_data_wk5_6 a
left join cfb2025.team_record_wk5 b on a.team = b.team;

select *from cfb2025.all_team_off_data_wk5_6;

drop table cfb2025.off_ypp_2025wk5_6;

SELECT 
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema  ILIKE 'public%';


select * from information_schema.tables where  table_name in ('brown_roster',
'michigan_state_schedule',
'lake_superior_state_schedule',
'north_dakota_schedule',
'michigan_schedule',
'princeton_schedule',
'denver_schedule',
'minnesota_state_schedule',
'augustana_schedule',
'canisius_schedule',
'clarkson_stats_table4',
'michigan_tech_schedule',
'miami_stats_table4',
'minnesota_schedule',
'alaska_anchorage_schedule',
'canisius_stats_table3',
'bemidji_state_stats_table4');

CREATE SCHEMA ncaahockey2026;
drop schema chockey2026;


select * from  bemidji_state_stats_table4;
select * from  bemidji_state_stats_table3;
select * from  bemidji_state_stats_table2;
select * from  bemidji_state_stats_table1;
select * from  bemidji_state_schedule;
select * from  bemidji_state_roster;

select *  FROM information_schema.schemata where schema_name = 'ncaahockey2026';
select *  FROM information_schema.tables where table_schema = 'ncaahockey2026';
select *  FROM information_schema.tables where table_name ilike '%_roster';
select count(1)  from minnesota_roster where "NHL.Draft" isnull;
select count(1)  from minnesota_roster where "NHL.Draft" notnull;
select count(1)  from minnesota_roster where "NHL.Draft" <> '';
select count(1)  from minnesota_roster where "NHL.Draft" = '';
select count(1)  from minnesota_roster; 
select * from minnesota_roster; 
select * from army_west_point_roster;

select * from ncaahockey2026.scoring_margin;
select * from ncaahockey2026.team_short_handed_goals;
select * from ncaahockey2026.blocks;
select * from ncaahockey2026.faceoff_win_percentage;
select * from ncaahockey2026.penalty_killing_percentage;
select * from ncaahockey2026.power_play_percentage;
select * from ncaahockey2026.scoring_defense;
select * from ncaahockey2026.scoring_offense;
select * from ncaahockey2026.team_penalty_minutes_per_game;
select * from ncaahockey2026.winning_percentage;

select *  FROM information_schema.columns
WHERE column_name ILIKE 'conference'and table_name ilike '%5_6%';

select * from cfb2025.team_basic_wk5_6;

select *  FROM information_schema.columns
WHERE column_name ILIKE  '%mascot%';

select *  FROM information_schema.columns
WHERE column_name ILIKE  'classification';

select * from cfb2025.team_record_wk5;

select * from cfb2025.off_ypp_2024;




select count(1)  from minnesota_roster where "NHL.Draft" <> '';
select *  FROM information_schema.tables where table_name ilike '%_roster';

select 'select count(1)  from '||w."Team"||'_roster where "NHL.Draft" <> '''';' from ncaahockey2026.winning_percentage w;
select 'select count(1)  from '||w.table_name||' where "NHL.Draft" <> '''';' from information_schema.tables w where table_name ilike '%_roster';
select * from  ncaahockey2026.winning_percentage w;
select 'select *  from '||w.table_name||';' from information_schema.tables w where table_name ilike '%_roster';



select "Team" from ncaahockey2026.winning_percentage;
select *  from ncaahockey2026.air_force_roster 
create table ncaahockey2026.nhl_draftees as
select count(1) as numdraftees from ncaahockey2026.Michigan_roster where "NHL.Draft" <> '';

select count(1)  from air_force_roster where "NHL.Draft" <> '';
select count(1)  from alaska_anchorage_roster where "NHL.Draft" <> '';
select count(1)  from alaska_roster where "NHL.Draft" <> '';
select count(1)  from arizona_state_roster where "NHL.Draft" <> '';
select count(1)  from army_west_point_roster where "NHL.Draft" <> '';
select count(1)  from augustana_roster where "NHL.Draft" <> '';
select count(1)  from bemidji_state_roster where "NHL.Draft" <> '';
select count(1)  from bentley_roster where "NHL.Draft" <> '';
select count(1)  from boston_college_roster where "NHL.Draft" <> '';
select count(1)  from boston_university_roster where "NHL.Draft" <> '';
select count(1)  from bowling_green_roster where "NHL.Draft" <> '';
select count(1)  from brown_roster where "NHL.Draft" <> '';
select count(1)  from canisius_roster where "NHL.Draft" <> '';
select count(1)  from clarkson_roster where "NHL.Draft" <> '';
select count(1)  from colgate_roster where "NHL.Draft" <> '';
select count(1)  from colorado_college_roster where "NHL.Draft" <> '';
select count(1)  from cornell_roster where "NHL.Draft" <> '';
select count(1)  from dartmouth_roster where "NHL.Draft" <> '';
select count(1)  from denver_roster where "NHL.Draft" <> '';
select count(1)  from ferris_state_roster where "NHL.Draft" <> '';
select count(1)  from harvard_roster where "NHL.Draft" <> '';
select count(1)  from holy_cross_roster where "NHL.Draft" <> '';
select count(1)  from lake_superior_state_roster where "NHL.Draft" <> '';
select count(1)  from lindenwood_roster where "NHL.Draft" <> '';
select count(1)  from long_island_roster where "NHL.Draft" <> '';
select count(1)  from maine_roster where "NHL.Draft" <> '';
select count(1)  from massachusetts_roster where "NHL.Draft" <> '';
select count(1)  from mercyhurst_roster where "NHL.Draft" <> '';
select count(1)  from merrimack_roster where "NHL.Draft" <> '';
select count(1)  from miami_roster where "NHL.Draft" <> '';
select count(1)  from michigan_roster where "NHL.Draft" <> '';
select count(1)  from michigan_state_roster where "NHL.Draft" <> '';
select count(1)  from michigan_tech_roster where "NHL.Draft" <> '';
select count(1)  from minnesota_duluth_roster where "NHL.Draft" <> '';
select count(1)  from minnesota_roster where "NHL.Draft" <> '';
select count(1)  from minnesota_state_roster where "NHL.Draft" <> '';
select count(1)  from new_hampshire_roster where "NHL.Draft" <> '';
select count(1)  from niagara_roster where "NHL.Draft" <> '';
select count(1)  from north_dakota_roster where "NHL.Draft" <> '';
select count(1)  from northeastern_roster where "NHL.Draft" <> '';
select count(1)  from northern_michigan_roster where "NHL.Draft" <> '';
select count(1)  from notre_dame_roster where "NHL.Draft" <> '';
select count(1)  from ohio_state_roster where "NHL.Draft" <> '';
select count(1)  from omaha_roster where "NHL.Draft" <> '';
select count(1)  from penn_state_roster where "NHL.Draft" <> '';
select count(1)  from princeton_roster where "NHL.Draft" <> '';
select count(1)  from providence_roster where "NHL.Draft" <> '';
select count(1)  from quinnipiac_roster where "NHL.Draft" <> '';
select count(1)  from rit_roster where "NHL.Draft" <> '';
select count(1)  from robert_morris_roster where "NHL.Draft" <> '';
select count(1)  from rpi_roster where "NHL.Draft" <> '';
select count(1)  from sacred_heart_roster where "NHL.Draft" <> '';
select count(1)  from st_cloud_state_roster where "NHL.Draft" <> '';
select count(1)  from st_lawrence_roster where "NHL.Draft" <> '';
select count(1)  from st_thomas_roster where "NHL.Draft" <> '';
select count(1)  from stonehill_roster where "NHL.Draft" <> '';
select count(1)  from uconn_roster where "NHL.Draft" <> '';
select count(1)  from umass_lowell_roster where "NHL.Draft" <> '';
select count(1)  from union_roster where "NHL.Draft" <> '';
select count(1)  from vermont_roster where "NHL.Draft" <> '';
select count(1)  from western_michigan_roster where "NHL.Draft" <> '';
select count(1)  from wisconsin_roster where "NHL.Draft" <> '';
select count(1)  from yale_roster where "NHL.Draft" <> '';

select *  from  ncaahockey2026.nhl_draftees ;


select *  from air_force_roster;
select *  from alaska_anchorage_roster;
select *  from alaska_roster;
select *  from arizona_state_roster;
select *  from army_west_point_roster;
select *  from augustana_roster;
select *  from bemidji_state_roster;
select *  from bentley_roster;
select *  from boston_college_roster;
select *  from boston_university_roster;
select *  from bowling_green_roster;
select *  from brown_roster;
select *  from canisius_roster;
select *  from clarkson_roster;
select *  from colgate_roster;
select *  from colorado_college_roster;
select *  from cornell_roster;
select *  from dartmouth_roster;
select *  from denver_roster;
select *  from ferris_state_roster;
select *  from harvard_roster;
select *  from holy_cross_roster;
select *  from lake_superior_state_roster;
select *  from lindenwood_roster;
select *  from long_island_roster;
select *  from maine_roster;
select *  from massachusetts_roster;
select *  from mercyhurst_roster;
select *  from merrimack_roster;
select *  from miami_roster;
select *  from michigan_roster;
select *  from michigan_state_roster;
select *  from michigan_tech_roster;
select *  from minnesota_duluth_roster;
select *  from minnesota_roster;
select *  from minnesota_state_roster;
select *  from new_hampshire_roster;
select *  from niagara_roster;
select *  from north_dakota_roster;
select *  from northeastern_roster;
select *  from northern_michigan_roster;
select *  from notre_dame_roster;
select *  from ohio_state_roster;
select *  from omaha_roster;
select *  from penn_state_roster;
select *  from princeton_roster;
select *  from providence_roster;
select *  from quinnipiac_roster;
select *  from rit_roster;
select *  from robert_morris_roster;
select *  from rpi_roster;
select *  from sacred_heart_roster;
select *  from st_cloud_state_roster;
select *  from st_lawrence_roster;
select *  from st_thomas_roster;
select *  from stonehill_roster;
select *  from uconn_roster;
select *  from umass_lowell_roster;
select *  from union_roster;
select *  from vermont_roster;
select *  from western_michigan_roster;
select *  from wisconsin_roster;
select *  from yale_roster;

select *  FROM information_schema.columns
WHERE  table_name ilike '%_roster' order by 3,4;

select table_name, column_name   FROM information_schema.columns
WHERE  table_name ilike '%_roster' order by 1,2;

select table_schema,table_name, column_name   FROM information_schema.columns
WHERE  table_name ilike '%_roster' order by 1,2,3;

select *  FROM information_schema.tables
WHERE  table_schema ilike 'c%' or  table_schema ilike 'n%';

select table_schema, table_name, count(1)   FROM information_schema.tables
WHERE  table_name ilike '%_roster' or table_name ilike '%_stats_table%' or table_name ilike '%_schedule'
group by 1,2
;

-- table_schema ilike 'c%' or  table_schema ilike 'n%' or  table_schema ilike 'p%'

select table_schema, table_name, count(1)   FROM information_schema.tables 
--where  table_schema ilike 'public' and table_name not ilike '%_roster' and table_name not ilike '%_stats_table%' and table_name not ilike '%_schedule'
group by 1,2;


table_name ilike '%_roster' order by 1,2,3;

select table_schema,  count(1)   FROM information_schema.tables 
where  table_schema ilike 'ncaahockey2026' and table_name not ilike '%_roster' and table_name not ilike '%_stats_table%' and table_name not ilike '%_schedule'
group by 1;

select *  FROM information_schema.tables 
where  table_schema ilike 'ncaahockey2026' and table_name not ilike '%_roster' and table_name not ilike '%_stats_table%' and table_name not ilike '%_schedule'
order by 3;

select table_schema, table_name, count(1)   FROM information_schema.tables 
where  table_schema ilike 'public' and (table_name  ilike '%_roster' or table_name  ilike '%_stats_table%' or table_name  ilike '%_schedule')
group by 1,2;


drop table 
where  table_schema ilike 'public' and (table_name  ilike '%_roster' or table_name  ilike '%_stats_table%' or table_name  ilike '%_schedule')
group by 1,2;


select 'drop table '||table_schema||'.'||table_name||'; ' FROM information_schema.tables 
where  table_schema ilike 'public' and (table_name  ilike '%_roster' or table_name  ilike '%_stats_table%' or table_name  ilike '%_schedule')
;

commit;

drop table public.air_force_roster; 

drop table public.air_force_schedule; 

drop table public.air_force_stats_table1; 

drop table public.air_force_stats_table2; 

drop table public.air_force_stats_table3; 

drop table public.air_force_stats_table4; 


drop table public.alaska_anchorage_roster; 
drop table public.alaska_anchorage_schedule; 
drop table public.alaska_anchorage_stats_table1; 
drop table public.alaska_anchorage_stats_table2; 
drop table public.alaska_anchorage_stats_table3; 
drop table public.alaska_anchorage_stats_table4; 
drop table public.alaska_roster; 
drop table public.alaska_schedule; 
drop table public.alaska_stats_table1; 
drop table public.alaska_stats_table2; 
drop table public.alaska_stats_table3; 
drop table public.alaska_stats_table4; 

drop table public.arizona_state_roster; 
drop table public.arizona_state_schedule; 
drop table public.arizona_state_stats_table1; 
drop table public.arizona_state_stats_table2; 
drop table public.arizona_state_stats_table3; 
drop table public.arizona_state_stats_table4; 
drop table public.army_west_point_roster; 
drop table public.army_west_point_schedule; 
drop table public.army_west_point_stats_table1; 
drop table public.army_west_point_stats_table2; 
drop table public.army_west_point_stats_table3; 
drop table public.army_west_point_stats_table4; 
drop table public.augustana_roster; 
drop table public.augustana_schedule; 
drop table public.augustana_stats_table1; 
drop table public.augustana_stats_table2; 
drop table public.augustana_stats_table3; 
drop table public.augustana_stats_table4; 
drop table public.bemidji_state_roster; 
drop table public.bemidji_state_schedule; 
drop table public.bemidji_state_stats_table1; 
drop table public.bemidji_state_stats_table2; 
drop table public.bemidji_state_stats_table3; 
drop table public.bemidji_state_stats_table4; 
drop table public.bentley_roster; 
drop table public.bentley_schedule; 
drop table public.bentley_stats_table1; 
drop table public.bentley_stats_table2; 
drop table public.bentley_stats_table3; 
drop table public.bentley_stats_table4; 
drop table public.boston_college_roster; 
drop table public.boston_college_schedule; 
drop table public.boston_college_stats_table1; 
drop table public.boston_college_stats_table2; 
drop table public.boston_college_stats_table3; 
drop table public.boston_college_stats_table4; 
drop table public.boston_university_roster; 
drop table public.boston_university_schedule; 
drop table public.boston_university_stats_table1; 
drop table public.boston_university_stats_table2; 
drop table public.boston_university_stats_table3; 
drop table public.boston_university_stats_table4; 
drop table public.bowling_green_roster; 
drop table public.bowling_green_schedule; 
drop table public.bowling_green_stats_table1; 
drop table public.bowling_green_stats_table2; 
drop table public.bowling_green_stats_table3; 
drop table public.bowling_green_stats_table4; 
drop table public.brown_roster; 
drop table public.brown_schedule; 
drop table public.brown_stats_table1; 
drop table public.brown_stats_table2; 
drop table public.brown_stats_table3; 
drop table public.brown_stats_table4; 
drop table public.canisius_roster; 
drop table public.canisius_schedule; 
drop table public.canisius_stats_table1; 
drop table public.canisius_stats_table2; 
drop table public.canisius_stats_table3; 
drop table public.canisius_stats_table4; 
drop table public.clarkson_roster; 
drop table public.clarkson_schedule; 
drop table public.clarkson_stats_table1; 
drop table public.clarkson_stats_table2; 
drop table public.clarkson_stats_table3; 
drop table public.clarkson_stats_table4; 
drop table public.colgate_roster; 
drop table public.colgate_schedule; 
drop table public.colgate_stats_table1; 
drop table public.colgate_stats_table2; 
drop table public.colgate_stats_table3; 
drop table public.colgate_stats_table4; 
drop table public.colorado_college_roster; 
drop table public.colorado_college_schedule; 
drop table public.colorado_college_stats_table1; 
drop table public.colorado_college_stats_table2; 
drop table public.colorado_college_stats_table3; 
drop table public.colorado_college_stats_table4; 
drop table public.cornell_roster; 
drop table public.cornell_schedule; 
drop table public.cornell_stats_table1; 
drop table public.cornell_stats_table2; 
drop table public.cornell_stats_table3; 
drop table public.cornell_stats_table4; 
drop table public.dartmouth_roster; 
drop table public.dartmouth_schedule; 
drop table public.dartmouth_stats_table1; 
drop table public.dartmouth_stats_table2; 
drop table public.dartmouth_stats_table3; 
drop table public.dartmouth_stats_table4; 
drop table public.denver_roster; 
drop table public.denver_schedule; 
drop table public.denver_stats_table1; 
drop table public.denver_stats_table2; 
drop table public.denver_stats_table3; 
drop table public.denver_stats_table4; 
drop table public.ferris_state_roster; 
drop table public.ferris_state_schedule; 
drop table public.ferris_state_stats_table1; 
drop table public.ferris_state_stats_table2; 
drop table public.ferris_state_stats_table3; 
drop table public.ferris_state_stats_table4; 
drop table public.harvard_roster; 
drop table public.harvard_schedule; 
drop table public.harvard_stats_table1; 
drop table public.harvard_stats_table2; 
drop table public.harvard_stats_table3; 
drop table public.harvard_stats_table4; 
drop table public.holy_cross_roster; 
drop table public.holy_cross_schedule; 
drop table public.holy_cross_stats_table1; 
drop table public.holy_cross_stats_table2; 
drop table public.holy_cross_stats_table3; 
drop table public.holy_cross_stats_table4; 
drop table public.lake_superior_state_roster; 
drop table public.lake_superior_state_schedule; 
drop table public.lake_superior_state_stats_table1; 
drop table public.lake_superior_state_stats_table2; 
drop table public.lake_superior_state_stats_table3; 
drop table public.lake_superior_state_stats_table4; 
drop table public.lindenwood_roster; 
drop table public.lindenwood_schedule; 
drop table public.lindenwood_stats_table1; 
drop table public.lindenwood_stats_table2; 
drop table public.lindenwood_stats_table3; 
drop table public.lindenwood_stats_table4; 
drop table public.long_island_roster; 
drop table public.long_island_schedule; 
drop table public.long_island_stats_table1; 
drop table public.long_island_stats_table2; 
drop table public.long_island_stats_table3; 
drop table public.long_island_stats_table4; 
drop table public.maine_roster; 
drop table public.maine_schedule; 
drop table public.maine_stats_table1; 
drop table public.maine_stats_table2; 
drop table public.maine_stats_table3; 
drop table public.maine_stats_table4; 
drop table public.massachusetts_roster; 
drop table public.massachusetts_schedule; 
drop table public.massachusetts_stats_table1; 
drop table public.massachusetts_stats_table2; 
drop table public.massachusetts_stats_table3; 
drop table public.massachusetts_stats_table4; 
drop table public.mercyhurst_roster; 
drop table public.mercyhurst_schedule; 
drop table public.mercyhurst_stats_table1; 
drop table public.mercyhurst_stats_table2; 
drop table public.mercyhurst_stats_table3; 
drop table public.mercyhurst_stats_table4; 
drop table public.merrimack_roster; 
drop table public.merrimack_schedule; 
drop table public.merrimack_stats_table1; 
drop table public.merrimack_stats_table2; 
drop table public.merrimack_stats_table3; 
drop table public.merrimack_stats_table4; 
drop table public.miami_roster; 
drop table public.miami_schedule; 
drop table public.miami_stats_table1; 
drop table public.miami_stats_table2; 
drop table public.miami_stats_table3; 
drop table public.miami_stats_table4; 
drop table public.michigan_roster; 
drop table public.michigan_schedule; 
drop table public.michigan_state_roster; 
drop table public.michigan_state_schedule; 
drop table public.michigan_state_stats_table1; 
drop table public.michigan_state_stats_table2; 
drop table public.michigan_state_stats_table3; 
drop table public.michigan_state_stats_table4; 
drop table public.michigan_stats_table1; 
drop table public.michigan_stats_table2; 
drop table public.michigan_stats_table3; 
drop table public.michigan_stats_table4; 
drop table public.michigan_tech_roster; 
drop table public.michigan_tech_schedule; 
drop table public.michigan_tech_stats_table1; 
drop table public.michigan_tech_stats_table2; 
drop table public.michigan_tech_stats_table3; 
drop table public.michigan_tech_stats_table4; 
drop table public.minnesota_duluth_roster; 
drop table public.minnesota_duluth_schedule; 
drop table public.minnesota_duluth_stats_table1; 
drop table public.minnesota_duluth_stats_table2; 
drop table public.minnesota_duluth_stats_table3; 
drop table public.minnesota_duluth_stats_table4; 
drop table public.minnesota_roster; 
drop table public.minnesota_schedule; 
drop table public.minnesota_state_roster; 
drop table public.minnesota_state_schedule; 
drop table public.minnesota_state_stats_table1; 
drop table public.minnesota_state_stats_table2; 
drop table public.minnesota_state_stats_table3; 
drop table public.minnesota_state_stats_table4; 
drop table public.minnesota_stats_table1; 
drop table public.minnesota_stats_table2; 
drop table public.minnesota_stats_table3; 
drop table public.minnesota_stats_table4; 
drop table public.new_hampshire_roster; 
drop table public.new_hampshire_schedule; 
drop table public.new_hampshire_stats_table1; 
drop table public.new_hampshire_stats_table2; 
drop table public.new_hampshire_stats_table3; 
drop table public.new_hampshire_stats_table4; 
drop table public.niagara_roster; 
drop table public.niagara_schedule; 
drop table public.niagara_stats_table1; 
drop table public.niagara_stats_table2; 
drop table public.niagara_stats_table3; 
drop table public.niagara_stats_table4; 
drop table public.north_dakota_roster; 
drop table public.north_dakota_schedule; 
drop table public.north_dakota_stats_table1; 
drop table public.north_dakota_stats_table2; 
drop table public.north_dakota_stats_table3; 
drop table public.north_dakota_stats_table4; 
drop table public.northeastern_roster; 
drop table public.northeastern_schedule; 
drop table public.northeastern_stats_table1; 
drop table public.northeastern_stats_table2; 
drop table public.northeastern_stats_table3; 
drop table public.northeastern_stats_table4; 
drop table public.northern_michigan_roster; 
drop table public.northern_michigan_schedule; 
drop table public.northern_michigan_stats_table1; 
drop table public.northern_michigan_stats_table2; 
drop table public.northern_michigan_stats_table3; 
drop table public.northern_michigan_stats_table4; 
drop table public.notre_dame_roster; 
drop table public.notre_dame_schedule; 
drop table public.notre_dame_stats_table1; 
drop table public.notre_dame_stats_table2; 
drop table public.notre_dame_stats_table3; 
drop table public.notre_dame_stats_table4; 
drop table public.ohio_state_roster; 
drop table public.ohio_state_schedule; 
drop table public.ohio_state_stats_table1; 
drop table public.ohio_state_stats_table2; 
drop table public.ohio_state_stats_table3; 
drop table public.ohio_state_stats_table4; 
drop table public.omaha_roster; 
drop table public.omaha_schedule; 
drop table public.omaha_stats_table1; 
drop table public.omaha_stats_table2; 
drop table public.omaha_stats_table3; 
drop table public.omaha_stats_table4; 
drop table public.penn_state_roster; 
drop table public.penn_state_schedule; 
drop table public.penn_state_stats_table1; 
drop table public.penn_state_stats_table2; 
drop table public.penn_state_stats_table3; 
drop table public.penn_state_stats_table4; 
drop table public.princeton_roster; 
drop table public.princeton_schedule; 
drop table public.princeton_stats_table1; 
drop table public.princeton_stats_table2; 
drop table public.princeton_stats_table3; 
drop table public.princeton_stats_table4; 
drop table public.providence_roster; 
drop table public.providence_schedule; 
drop table public.providence_stats_table1; 
drop table public.providence_stats_table2; 
drop table public.providence_stats_table3; 
drop table public.providence_stats_table4; 
drop table public.quinnipiac_roster; 
drop table public.quinnipiac_schedule; 
drop table public.quinnipiac_stats_table1; 
drop table public.quinnipiac_stats_table2; 
drop table public.quinnipiac_stats_table3; 
drop table public.quinnipiac_stats_table4; 
drop table public.rit_roster; 
drop table public.rit_schedule; 
drop table public.rit_stats_table1; 
drop table public.rit_stats_table2; 
drop table public.rit_stats_table3; 
drop table public.rit_stats_table4; 
drop table public.robert_morris_roster; 
drop table public.robert_morris_schedule; 
drop table public.robert_morris_stats_table1; 
drop table public.robert_morris_stats_table2; 
drop table public.robert_morris_stats_table3; 
drop table public.robert_morris_stats_table4; 
drop table public.rpi_roster; 
drop table public.rpi_schedule; 
drop table public.rpi_stats_table1; 
drop table public.rpi_stats_table2; 
drop table public.rpi_stats_table3; 
drop table public.rpi_stats_table4; 
drop table public.sacred_heart_roster; 
drop table public.sacred_heart_schedule; 
drop table public.sacred_heart_stats_table1; 
drop table public.sacred_heart_stats_table2; 
drop table public.sacred_heart_stats_table3; 
drop table public.sacred_heart_stats_table4; 
drop table public.st_cloud_state_roster; 
drop table public.st_cloud_state_schedule; 
drop table public.st_cloud_state_stats_table1; 
drop table public.st_cloud_state_stats_table2; 
drop table public.st_cloud_state_stats_table3; 
drop table public.st_cloud_state_stats_table4; 
drop table public.st_lawrence_roster; 
drop table public.st_lawrence_schedule; 
drop table public.st_lawrence_stats_table1; 
drop table public.st_lawrence_stats_table2; 
drop table public.st_lawrence_stats_table3; 
drop table public.st_lawrence_stats_table4; 
drop table public.st_thomas_roster; 
drop table public.st_thomas_schedule; 
drop table public.st_thomas_stats_table1; 
drop table public.st_thomas_stats_table2; 
drop table public.st_thomas_stats_table3; 
drop table public.st_thomas_stats_table4; 
drop table public.stonehill_roster; 
drop table public.stonehill_schedule; 
drop table public.stonehill_stats_table1; 
drop table public.stonehill_stats_table2; 
drop table public.stonehill_stats_table3; 
drop table public.stonehill_stats_table4; 
drop table public.uconn_roster; 
drop table public.uconn_schedule; 
drop table public.uconn_stats_table1; 
drop table public.uconn_stats_table2; 
drop table public.uconn_stats_table3; 
drop table public.uconn_stats_table4; 
drop table public.umass_lowell_roster; 
drop table public.umass_lowell_schedule; 
drop table public.umass_lowell_stats_table1; 
drop table public.umass_lowell_stats_table2; 
drop table public.umass_lowell_stats_table3; 
drop table public.umass_lowell_stats_table4; 
drop table public.union_roster; 
drop table public.union_schedule; 
drop table public.union_stats_table1; 
drop table public.union_stats_table2; 
drop table public.union_stats_table3; 
drop table public.union_stats_table4; 
drop table public.vermont_roster; 
drop table public.vermont_schedule; 
drop table public.vermont_stats_table1; 
drop table public.vermont_stats_table2; 
drop table public.vermont_stats_table3; 
drop table public.vermont_stats_table4; 
drop table public.western_michigan_roster; 
drop table public.western_michigan_schedule; 
drop table public.western_michigan_stats_table1; 
drop table public.western_michigan_stats_table2; 
drop table public.western_michigan_stats_table3; 
drop table public.western_michigan_stats_table4; 
drop table public.wisconsin_roster; 
drop table public.wisconsin_schedule; 
drop table public.wisconsin_stats_table1; 
drop table public.wisconsin_stats_table2; 
drop table public.wisconsin_stats_table3; 
drop table public.wisconsin_stats_table4; 
drop table public.yale_roster; 
drop table public.yale_schedule; 
drop table public.yale_stats_table1; 
drop table public.yale_stats_table2; 
drop table public.yale_stats_table3; 
drop table public.yale_stats_table4; 



ALTER TABLE ncaahockey2026.air_force_roster 
RENAME COLUMN "NHL.Draft" TO "nhl_draft";

select *  from information_schema.tables w 
where w.table_schema ilike 'ncaahockey2026' and w.table_name  ilike '%_roster' ;
select 'alaska_anchorage_roster' as team, count(1) as numdraft  from ncaahockey2026.alaska_anchorage_roster r WHERE r.nhl_draft IS TRUE group by 1 order by 1;


select 'select '''||w.table_name||''' as team, count(1) as numdraft  from ncaahockey2026.'||w.table_name||' r WHERE r.nhl_draft IS TRUE group by 1 order by 1;' from information_schema.tables w 
where w.table_schema ilike 'ncaahockey2026' and w.table_name  ilike '%_roster' ;

select 'bemidji_state_roster' as team, count(1) as numdraft  from ncaahockey2026.bemidji_state_roster r WHERE r.nhl_draft IS TRUE group by 1 order by 1;

SELECT 
    'air_force_roster' AS team, 
    COUNT(1) AS numdraft 
FROM 
    ncaahockey2026.air_force_roster r 
WHERE 
    r.nhl_draft IS NOT NULL 
    AND r.nhl_draft != ''
GROUP BY 1 
ORDER BY 1;

SQL Error [22P02]: ERROR: invalid input syntax for type boolean: ""
  Position: 172

SELECT 
    'air_force_roster' AS team, 
    COUNT(1) AS numdraft 
FROM 
    ncaahockey2026.air_force_roster r 
WHERE 
    r.nhl_draft IS TRUE
GROUP BY 1 
ORDER BY 1;

  
  
  
  
select * from ncaahockey2026.air_force_roster r





ALTER TABLE ncaahockey2026.air_force_roster  RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.alaska_anchorage_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.alaska_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.arizona_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.army_west_point_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.augustana_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.bemidji_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.bentley_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.boston_college_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.boston_university_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.bowling_green_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.brown_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.canisius_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.clarkson_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.colgate_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.colorado_college_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.cornell_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.dartmouth_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.denver_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.ferris_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.harvard_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.holy_cross_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.lake_superior_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";

ALTER TABLE ncaahockey2026.lindenwood_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.long_island_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.maine_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.massachusetts_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.mercyhurst_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.merrimack_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.miami_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.michigan_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.michigan_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.michigan_tech_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.minnesota_duluth_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.minnesota_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.minnesota_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.new_hampshire_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.niagara_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.north_dakota_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.northeastern_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.northern_michigan_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.notre_dame_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.ohio_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.omaha_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.penn_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.princeton_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.providence_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.quinnipiac_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.rit_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.robert_morris_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";

ALTER TABLE ncaahockey2026.rpi_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.sacred_heart_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.st__cloud_state_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.st__lawrence_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.st__thomas_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.stonehill_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.uconn_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.umass_lowell_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.union_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.vermont_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.western_michigan_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";
ALTER TABLE ncaahockey2026.wisconsin_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";

ALTER TABLE ncaahockey2026.yale_roster RENAME COLUMN "NHL.Draft" TO "nhl_draft";


select count(1)  from ncaahockey2026.vermont_roster where "NHL.Draft" <> '';

drop table ncaahockey2026.nhl_draft_counts;
create table ncaahockey2026.nhl_draft_counts AS
select 'air_force_roster' as team, count(1) as numdraft  from ncaahockey2026.air_force_roster r WHERE r.nhl_draft IS TRUE ;

select * from ncaahockey2026.nhl_draft_counts ;

select 'alaska_anchorage_roster' as team, count(1) as numdraft from ncaahockey2026.alaska_anchorage_roster r 


select * from ncaahockey2026.miami_roster


insert into ncaahockey2026.nhl_draft_counts (team, numdraft)
select 'alaska_anchorage_roster' as team, count(1) as numdraft  from ncaahockey2026.alaska_anchorage_roster r WHERE r.nhl_draft != '' union all
select 'alaska_roster' as team, count(1) as numdraft  from ncaahockey2026.alaska_roster r WHERE r.nhl_draft != '' union all 
select 'arizona_state_roster' as team, count(1) as numdraft  from ncaahockey2026.arizona_state_roster r WHERE r.nhl_draft != '' union all 
select 'army_west_point_roster' as team, count(1) as numdraft  from ncaahockey2026.army_west_point_roster r WHERE r.nhl_draft != '' union all 
select 'augustana_roster' as team, count(1) as numdraft  from ncaahockey2026.augustana_roster r WHERE r.nhl_draft != '' union all 
select 'bemidji_state_roster' as team, count(1) as numdraft  from ncaahockey2026.bemidji_state_roster r WHERE r.nhl_draft != '' union all 
select 'bentley_roster' as team, count(1) as numdraft  from ncaahockey2026.bentley_roster r WHERE r.nhl_draft != '' union all 
select 'boston_college_roster' as team, count(1) as numdraft  from ncaahockey2026.boston_college_roster r WHERE r.nhl_draft != '' union all 
select 'boston_university_roster' as team, count(1) as numdraft  from ncaahockey2026.boston_university_roster r WHERE r.nhl_draft != '' union all 
select 'bowling_green_roster' as team, count(1) as numdraft  from ncaahockey2026.bowling_green_roster r WHERE r.nhl_draft != '' union all 
select 'brown_roster' as team, count(1) as numdraft  from ncaahockey2026.brown_roster r WHERE r.nhl_draft != '' union all 
select 'canisius_roster' as team, count(1) as numdraft  from ncaahockey2026.canisius_roster r WHERE r.nhl_draft != '' union all 
select 'clarkson_roster' as team, count(1) as numdraft  from ncaahockey2026.clarkson_roster r WHERE r.nhl_draft != '' union all 
select 'colgate_roster' as team, count(1) as numdraft  from ncaahockey2026.colgate_roster r WHERE r.nhl_draft != '' union all 
select 'colorado_college_roster' as team, count(1) as numdraft  from ncaahockey2026.colorado_college_roster r WHERE r.nhl_draft != '' union all 
select 'cornell_roster' as team, count(1) as numdraft  from ncaahockey2026.cornell_roster r WHERE r.nhl_draft != '' union all 
select 'dartmouth_roster' as team, count(1) as numdraft  from ncaahockey2026.dartmouth_roster r WHERE r.nhl_draft != '' union all 
select 'denver_roster' as team, count(1) as numdraft  from ncaahockey2026.denver_roster r WHERE r.nhl_draft != '' union all 
select 'ferris_state_roster' as team, count(1) as numdraft  from ncaahockey2026.ferris_state_roster r WHERE r.nhl_draft != '' union all 
select 'harvard_roster' as team, count(1) as numdraft  from ncaahockey2026.harvard_roster r WHERE r.nhl_draft != '' union all 
select 'holy_cross_roster' as team, count(1) as numdraft  from ncaahockey2026.holy_cross_roster r WHERE r.nhl_draft != '' union all 
select 'lake_superior_state_roster' as team, count(1) as numdraft  from ncaahockey2026.lake_superior_state_roster r WHERE r.nhl_draft != '' union all 
select 'lindenwood_roster' as team, count(1) as numdraft  from ncaahockey2026.lindenwood_roster r WHERE r.nhl_draft != '' union all 
select 'long_island_roster' as team, count(1) as numdraft  from ncaahockey2026.long_island_roster r WHERE r.nhl_draft != '' union all 
select 'maine_roster' as team, count(1) as numdraft  from ncaahockey2026.maine_roster r WHERE r.nhl_draft != '' union all 
select 'massachusetts_roster' as team, count(1) as numdraft  from ncaahockey2026.massachusetts_roster r WHERE r.nhl_draft != '' union all 
select 'mercyhurst_roster' as team, count(1) as numdraft  from ncaahockey2026.mercyhurst_roster r WHERE r.nhl_draft != '' union all 
select 'merrimack_roster' as team, count(1) as numdraft  from ncaahockey2026.merrimack_roster r WHERE r.nhl_draft != '' union all 
select 'miami_roster' as team, count(1) as numdraft  from ncaahockey2026.miami_roster r WHERE r.nhl_draft != '' union all 
select 'michigan_roster' as team, count(1) as numdraft  from ncaahockey2026.michigan_roster r WHERE r.nhl_draft != '' union all 
select 'michigan_state_roster' as team, count(1) as numdraft  from ncaahockey2026.michigan_state_roster r WHERE r.nhl_draft != '' union all 
select 'michigan_tech_roster' as team, count(1) as numdraft  from ncaahockey2026.michigan_tech_roster r WHERE r.nhl_draft != '' union all 
select 'minnesota_duluth_roster' as team, count(1) as numdraft  from ncaahockey2026.minnesota_duluth_roster r WHERE r.nhl_draft != '' union all 
select 'minnesota_roster' as team, count(1) as numdraft  from ncaahockey2026.minnesota_roster r WHERE r.nhl_draft != '' union all 
select 'minnesota_state_roster' as team, count(1) as numdraft  from ncaahockey2026.minnesota_state_roster r WHERE r.nhl_draft != '' union all 
select 'new_hampshire_roster' as team, count(1) as numdraft  from ncaahockey2026.new_hampshire_roster r WHERE r.nhl_draft != '' union all 
select 'niagara_roster' as team, count(1) as numdraft  from ncaahockey2026.niagara_roster r WHERE r.nhl_draft != '' union all 
select 'north_dakota_roster' as team, count(1) as numdraft  from ncaahockey2026.north_dakota_roster r WHERE r.nhl_draft != '' union all 
select 'northeastern_roster' as team, count(1) as numdraft  from ncaahockey2026.northeastern_roster r WHERE r.nhl_draft != '' union all 
select 'northern_michigan_roster' as team, count(1) as numdraft  from ncaahockey2026.northern_michigan_roster r WHERE r.nhl_draft != '' union all 
select 'notre_dame_roster' as team, count(1) as numdraft  from ncaahockey2026.notre_dame_roster r WHERE r.nhl_draft != '' union all 
select 'ohio_state_roster' as team, count(1) as numdraft  from ncaahockey2026.ohio_state_roster r WHERE r.nhl_draft != '' union all 
select 'omaha_roster' as team, count(1) as numdraft  from ncaahockey2026.omaha_roster r WHERE r.nhl_draft != '' union all 
select 'penn_state_roster' as team, count(1) as numdraft  from ncaahockey2026.penn_state_roster r WHERE r.nhl_draft != '' union all 
select 'princeton_roster' as team, count(1) as numdraft  from ncaahockey2026.princeton_roster r WHERE r.nhl_draft != '' union all 
select 'providence_roster' as team, count(1) as numdraft  from ncaahockey2026.providence_roster r WHERE r.nhl_draft != '' union all 
select 'quinnipiac_roster' as team, count(1) as numdraft  from ncaahockey2026.quinnipiac_roster r WHERE r.nhl_draft != '' union all 
select 'rit_roster' as team, count(1) as numdraft  from ncaahockey2026.rit_roster r WHERE r.nhl_draft != '' union all 
select 'robert_morris_roster' as team, count(1) as numdraft  from ncaahockey2026.robert_morris_roster r WHERE r.nhl_draft != '' union all 
select 'rpi_roster' as team, count(1) as numdraft  from ncaahockey2026.rpi_roster r WHERE r.nhl_draft != '' union all 
select 'sacred_heart_roster' as team, count(1) as numdraft  from ncaahockey2026.sacred_heart_roster r WHERE r.nhl_draft != '' union all 
select 'st__cloud_state_roster' as team, count(1) as numdraft  from ncaahockey2026.st__cloud_state_roster r WHERE r.nhl_draft != '' union all 
select 'st__lawrence_roster' as team, count(1) as numdraft  from ncaahockey2026.st__lawrence_roster r WHERE r.nhl_draft != '' union all 
select 'st__thomas_roster' as team, count(1) as numdraft  from ncaahockey2026.st__thomas_roster r WHERE r.nhl_draft != '' union all 
select 'stonehill_roster' as team, count(1) as numdraft  from ncaahockey2026.stonehill_roster r WHERE r.nhl_draft != '' union all 
select 'uconn_roster' as team, count(1) as numdraft  from ncaahockey2026.uconn_roster r WHERE r.nhl_draft != '' union all 
select 'umass_lowell_roster' as team, count(1) as numdraft  from ncaahockey2026.umass_lowell_roster r WHERE r.nhl_draft != '' union all 
select 'union_roster' as team, count(1) as numdraft  from ncaahockey2026.union_roster r WHERE r.nhl_draft != '' union all 
select 'vermont_roster' as team, count(1) as numdraft  from ncaahockey2026.vermont_roster r WHERE r.nhl_draft != '' union all 
select 'western_michigan_roster' as team, count(1) as numdraft  from ncaahockey2026.western_michigan_roster r WHERE r.nhl_draft != '' union all 
select 'wisconsin_roster' as team, count(1) as numdraft  from ncaahockey2026.wisconsin_roster r WHERE r.nhl_draft != '' union all 
select 'yale_roster' as team, count(1) as numdraft  from ncaahockey2026.yale_roster r WHERE r.nhl_draft !='';

commit;

SQL Error [42804]: ERROR: argument of IS TRUE must be type boolean, not type text
  Position: 447


select * from information_schema.columns where column_name = 'nhl_draft' and table_schema = 'ncaahockey2026';



alter table ncaahockey2026.air_force_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.alaska_anchorage_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.alaska_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.army_west_point_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.augustana_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.bentley_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.brown_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.ferris_state_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.holy_cross_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.lindenwood_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.mercyhurst_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.niagara_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.princeton_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.rit_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.rpi_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.st__lawrence_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.stonehill_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.union_roster ALTER COLUMN nhl_draft TYPE text;
alter table ncaahockey2026.yale_roster ALTER COLUMN nhl_draft TYPE text;

select * from ncaahockey2026.blocks;
select * from ncaahockey2026.faceoff_win_percentage;
select * from ncaahockey2026.nhl_draft_counts;
select * from ncaahockey2026.nhl_draftees;
select * from ncaahockey2026.penalty_killing_percentage;
select * from ncaahockey2026.power_play_percentage;
select * from ncaahockey2026.scoring_defense;
select * from ncaahockey2026.scoring_margin;
select * from ncaahockey2026.scoring_offense;
select * from ncaahockey2026.team_penalty_minutes_per_game;
select * from ncaahockey2026.team_short_handed_goals;
select * from ncaahockey2026.winning_percentage;





SELECT a.team,h.gm, k.players
,(fo_pct / max(fo_pct) over () ) * 0.05 + (pen_kill_pct / max(pen_kill_pct) over ()) * 0.1 + (pp_pct / max(pp_pct)over ()) * 0.1 
+  score_def_avg / max(score_def_avg) over ()  * 0.1
+ "margin"/max("margin")over () * 0.15 
+ off_score_avg / max(off_score_avg)over () * 0.2
+ team_pen_min_avg / max(team_pen_min_avg) over () * 0.05
+ win_pct/max(win_pct)over ()* 0.2
+ NVL(players / max(players) over () * .125, 0)
as composite


select a.team,a.numdraft, b."Blocks",fwp."FO.won",pk."Pct.", pp."Pct.", sd."Avg.", sm."Margin", so."Avg.", penaltypg."Avg.", shg."SHG", wp."Pct."
from  ncaahockey2026.nhl_draft_counts a
join ncaahockey2026.blocks b  on team = Team
join ncaahockey2026.faceoff_win_percentage fwp  on team = Team
join ncaahockey2026.penalty_killing_percentage pk  on team = Team
join ncaahockey2026.power_play_percentage pp  on team = Team
join ncaahockey2026.scoring_defense sd  on team = Team
join ncaahockey2026.scoring_margin sm on team = Team
join ncaahockey2026.scoring_offense so on team = Team
join ncaahockey2026.team_penalty_minutes_per_game penaltypg  on team = Team
join ncaahockey2026.team_short_handed_goals shg on team = Team
join ncaahockey2026.winning_percentage wp on team = Team
group by 1,2,3,4,5,6,7,8,9,10,11,12;


create table ncaahockey2026.composite_stage 
AS
SELECT
    -- a."team",
 wp."Team",
    a.numdraft, 
    b."Blocks",
    fwp."FO.won",
    pk."Pct." AS penalty_kill_pct,
    pp."Pct." AS power_play_pct,
    sd."Avg." AS scoring_defense_avg,
    sm."Margin" AS scoring_margin,
    so."Avg." AS scoring_offense_avg,
    penaltypg."Avg." AS penalty_minutes_avg,
    shg."SHG" AS short_handed_goals,
    wp."Pct." AS winning_pct
FROM ncaahockey2026.winning_percentage wp 
LEFT JOIN ncaahockey2026.faceoff_win_percentage fwp ON  wp."Team"= fwp."Team"
LEFT JOIN ncaahockey2026.penalty_killing_percentage pk ON wp."Team"= pk."Team"
LEFT JOIN ncaahockey2026.power_play_percentage pp ON  wp."Team" = pp."Team"
LEFT JOIN ncaahockey2026.scoring_defense sd ON  wp."Team" = sd."Team"
LEFT JOIN ncaahockey2026.scoring_margin sm ON  wp."Team" = sm."Team"
LEFT JOIN ncaahockey2026.scoring_offense so ON  wp."Team" = so."Team"
LEFT JOIN ncaahockey2026.team_penalty_minutes_per_game penaltypg ON  wp."Team"= penaltypg."Team"
LEFT JOIN ncaahockey2026.team_short_handed_goals shg ON  wp."Team"= shg."Team"
LEFT JOIN ncaahockey2026.blocks b on  wp."Team" = b."Team"
LEFT JOIN  ncaahockey2026.nhl_draft_counts a  ON wp."Team" = a."team" ;

select * from ncaahockey2026.composite_stage ;



SELECT 
    a."team",
    a.numdraft, 
    b."Blocks"
FROM ncaahockey2026.nhl_draft_counts a
LEFT JOIN ncaahockey2026.blocks b ON a.team = b."Team"


SELECT 
    a."team",
    a.numdraft, 
    b."Team",
    b."Blocks"
    
select * , TRIM(LOWER(b."Team"))  FROM ncaahockey2026.nhl_draft_counts a LEFT JOIN ncaahockey2026.blocks b     ON TRIM(LOWER(a."team")) = TRIM(LOWER(b."Team"));
SQL Error [42601]: ERROR: syntax error at or near "a"
  Position: 72

truncate table ncaahockey2026.nhl_draft_counts;
select * from  ncaahockey2026.nhl_draft_counts; 


insert into ncaahockey2026.nhl_draft_counts (team, numdraft)
values
('Air Force',0),
('Alas. Anchorage',0),
('Alas. Fairbanks',0),
('Arizona St.',5),
('Army West Point',0),
('Augustana (SD)',0),
('Bemidji St.', 1),
('Bentley', 0),
('Boston College',12),
('Boston U.',18),
('Bowling Green',1),
('Brown',0),
('Canisius',1),
('Clarkson',1),
('Colgate',1),
('Colorado Col.',10),
('Cornell',9),
('Dartmouth',1),
('Denver',14),
('Ferris St.',0),
('Harvard',10),
('Holy Cross',0),
('Lake Superior St.',1),
('Lindenwood',0),
('LIU',1),
('Maine',5),
('Massachusetts',7),
('Mercyhurst',0),
('Merrimack',3),
('Miami (OH)',3),
('Michigan',13),
('Michigan St.',15),
('Michigan Tech',2),
('Minn. Duluth',7),
('Minnesota',13),
('Minnesota St.',1),
('New Hampshire',3),
('Niagara',0),
('North Dakota',11),
('Northeastern',4),
('Northern Mich.',1),
('Notre Dame',8),
('Ohio St.',2),
('Omaha',3),
('Penn St.',7),
('Princeton',0),
('Providence',7),
('Quinnipiac',5),
('Rensselaer',0),
('RIT',1),
('Robert Morris',0),
('Sacred Heart',1),
('St. Cloud St.',6),
('St. Lawrence',0),
('St. Thomas (MN)',4),
('Stonehill',0),
('UConn',6),
('UMass Lowell',3),
('Union (NY)',0),
('Vermont',2),
('Western Mich.',10),
('Wisconsin',10),
('Yale',0);


ALTER TABLE ncaahockey2026.composite_stage RENAME COLUMN "FO.won" TO faceoffs_won;
ALTER TABLE ncaahockey2026.composite_stage RENAME COLUMN "Team" TO team;
ALTER TABLE ncaahockey2026.composite_stage RENAME COLUMN "Blocks" TO blocks;

SELECT
team,
numdraft,
blocks,
faceoffs_won,
penalty_kill_pct,
power_play_pct,
scoring_defense_avg,
scoring_margin,
scoring_offense_avg,
penalty_minutes_avg,
short_handed_goals,
winning_pct
from ncaahockey2026.composite_stage c;



SQL Error [42883]: ERROR: function nvl(bigint, numeric, integer) does not exist
  Hint: No function matches the given name and argument types. You might need to add explicit type casts.
  Position: 193


SELECT
    team,
    numdraft,
    blocks,
    faceoffs_won,
    penalty_kill_pct,
    power_play_pct,
    scoring_defense_avg,
    scoring_margin,
    scoring_offense_avg,
    penalty_minutes_avg,
    short_handed_goals,
    winning_pct,

    -- Fixed Calculation
    COALESCE(numdraft, 0) * 0.125 + 
    COALESCE(faceoffs_won, 0) * 0.05 + 
    COALESCE(penalty_kill_pct, 0) * 0.1 + 
    COALESCE(power_play_pct, 0) * 0.1 + 
    COALESCE(scoring_defense_avg, 0) * 0.1 + 
    COALESCE(scoring_margin, 0) * 0.15 + 
    COALESCE(scoring_offense_avg, 0) * 0.2 + 
    COALESCE(penalty_minutes_avg, 0) * 0.05 +  
    COALESCE(winning_pct, 0) * 0.2 AS composite_score

FROM ncaahockey2026.composite_stage
order by composite_score desc;

SELECT
    team,
    numdraft,
    blocks,
    faceoffs_won,
    penalty_kill_pct,
    power_play_pct,
    scoring_defense_avg,
    scoring_margin,
    scoring_offense_avg,
    penalty_minutes_avg,
    short_handed_goals,
    winning_pct,
       COALESCE(penalty_minutes_avg, 0) * 0.05 * (-1) as corr_pen_min_avg,
          COALESCE(scoring_defense_avg, 0) * 0.1 * (-1) as scoring_def_avg,

    -- Fixed Calculation
    COALESCE(numdraft, 0) * 0.125 + 
    COALESCE(faceoffs_won, 0) * 0.05 + 
    COALESCE(penalty_kill_pct, 0) * 0.1 + 
    COALESCE(power_play_pct, 0) * 0.1 + 
    COALESCE(scoring_defense_avg, 0) * 0.1 * (-1) + 
    COALESCE(scoring_margin, 0) * 0.15 + 
    COALESCE(scoring_offense_avg, 0) * 0.2 + 
    COALESCE(penalty_minutes_avg, 0) * 0.05 * (-1) +  
    COALESCE(winning_pct, 0) * 0.2 AS composite_score

FROM ncaahockey2026.composite_stage
order by composite_score desc;

drop table  ncaahockey2026.composite2026schedule;

CREATE TABLE ncaahockey2026.composite2026schedule
(
Week integer,
Day varchar,
Date  date,
Time varchar,
Opponent varchar,
OppScore integer,
AT varchar,
Home varchar,
Score integer,
OT varchar,
Notes varchar,
Type varchar,
Summary varchar,
Location varchar,
TV1 varchar,
TV2 varchar,
TV3 varchar
);

select * from ncaahockey2026.composite2026schedule where week = 17;
select * from ncaahockey2026.npi_ranking;

create table ncaahockey2026.composite_ranking
as
SELECT
    team,
    numdraft,
    blocks,
    faceoffs_won,
    penalty_kill_pct,
    power_play_pct,
    scoring_defense_avg,
    scoring_margin,
    scoring_offense_avg,
    penalty_minutes_avg,
    short_handed_goals,
    winning_pct,
       COALESCE(penalty_minutes_avg, 0) * 0.05 * (-1) as corr_pen_min_avg,
          COALESCE(scoring_defense_avg, 0) * 0.1 * (-1) as scoring_def_avg,

    -- Fixed Calculation
    COALESCE(numdraft, 0) * 0.125 + 
    COALESCE(faceoffs_won, 0) * 0.05 + 
    COALESCE(penalty_kill_pct, 0) * 0.1 + 
    COALESCE(power_play_pct, 0) * 0.1 + 
    COALESCE(scoring_defense_avg, 0) * 0.1 * (-1) + 
    COALESCE(scoring_margin, 0) * 0.15 + 
    COALESCE(scoring_offense_avg, 0) * 0.2 + 
    COALESCE(penalty_minutes_avg, 0) * 0.05 * (-1) +  
    COALESCE(winning_pct, 0) * 0.2 AS composite_score

FROM ncaahockey2026.composite_stage
order by composite_score desc;



select c.team, c.composite_score, nr.* 
from ncaahockey2026.composite_ranking c
join ncaahockey2026.npi_ranking nr 
using(team);


select * from  ncaahockey2026.composite_ranking
select * from ncaahockey2026.npi_ranking

select * from ncaahockey2026.air_force_schedule

select *
FROM information_schema.tables 
where  table_schema ilike 'ncaahockey2026' and table_name not ilike '%_roster' and table_name not ilike '%_stats_table%' and table_name not ilike '%_schedule'
;

select * from  ncaahockey2026.composite_sched_2026;


select "Home", "Opponent", count(1) from ncaahockey2026.composite_sched_2026 group by 1,2;

select * from ncaahockey2026.composite_sched_2026 where "Week" = 17;
select * from ncaahockey2026.nhl_draft_counts;
select * from ncaahockey2026.composite_ranking order by team;

Air Force
Alas. Anchorage
Alas. Fairbanks
Arizona St.
Army West Point
Augustana (SD)
Bemidji St.
Bentley
Boston College
Boston U.
Bowling Green
Brown
Canisius
Clarkson
Colgate
Colorado Col.
Cornell
Dartmouth
Denver
Ferris St.
Harvard
Holy Cross
Lake Superior St.
Lindenwood
LIU
Maine
Massachusetts
Mercyhurst
Merrimack
Miami (OH)
Michigan
Michigan St.
Michigan Tech
Minn. Duluth
Minnesota
Minnesota St.
New Hampshire
Niagara
North Dakota
Northeastern
Northern Mich.
Notre Dame
Ohio St.
Omaha
Penn St.
Princeton
Providence
Quinnipiac
Rensselaer
RIT
Robert Morris
Sacred Heart
St. Cloud St.
St. Lawrence
Stonehill
St. Thomas (MN)
UConn
UMass Lowell
Union (NY)
Vermont
Western Mich.
Wisconsin
Yale



SELECT 
  "Home",
  TRIM(
    REGEXP_REPLACE(
      "Home", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name,
    "Opponent",
  TRIM(
    REGEXP_REPLACE(
      "Opponent", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_opponent_team_name
FROM ncaahockey2026.composite_sched_2026;


select * from ncaahockey2026.composite_ranking order by team








select *, TRIM(
    REGEXP_REPLACE(
      "team", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name 
from 
ncaahockey2026.composite_ranking 
order by team


(
SELECT 
  "Home",
  TRIM(
    REGEXP_REPLACE(
      "Home", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name,
    "Opponent",
  TRIM(
    REGEXP_REPLACE(
      "Opponent", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_opponent_team_name
FROM ncaahockey2026.composite_sched_2026
order by clean_home_team_name
) a





SELECT 
  
  TRIM(
    REGEXP_REPLACE(
      "Home", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name,
  
  TRIM(
    REGEXP_REPLACE(
      "Opponent", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_opponent_team_name,
  count(1)
FROM ncaahockey2026.composite_sched_2026
group by 1,2
order by clean_home_team_name;












select 
  TRIM(
    REGEXP_REPLACE(
      "team", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name,team
from ncaahockey2026.composite_ranking order by team;



select clean_home_team_name, clean_opponent_team_name from (

SELECT 
  "Home",
  TRIM(
    REGEXP_REPLACE(
      "Home", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name,
    "Opponent",
  TRIM(
    REGEXP_REPLACE(
      "Opponent", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_opponent_team_name
FROM ncaahockey2026.composite_sched_2026 
where (
TRIM(
    REGEXP_REPLACE(
      "Home", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) ) ilike '%State%' 
  and   
  (TRIM(
    REGEXP_REPLACE(
      "Opponent", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  )    ilike '%State%')
group by 1,2,3,4

order by clean_home_team_name

)a 
group by clean_home_team_name,clean_opponent_team_name




select  
"Home", "Opponent"
FROM ncaahockey2026.composite_sched_2026 where "Home"    ilike '%State%' or    "Opponent" ilike '%State%'
group by 1,2


select * from ncaahockey2026.composite_ranking order by team

ALTER TABLE ncaahockey2026.composite_ranking 
ADD COLUMN clean_team_name VARCHAR(100);






select team,
  TRIM(
    REGEXP_REPLACE(
      "team", 
      '^(\w+)[^\.]\s+(\w+)[^\(|\.]+', 
      '\2'
    )
  ) 
  from ncaahockey2026.composite_ranking order by team;
  
 

select 
  TRIM(
    REGEXP_REPLACE(
      "team", 
      '^(\(\d+\)\s+)?(.+?)\s+\(\d+-\d+-\d+\)$', 
      '\2'
    )
  ) AS clean_home_team_name,team
from ncaahockey2026.composite_ranking order by team;


-- =====================================================================

commit;

select * from ncaahockey2026.composite_ranking order by team;

update ncaahockey2026.composite_ranking
set clean_team_name= 'Arizona State'
where team = 'Arizona St.';
 

update ncaahockey2026.composite_ranking
set clean_team_name= 'Alaska Anchorage'
where team = 'Alas. Anchorage' ; 


update ncaahockey2026.composite_ranking
set clean_team_name= 'Alaska Fairbanks'
where team = 'Alas. Fairbanks' ; 
  

update ncaahockey2026.composite_ranking
set clean_team_name= 'Minn Duluth'
where team = 'Minn. Duluth';
 

update ncaahockey2026.composite_ranking
set clean_team_name= 'St Lawrence'
where team = 'St. Lawrence' ; 


  update ncaahockey2026.composite_ranking
set clean_team_name= 'St Thomas'
where team = 'St. Thomas (MN)';
 
-- ========================================================================================

update ncaahockey2026.composite_ranking
set clean_team_name= 'Bemidji State'
where team = 'Bemidji St.';
 
update ncaahockey2026.composite_ranking
set clean_team_name= 'Ferris State'
where team = 'Ferris St.' ; 

update ncaahockey2026.composite_ranking
set clean_team_name= 'Michigan State'
where team = 'Michigan St.' ; 

update ncaahockey2026.composite_ranking
set clean_team_name= 'Ohio State'
where team = 'Ohio St.' ; 

update ncaahockey2026.composite_ranking
set clean_team_name= 'Penn State'
where team = 'Penn State';

update ncaahockey2026.composite_ranking
set clean_team_name= 'St. Cloud State'
where team = 'St. Cloud St.';




select * from  ncaahockey2026.composite_sched_2026

select * from ncaahockey2026.composite_ranking;

select * from  ncaahockey2026.composite_sched_2026 where "Week" = 17;

create table ncaahockey2026.week17_games 
as
select * from  ncaahockey2026.composite_sched_2026 where "Week" = 17;

ALTER TABLE ncaahockey2026.week17_games  ADD COLUMN home_clean_name varchar(100);
ALTER TABLE ncaahockey2026.week17_games  ADD COLUMN opponent_clean_name varchar(100);
select * from  ncaahockey2026.week17_games; 

CREATE TABLE ncaahockey2026.full_team_names (
  team VARCHAR(100)
);

COPY ncaahockey2026.full_team_names
FROM '/home/jack/Documents/ice_hockey/hockey2026/full_team_names.ods'
WITH (FORMAT csv, HEADER true, DELIMITER ',');



select * from pg_stat_statements;
SQL Error [42P01]: ERROR: relation "pg_stat_statements" does not exist
  Position: 15

SHOW shared_preload_libraries;

CREATE EXTENSION pg_stat_statements;
SELECT * FROM pg_stat_statements LIMIT 5;

SHOW shared_preload_libraries;

SHOW config_file;

select * from cfb2026.games
where week =2

select t.school, g.game_id, max(g.week) week, max(r.elo_rating) h_elo, max(r.fpi_rating) h_fpi, max(r.fpi_offense) h_fpi_off, max(r.fpi_defense) h_fpi_def,-- max(r.pulled_at) h_pulled_at,  
t2.school,  max(r2.elo_rating) a_elo, max(r2.fpi_rating) a_fpi, max(r2.fpi_offense) a_fpi_off, max(r2.fpi_defense) a_fpi_def, -- max(r2.pulled_at) a_pulled_at,
max(r.elo_rating) - max(r2.elo_rating)    as elo_delta,      max(r.fpi_rating)  -    max(r2.fpi_rating)  as fpi_delta,

from cfb2026.games g
left join cfb2026.team_week_ratings r on (g.home_team_id = r.team_id)
left join cfb2026.team_week_ratings r2 on (g.away_team_id = r2.team_id) 
left join cfb2026.teams t on (g.home_team_id = t.team_id)
left join cfb2026.teams t2 on (g.away_team_id = t2.team_id)

where g.week = 3 -- and t.school = t2.school
group by t.school, g.game_id, t2.school
order by t.school


select week, count(1)  from cfb2026.games g where completed = true group by week


SELECT current_setting('search_path');

SELECT
    schemaname,
    relname AS table_name,
    n_live_tup AS live_tuples,
    n_dead_tup AS dead_tuples,
    ROUND((n_dead_tup::float / NULLIF(n_live_tup + n_dead_tup, 0)) * 100, 2) AS dead_tuple_percent,
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY dead_tuples DESC;


SELECT count(1)
FROM cfb2026.games;


SELECT count(1)
FROM cfb2026.teams;

team_id

SELECT distinct count(team_id)
FROM cfb2026.teams;



select * from pg_stat_activity order by query_start desc;

select * from pg_stat_activity order by query_start desc;

select * from pg_stat_statements
select * from pg_attribute 
select * from pg_stat_statements  where query ilike '%tmp_%' ;
select * from pg_stat_statements  where query ilike '%ON CONFLICT%';

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = pg_my_temp_schema()::regnamespace::text;

SELECT schemaname, tablename, tableowner 
FROM pg_tables 
WHERE schemaname = pg_my_temp_schema()::regnamespace::text;

SELECT * FROM pg_namespace

SELECT a.attname AS column_name, format_type(a.atttypid, a.atttypmod) AS data_type
     FROM pg_attribute a
     WHERE a.attrelid = '{table}'::regclass AND a.attnum > 0 AND NOT a.attisdropped
       AND a.attname IN ({paste(sprintf(\"'%s'\", colnames(df)), collapse = ', ')});

SELECT * FROM information_schema.tables

SELECT table_catalog, table_schema, count(1)  FROM information_schema.tables group by table_catalog, table_schema


SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = pg_my_temp_schema()::regnamespace::text;
.h

select t.school, h.* from cfb2026.teams t join cfb2026.v_team_play_history h using (team_id)
order by school

select * from cfb2026.v_team_play_history;

select t.school, t.conference, t.division, t.classification, gts.* from 
(
SELECT s.team_id,
    g.season,
    g.week,
    sum(s.offensive_plays) OVER (PARTITION BY s.team_id, g.season ORDER BY g.week) AS cumulative_plays_through_week,
    count(*) OVER (PARTITION BY s.team_id, g.season ORDER BY g.week) AS like_to_like_games_through_week
   FROM cfb2026.game_team_stats s
     JOIN cfb2026.games g ON g.game_id = s.game_id
     JOIN cfb2026.v_games_tiered gt ON gt.game_id = g.game_id
     ) gts
     join cfb2026.teams t 
     using (team_id)
     
     


SELECT *
FROM information_schema.tables 
WHERE table_schema = 'cfb2026';

SELECT 
    schemaname,
    relname AS table_name,
    n_tup_ins AS rows_inserted,
    n_tup_upd AS rows_updated,
    n_tup_del AS rows_deleted,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'your_schema_name'
ORDER BY relname;


SELECT 
  *
FROM pg_stat_user_tables
WHERE schemaname = 'cfb2026'
ORDER BY relname;


SELECT * FROM cfb2026.v_game_features WHERE actual_spread IS NOT NULL;

select * from cfb2026.v_game_features;

SELECT *
FROM information_schema.columns
WHERE column_name = 'vegas_spread'
ORDER BY table_schema, table_name;

select * from cfb2026.betting_lines;

SELECT * FROM cfb2026.v_game_features f 
join (select game_id, max(provider), max(spread), min(spread), min(over_under), max(over_under), max(pulled_at)  from cfb2026.betting_lines group by game_id order by game_id) b
using (game_id)
WHERE actual_spread IS NOT NULL;

SELECT b.spread,
            b.over_under
           FROM cfb2026.betting_lines b
          WHERE -- b.game_id = g.game_id AND 
          b.provider = 'consensus'::text
          ORDER BY b.pulled_at DESC
         LIMIT 1
         
         

SELECT 
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE column_name = 'your_column_name'
ORDER BY table_schema, table_name;

select game_id, count(1) from (

drop view cfb2026.v_game_features

CREATE OR REPLACE VIEW cfb2026.v_game_features
AS 
 SELECT g.game_id,
    g.season,
    g.week,
    g.start_date,
    g.neutral_site,
    g.conference_game,
    g.home_team_id,
    ht.school AS home_school,
    vt_h.tier AS home_tier,
    g.away_team_id,
    at.school AS away_school,
    vt_a.tier AS away_tier,
    vt_h.tier IS NOT NULL AND vt_h.tier = vt_a.tier AS like_to_like,
    g.home_points,
    g.away_points,
    g.home_points - g.away_points AS actual_spread,
    hr.elo_rating AS home_elo,
    ar.elo_rating AS away_elo,
    hr.fpi_rating AS home_fpi,
    ar.fpi_rating AS away_fpi,
    hr.sp_plus_rating AS home_sp_plus,
    ar.sp_plus_rating AS away_sp_plus,
    bl.spread AS vegas_spread,
    bl.over_under AS vegas_total
   FROM cfb2026.games g
     JOIN cfb2026.teams ht ON ht.team_id = g.home_team_id
     JOIN cfb2026.teams at ON at.team_id = g.away_team_id
     JOIN cfb2026.v_team_tier vt_h ON vt_h.team_id = g.home_team_id
     JOIN cfb2026.v_team_tier vt_a ON vt_a.team_id = g.away_team_id
     LEFT JOIN cfb2026.team_week_ratings hr ON hr.team_id = g.home_team_id AND hr.season = g.season AND hr.week = g.week
     LEFT JOIN cfb2026.team_week_ratings ar ON ar.team_id = g.away_team_id AND ar.season = g.season AND ar.week = g.week
     LEFT JOIN LATERAL ( SELECT max(b.spread) as spread,
            max(b.over_under) as over_under
           FROM cfb2026.betting_lines b
          WHERE b.game_id = g.game_id AND b.provider = 'DraftKings'::text
           group by pulled_at
          ORDER BY b.pulled_at desc
          LIMIT 1
        ) bl ON true;
 
        
        
        
        
) a
group by game_id;


 
 
 
 
SELECT provider, COUNT(*) 
FROM cfb2026.betting_lines 
GROUP BY provider 
ORDER BY COUNT(*) DESC;


 
select*
FROM cfb2026.betting_lines 
where provider = 'DraftKings'

select*
FROM cfb2026.betting_lines 
where provider = 'Draft Kings'

select*
FROM cfb2026.betting_lines 
where provider = 'Bovada'






SELECT g.season, g.week, g.start_date, gt.like_to_like, gt.home_tier, gt.away_tier,
         s.team_id, s.opponent_id, s.is_home,
         s.points,
         -- atomic-grain rate stats: already (sum over scrimmage plays) /
         -- (count of scrimmage plays), so a 60-play and a 100-play team are
         -- directly comparable here without any further normalization.
         s.offensive_plays, s.yards_per_play, s.epa_per_play, s.success_rate, s.explosiveness,
         s.offensive_plays_ex_garbage, s.yards_per_play_ex_garbage,
         s.epa_per_play_ex_garbage, s.success_rate_ex_garbage,
         s.turnovers, s.third_down_pct,
         r.elo_rating, r.fpi_rating, r.sp_plus_rating
  FROM cfb2026.game_team_stats s
  JOIN cfb2026.games g ON g.game_id = s.game_id
  JOIN cfb2026.v_games_tiered gt ON gt.game_id = g.game_id
  LEFT JOIN cfb2026.team_week_ratings r ON r.team_id = s.team_id AND r.season = g.season AND r.week = g.week
  ORDER BY s.team_id, g.season, g.week;


SELECT t.school, c.* FROM cfb2026.v_team_like_to_like_counts c
join cfb2026.teams t using(team_id);


select * from cfb2026.teams
order by school;

select * from cfb2026.games where home_team_id = 344 or away_team_id = 344;



SELECT * FROM cfb2026.v_team_like_to_like_counts order by team_id


CREATE OR REPLACE VIEW cfb2026.v_games_tiered AS
SELECT 
    g.game_id,
    g.season,
    g.week,
    g.start_date,
    g.home_team_id,
    g.away_team_id,
    vt_h.tier AS home_tier,
    vt_a.tier AS away_tier,
    -- Evaluates TRUE for any P4 vs P4 (e.g., SEC vs Big Ten) or G5 vs G5 matchup
    (vt_h.tier IS NOT NULL AND vt_a.tier IS NOT NULL AND vt_h.tier = vt_a.tier) AS like_to_like
FROM cfb2026.games g
LEFT JOIN cfb2026.v_team_tier vt_h ON vt_h.team_id = g.home_team_id
LEFT JOIN cfb2026.v_team_tier vt_a ON vt_a.team_id = g.away_team_id;








drop view  cfb2026.v_games_tiered cascade;

CREATE OR REPLACE VIEW cfb2026.v_games_tiered AS
SELECT 
    g.game_id,
    g.season,
    g.week,
    g.start_date,
    g.home_team_id,
    g.away_team_id,
    vt_h.tier AS home_tier,
    vt_a.tier AS away_tier,
    -- Evaluates TRUE for any P4 vs P4 (e.g., SEC vs Big Ten) or G5 vs G5 matchup
    (vt_h.tier IS NOT NULL AND vt_a.tier IS NOT NULL AND vt_h.tier = vt_a.tier) AS like_to_like
FROM cfb2026.games g
LEFT JOIN cfb2026.v_team_tier vt_h ON vt_h.team_id = g.home_team_id
LEFT JOIN cfb2026.v_team_tier vt_a ON vt_a.team_id = g.away_team_id;


-- fb2026.v_team_play_history 

-- cfb2026.v_team_play_history source

CREATE OR REPLACE VIEW cfb2026.v_team_play_history
AS SELECT s.team_id,
    g.season,
    g.week,
    sum(s.offensive_plays) OVER (PARTITION BY s.team_id, g.season ORDER BY g.week) AS cumulative_plays_through_week,
    count(*) OVER (PARTITION BY s.team_id, g.season ORDER BY g.week) AS like_to_like_games_through_week
   FROM cfb2026.game_team_stats s
     JOIN cfb2026.games g ON g.game_id = s.game_id
     JOIN cfb2026.v_games_tiered gt ON gt.game_id = g.game_id
  WHERE gt.like_to_like AND g.completed;


-- cfb2026.v_team_like_to_like_counts

-- cfb2026.v_team_like_to_like_counts source

CREATE OR REPLACE VIEW cfb2026.v_team_like_to_like_counts
AS SELECT t.team_id,
    COALESCE(c.like_to_like_games_played, 0::bigint) AS like_to_like_games_played
   FROM cfb2026.teams t
     LEFT JOIN ( SELECT s.team_id,
            count(*) AS like_to_like_games_played
           FROM cfb2026.game_team_stats s
             JOIN cfb2026.v_games_tiered gt ON gt.game_id = s.game_id
          WHERE gt.like_to_like
          GROUP BY s.team_id) c ON c.team_id = t.team_id
  WHERE t.classification = 'fbs'::text;


SELECT g.season, g.week, g.start_date, gt.like_to_like, gt.home_tier, gt.away_tier,
         s.team_id, s.opponent_id, s.is_home,
         s.points,
         s.offensive_plays, s.yards_per_play, s.epa_per_play, s.success_rate, s.explosiveness,
         s.offensive_plays_ex_garbage, s.yards_per_play_ex_garbage,
         s.epa_per_play_ex_garbage, s.success_rate_ex_garbage,
         s.turnovers, s.third_down_pct,
         r.elo_rating, r.fpi_rating, r.sp_plus_rating
  FROM cfb2026.game_team_stats s
  JOIN cfb2026.games g ON g.game_id = s.game_id
  JOIN cfb2026.v_games_tiered gt ON gt.game_id = g.game_id
  LEFT JOIN cfb2026.team_week_ratings r ON r.team_id = s.team_id AND r.season = g.season AND r.week = g.week
  ORDER BY s.team_id, g.season, g.week;



select t.school, p.game_id, g.week, count(1)   from cfb2026.plays p
join cfb2026.teams t    on (p.offense_team_id = t.team_id)
  JOIN cfb2026.games g ON g.game_id = p.game_id
  group by t.school, p.game_id, g.week
  order by t.school, week
  
  
SELECT 
    o.school, 
    o.game_id, 
    o.week, 
    o.off_plays, 
    d.school AS def_school,  
    d.def_plays    
FROM 
    (
        SELECT 
            t.school, 
            p.game_id, 
            g.week, 
            COUNT(1) AS off_plays   
        FROM cfb2026.plays p
        JOIN cfb2026.teams t ON p.offense_team_id = t.team_id
        JOIN cfb2026.games g ON g.game_id = p.game_id
        GROUP BY t.school, p.game_id, g.week
    ) o
JOIN
    (
        SELECT 
            t.school, 
            p.game_id, 
            g.week, 
            COUNT(1) AS def_plays   
        FROM cfb2026.plays p
        JOIN cfb2026.teams t ON p.defense_team_id = t.team_id
        JOIN cfb2026.games g ON g.game_id = p.game_id
        GROUP BY t.school, p.game_id, g.week
    ) d
ON o.school = d.school 
AND o.game_id = d.game_id
ORDER BY school

off_plays desc;






  
  
select t.school, p.game_id, g.week, count(1)   from cfb2026.plays p
join cfb2026.teams ht    on (p.offense_team_id = t.team_id)
  JOIN cfb2026.games g ON g.game_id = p.game_id
  group by t.school, p.game_id, g.week  
  

select  p.* from cfb2026.plays p


  
SELECT 
    o.school as off_school, 
    o.off_plays, 
     o.off_plays / 2 as avg_off_plays,
    d.school AS def_school,   
     d.def_plays,  
    d.def_plays  / 2   as avg_def_plays
FROM 
    (
        SELECT 
            t.school, 
            COUNT(1) AS off_plays   
        FROM cfb2026.plays p
        JOIN cfb2026.teams t ON p.offense_team_id = t.team_id
        JOIN cfb2026.games g ON g.game_id = p.game_id
        GROUP BY t.school
    ) o
JOIN
    (
        SELECT 
            t.school, 
            COUNT(1) AS def_plays   
        FROM cfb2026.plays p
        JOIN cfb2026.teams t ON p.defense_team_id = t.team_id
        JOIN cfb2026.games g ON g.game_id = p.game_id
        GROUP BY t.school
    ) d
ON o.school = d.school 

ORDER BY off_plays desc;





select * from 
cfb2026.betting_lines b
join



select * from cfb2026.games g 
join (
select game_id, max(provider) as provider, max(spread) as max_spread, min(spread)as min_spread, min(over_under) as min_spead, max(over_under) as max_over_under, max(pulled_at)  
from cfb2026.betting_lines group by game_id order by game_id
) b
using (game_id)





select t.school, g.game_id, max(g.week) week, max(r.elo_rating) h_elo, max(r.fpi_rating) h_fpi, max(r.fpi_offense) h_fpi_off, max(r.fpi_defense) h_fpi_def, max(r.pulled_at) h_pulled_at,  
t2.school,  max(r2.elo_rating) a_elo, max(r2.fpi_rating) a_fpi, max(r2.fpi_offense) a_fpi_off, max(r2.fpi_defense) a_fpi_def, max(r2.pulled_at) a_pulled_at,
max(r.elo_rating) - max(r2.elo_rating)    as elo_delta,      max(r.fpi_rating)  -    max(r2.fpi_rating)  as fpi_delta
from cfb2026.games g
left join cfb2026.team_week_ratings r on (g.home_team_id = r.team_id)
left join cfb2026.team_week_ratings r2 on (g.away_team_id = r2.team_id) 
left join cfb2026.teams t on (g.home_team_id = t.team_id)
left join cfb2026.teams t2 on (g.away_team_id = t2.team_id)

where g.week = 3 -- and t.school = t2.school
group by t.school, g.game_id, t2.school
order by t.school


