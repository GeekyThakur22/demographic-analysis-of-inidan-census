select*
from [district census]

select*
from [literacy ratio]


--count number of rows into our dataset

select count(*)
from [district census]

select count(*)
from [literacy ratio]

--generate data for two different states
--a)using union
select*
from [literacy ratio]
where [State ] like '%rajasthan%'
union
select*
from [literacy ratio]
where [State ] like '%punjab%'

--b)using where 
select*
from [literacy ratio]
where [State ] in('rajasthan','punjab')

--population of india 

select SUM(population)as total_population
from [district census]


-- average growth of india
select AVG(growth)*100 as avg_growth
from [literacy ratio]

--average growth by state

select [State ],AVG(growth)*100 as avg_growth
from [literacy ratio]
where Growth is not null
group by [State ]

--avg sex ratio(using round off function)
select [State ],round(AVG(sex_ratio),0) as avg_sex_ratio
from [literacy ratio]
where Sex_Ratio is not null
group by [State ]
order by avg_sex_ratio desc

--avg literacy rate
-- a)using round function
select [State ],round(AVG(Literacy),0) as avg_literacy_ratio
from [literacy ratio]
group by [State ]
order by avg_literacy_ratio desc

--b)using having clause
select [State ],round(AVG(Literacy),0) as avg_literacy_ratio
from [literacy ratio]
group by [State ]
having round(AVG(Literacy),0)>90
order by avg_literacy_ratio desc

--- top 3 states showing highest growth ratio
select top 3 [State ],avg(Growth)*100 as highest_growth_ratio
from [literacy ratio]
where Growth is not null
group by [State ]
order by highest_growth_ratio desc

--bottom 3 states showing lowest sex ratio
select top 3 [State ],round(AVG(sex_ratio),0) as avg_sex_ratio
from [literacy ratio]
where Sex_Ratio is not null
group by [State ]
order by avg_sex_ratio 

--top states and bottom states literacy wise 

drop table if exists #topstates
create table #topstates
( state nvarchar(255),
  topstate float
  )
  insert into #topstates
  select [State ],round(AVG(Literacy),0) as avg_literacy_ratio
from [literacy ratio]
where Sex_Ratio is not null
group by [State ]
order by avg_literacy_ratio desc;

select top 3 *
from #topstates
order by #topstates.topstate

drop table if exists #bottomstates
create table #bottomstates
( state nvarchar(255),
  bottomstates float
  )
  insert into #bottomstates
  select [State ],round(AVG(Literacy),0) as avg_literacy_ratio
from [literacy ratio]
where Sex_Ratio is not null
group by [State ]
order by avg_literacy_ratio desc;

select top 3*
from #bottomstates
order by #bottomstates.bottomstates


select*
from (
select top 3 *
from #topstates
order by #topstates.topstate desc)a
union
select*
from(
select top 3*
from #bottomstates
order by #bottomstates.bottomstates
)b;




---JOINING BOTH TABLES
-- district wise 
select c.district,c.state,round(c.population/(Sex_Ratio+1),0)males,round((c.population*c.Sex_Ratio)/(c.Sex_Ratio+1),0)females from
(select dis.District,dis.State,lit.Sex_Ratio/1000 as Sex_ratio,dis.Population
from [district census] dis
inner join [literacy ratio] lit
on dis.District=lit.District)c

--state wise
select d.state,sum(d.males)as total_males,sum(d.females)as total_females from
(select c.district,c.state,round(c.population/(Sex_Ratio+1),0)males,round((c.population*c.Sex_Ratio)/(c.Sex_Ratio+1),0)females from
(select dis.District,dis.State,lit.Sex_Ratio/1000 as Sex_ratio,dis.Population
from [district census] dis
inner join [literacy ratio] lit
on dis.District=lit.District)c)d
group by d.State

-- literacy vs illiterate people
select d.state,sum(d.literate_people)as total_literate,sum(d.illiterate_people) as total_illiterate_people from
(select c.district,c.state,round(c.literacy_ratio*c.population,0) as literate_people,round((1-c.literacy_ratio)*c.population,0)as illiterate_people from
(select dis.District,dis.State,lit.Literacy/100 as literacy_ratio,dis.Population
from [district census] dis
inner join [literacy ratio] lit
on dis.District=lit.District)c)d
group by d.State



--previous census data 
select d.district,d.state,d.population/(d.growth+1)previous_census_population,d.population as current_census_population from
(select a.District,a.State,b.Growth,a.Population
from [district census] a
inner join [literacy ratio] b
on a.District=b.District)d


--previous census state wise data

select e.state,sum(e.previous_census_population) total_previous_pop,sum(e.current_census_population) total_current_pop from
(select d.district,d.state,d.population/(d.growth+1)previous_census_population,d.population as current_census_population from
(select a.District,a.State,b.Growth,a.Population
from [district census] a
inner join [literacy ratio] b
on a.District=b.District)d)e
group by e.State

---- country wise census data

select round(sum(m.previous_census_population),0) as previous_census_population,sum(current_census_population)as current_census_population from
(select e.state,sum(e.previous_census_population)as previous_census_population,sum(e.current_census_population)as current_census_population from
(select d.district,d.state,d.population/(d.growth+1)previous_census_population,d.population as current_census_population from
(select a.District,a.State,b.Growth,a.Population
from [district census] a
inner join [literacy ratio] b
on a.District=b.District)d)e
group by e.State)m

-- population vs area
select (g.total_area/g.previous_census_population)as previous_census_population_vs_area,(g.total_area/g.current_census_population)as current_census_population_vs_area  from
(select q.*,r.total_area from
(select 'INDIA' as country,f.* from
(select round(sum(m.previous_census_population),0) as previous_census_population,sum(current_census_population)as current_census_population from
(select e.state,sum(e.previous_census_population)as previous_census_population,sum(e.current_census_population)as current_census_population from
(select d.district,d.state,d.population/(d.growth+1)previous_census_population,d.population as current_census_population from
(select a.District,a.State,b.Growth,a.Population
from [district census] a
inner join [literacy ratio] b
on a.District=b.District)d)e
group by e.State)m)f) q inner join (
select 'INDIA' as country,z.* from
(select sum(Area_km2)total_area from [district census] )z)r on q.country=r.country)g










