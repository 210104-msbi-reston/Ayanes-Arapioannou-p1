use project1

------------------------------------------------------------------------------------------------------
--											Views												    --
------------------------------------------------------------------------------------------------------
go
create view [Returns] 
as
select * from tbl_product_transition_log where recieved_by like '%PH%' 
go

select * from Returns