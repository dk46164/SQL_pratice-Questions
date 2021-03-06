---DDL for tables
create table candidates(
  id  varchar(200),
  first_name  varchar(200),
  last_name  varchar(200));
  
CREATE TABLE result(
    cands_id  varchar(200),
    state  varchar(200)
);
    
---DML statements
insert into candidates VALUES (1,'deepak','kumar'),('2','ram','kumar'),('3','moose','kumar');
insert into result VALUES
(1,'BIHAR'),('1','UP'),('1','BIHAR'),('1','MP'),('1','UP'),('1','UP'),(1,'BIHAR'),
('2','WB'), ('2','WB'),('2','UP'),('2','BIHAR'),('2','BIHAR'),('2','UP'),('2','UP');
    
Expected output schema & values
///--------------------------------------------------------------------------------------///
[
    {"pos_1st":"UP(3)","pos_2nd":"BIHAR(2),MP(2)","pos_3rd":null,"name":"deepak kumar"}, ---> for the cnadidate their respective position & state &votecount
    {"pos_1st":"UP(3)","pos_2nd":"WB(2),BIHAR(2)","pos_3rd":null,"name":"ram kumar"}
]
///--------------------------------------------------------------------------------------///


*****************************************************QUERY********************************************
with cte as (
select count(state) as cnt ,
cands_id,state
from result 
group by cands_id,state),

cte_rnk as (
select  cands_id,concat(state,'(' ,cast(cnt as varchar),')') as str_f ,
  dense_rank()over(partition by cands_id order by cnt desc) as rnk
from cte),

cte_f as (
  SELECT  string_agg(str_f,',') as str_fr,
  cands_id,
  rnk
from cte_rnk where rnk<=3
GROUP by cands_id,rnk)

select max(t.one_palace) as pos_1st,
max(t.two_palace) as pos_2nd,
max(t.tree_palace) as pos_3rd,
concat(c.first_name,' ',c.last_name) as name
from (
SELECT 
case 
 	when rnk =1 then str_fr 
end as one_palace,
case 
 	when rnk =2 then str_fr 
end as two_palace,
case 
 	when rnk =3 then str_fr
end  as tree_palace,
cands_id
from cte_f) t 
join candidates c on c.id = t.cands_id
GROUP by t.cands_id,c.first_name,c.last_name ;
