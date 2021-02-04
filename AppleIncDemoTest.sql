use Project1

select * from tbl_product_line

exec proc_PlaceManufacturingOrder 'NAPH01', 'US01', 'A1280', 20

select count(serial_number),current_location from tbl_warehouse_stock where right(serial_number,5) = 'A1820' group by current_location having current_location = 'AD02'
select count(serial_number) from tbl_warehouse_stock where right(serial_number,5) = 'A1820' and current_location = 'AD02'

exec proc_PlaceDistributorOrder 'US-Dist','US01','A1280',5

select * from tbl_warehouse_stock


select distinct unit_price from tbl_warehouse_stock where 'A1551' = right(serial_number,5) and 'AD02' = tbl_warehouse_stock.current_location

exec proc_PlaceSubDistributorOrder 'AD-Dist','AD-SD01', 'A1553',1
exec proc_PlaceSubDistributorOrder 'US-Dist','US-SD01', 'A1280',4


exec proc_PlaceChannelPartnerOrder 'US-SD01','CP01:US-SD01','A1280',2
exec proc_PlaceChannelPartnerOrder 'AD-SD01','CP01:AD-SD01','A1553',2

exec proc_PlacestoreOrder 'CP01:US-SD01','ST01:CP01:US-SD01','A1280',1

exec proc_PlaceCustomerOrder 'ST01:CP01:US-SD01',2,'A1280',1

exec proc_PlaceReturnOrder 'NAPH01','NAPH01-2019-49-A1280','231-33-221'

select * from Returns

--gets all the transition info for a SN from log
select * from tbl_product_transition_log where serial_number = 'NAPH01-2019-49-A1280'