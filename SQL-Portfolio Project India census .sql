select * from project.dbo.Data1
select * from project.dbo.Data2

-- number of rows in our dataset
select count(*) from project..data1
select count(*) from project..data2;

--find info about only Jharkhand and Bihar
select * from project.dbo.Data1 where state in ('Jharkhand','Bihar');
-- total population of India
select sum(population) as total_population
from project..data2

--average growth 
select avg(growth)*100 as average_growth
from project..data1

--average growth percentage by state
select state, avg(growth)*100 as average_growth
from project..data1
group by state;

--average sex-ratio
select state, round(avg(sex_ratio),0) as avg_sex_ratio
from project..data1
group by state
order by  avg_sex_ratio desc;

--average literacy rate
select state, round(avg(literacy),0) as avg_literacy
from project..data1
group by state
order by  avg_literacy desc;

--filter literacy above 90
select state, round(avg(literacy),0) as avg_literacy
from project..data1
group by state
having round(avg(literacy),0)>90
order by  avg_literacy desc

--top 3 state showing highest growth ratio
select top 3 state, avg(growth)*100 as average_growth
from project..data1
group by state
order by average_growth desc

--create a table called topstates

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstates float
  )
insert into #topstates
select state, round(avg(literacy),0) as avg_literacy
from project..data1
group by state
order by  avg_literacy desc;
select top 3 * from #topstates order by #topstates.topstates desc

--create another table called bottomstates

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstates float
  )
insert into #bottomstates
select state, round(avg(literacy),0) as avg_literacy
from project..data1
group by state
order by  avg_literacy desc;
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc

--combine the results using union operator
select * from ( select top 3 * from #topstates order by #topstates.topstates desc) as top_states
union
select * from (select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) as bottom_states

--filter states starting with letter a
select distinct state
from project..data1
where state like 'A%' or state like 'B%'

--filter states starting with a and ending with h
select distinct state
from project..data1
where state like 'A%' and  state like '%h'

--join both the tables

select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females 
from(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population 
from project..data1 a
 inner join project..data2 b
 on a.district=b.district ) c
  
 --district level male & female population
select d.state,sum(d.males) total_males ,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females 
from(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population 
from project..data1 a
 inner join project..data2 b
 on a.district=b.district ) c)d
 group by d.state

 --total literacy rate
 select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from project..data1 a 
inner join project..data2 b on a.district=b.district) d) c
group by c.state

-- -- population in previous census

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.district=b.district) d) e
group by e.state)m

-- output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rank from project..data1) a
where a.rank in (1,2,3) order by state















