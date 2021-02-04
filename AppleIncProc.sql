use Project1
--Needs cleaning up
--Combine proc

------------------------------------------------------------------------------------------------------
--									Sequence										--
------------------------------------------------------------------------------------------------------
--Sequence used to concatenate into product serial number
create sequence serialNumberCounter
start with 1
increment by 1
------------------------------------------------------------------------------------------------------
--									Functions and Procedures									    --
------------------------------------------------------------------------------------------------------

--Function to get country tax
go
create function GetCntryTax(@whCode varchar(10))
returns decimal
as
begin
	declare @cntryTax decimal
	set @cntryTax =	(select ctry_tax from tbl_countries inner join tbl_warehouse on tbl_countries.code = tbl_warehouse.country_code where tbl_warehouse.code = @whCode)
	return @cntryTax
end
go


--Proc to create a amnufatuting order and exec proc to generate serial numbers
go
alter procedure proc_PlaceManufacturingOrder(@phCode varchar(10), @whCode varchar(10), @modelNo varchar(50), @qty int)
as
begin
	declare @manCost money
	declare @unitPrice money
	set @manCost = (@qty * (select price from tbl_product_line where @modelNo = ModelNumbers)) 
	set @manCost = @manCost + (dbo.GetCntryTax (@whCode)) 
					--(@manCost * (select ctry_tax from tbl_countries 
					--inner join tbl_warehouse on tbl_countries.code = tbl_warehouse.country_code 
					--where tbl_warehouse.code = @whCode))
	set @unitPrice = @manCost / @qty
	if((left(@phCode,2) = (select continent_code from tbl_countries where code = left(@whCode,2))))
	begin
		insert into tbl_manufacturing_order values (@phCode, @whCode, @modelNo, @qty, @manCost, GETDATE())
		declare @currentOrderId int
		set @currentOrderId = (select max(id) from tbl_manufacturing_order)
		declare @i int
		set @i = 0
		while @i < @qty
		begin
			set @i = @i + 1
			exec proc_GenerateSerialNoManuOrder @currentOrderId,@phCode,@modelNo,@whCode,@unitPrice
		end
	end
	else
	begin
		raiserror('That warehouse does not belong to that Production house', 11, 0)
	end
end
go

--Proc to generate serial numbers exec when an manufaturing order is placed
go
alter procedure proc_GenerateSerialNoManuOrder(@manOrderId int, @phCode varchar(10), @modelNo varchar(50), @whCode varchar(10),@unitPrice money)
as
begin
	declare @modelYear varchar(10)
	set @modelYear = (select year from tbl_product_line where ModelNumbers = @modelNo)
	declare @SN varchar(50) = ''
	set @SN = CONCAT(@phCode,'-',@modelYear,'-',next value for SerialNumberCounter,'-',@modelNo)
	insert into tbl_manufacturing_order_details values (@manOrderId, @SN)
	insert into tbl_warehouse_stock values (@whCode,@SN,@unitPrice)
end
go

--Proc to create a Distributor order
go
alter procedure proc_PlaceDistributorOrder(@distCode varchar(10), @whCode varchar(10),@modelNo varchar(50), @qty int)
as
begin
	declare @distCost money
	set @distCost = (select distinct unit_price from tbl_warehouse_stock where @modelNo = right(serial_number,5) and @whCode = tbl_warehouse_stock.current_location)
	set @distCost = @qty * (@distCost + (@distCost * .08))
	declare @unitPrice money
	set @unitPrice = (@distCost / @qty)

	if(left(@distCode,2) = left(@whCode,2))
	begin
		if(@qty <= (select count(serial_number) from tbl_warehouse_stock where right(serial_number,5) = @modelNo and current_location = @whCode))
		begin
			insert into tbl_distributor_order values (@distCode,@whCode,@modelNo,@qty,@distCost,GETDATE())
			declare @currentDistOrderId int
			set @currentDistOrderId = (select max(id) from tbl_distributor_order)

			declare @i int = 0
			while(@i < @qty)
			begin
				
				--grabs the the highest id of the model for that WH
				declare @unit_id int
				declare @current_sn varchar(50)
				set @unit_id = (select min(id) from tbl_warehouse_stock where right(serial_number,5) = @modelNo and current_location = @whCode)
				--uses that id to get the serial number that will be removed from WH and added to Dist order and later to Dist stock
				set @current_sn = (select serial_number from tbl_warehouse_stock where id = (@unit_id))
				insert into tbl_distributor_order_details values (@currentDistOrderId , @current_sn)
				insert into tbl_distributor_stock values (@distCode, @current_sn,@unitPrice)
				delete from tbl_warehouse_stock where id = @unit_id
				set @i = @i + 1
			end

		end
		else
		begin			
			raiserror('That warehouse does not have enough of that product in stock', 11, 0)
		end
	end
	else
	begin
		raiserror('This distributor cannot order from a warehouse in another country', 11, 0)
	end
end
go

--Proc to create a Sub Distributor order
go
alter procedure proc_PlaceSubDistributorOrder(@distCode varchar(10), @subDistCode varchar(10),@modelNo varchar(50), @qty int)
as
begin
	declare @subDistCost money
	set @subDistCost = (select distinct unit_price from tbl_distributor_stock where @modelNo = right(serial_number,5) and @DistCode = tbl_distributor_stock.current_location)
	set @subDistCost = @qty * (@subDistCost + (@subDistCost * .08))
	declare @unitPrice money
	set @unitPrice = (@subDistCost / @qty)

	if(left(@distCode,2) = left(@subDistCode,2))
	begin
		if(@qty <= (select count(serial_number) from tbl_distributor_stock where right(serial_number,5) = @modelNo and current_location = @distCode))
		begin
			insert into tbl_sub_distributor_order values (@distCode,@subDistCode,@modelNo,@qty,@subDistCost,GETDATE())
			declare @currentSubDistOrderId int
			set @currentSubDistOrderId = (select max(id) from tbl_sub_distributor_order)

			declare @i int = 0
			while(@i < @qty)
			begin
				
				--grabs the the highest id of the model for that Distributor
				declare @unit_id int
				declare @current_sn varchar(50)
				set @unit_id = (select min(id) from tbl_distributor_stock where right(serial_number,5) = @modelNo and current_location = @distCode)
				--uses that id to get the serial number that will be removed from Distributor and added to subDist order and later to Dist stock
				set @current_sn = (select serial_number from tbl_distributor_stock where id = (@unit_id))
				insert into tbl_sub_distributor_order_details values (@currentSubDistOrderId , @current_sn)
				insert into tbl_sub_distributor_stock values (@subDistCode, @current_sn,@unitPrice)
				delete from tbl_distributor_stock where id = @unit_id
				set @i = @i + 1
			end

		end
		else
		begin			
			raiserror('That Distributor does not have enough of that product in stock', 11, 0)
		end
	end
	else
	begin
		raiserror('This Sub Distributor cannot order from a Distibutor in another country', 11, 0)
	end
end

--create channel partner order
go
alter procedure proc_PlaceChannelPartnerOrder(@subDistCode varchar(10), @cpCode varchar(20),@modelNo varchar(50), @qty int)
as
begin
	declare @cpCost money
	set @cpCost = (select distinct unit_price from tbl_sub_distributor_stock where @modelNo = right(serial_number,5) and @subDistCode = tbl_sub_distributor_stock.current_location)
	set @cpCost = @qty * (@cpCost + (@cpCost * .08))
	declare @unitPrice money
	set @unitPrice = (@cpCost / @qty)

	if(right(@cpCode,7) = right(@subDistCode,7))
	begin
		if(@qty <= (select count(serial_number) from tbl_sub_distributor_stock where right(serial_number,5) = @modelNo and current_location = @subDistCode))
		begin
			insert into tbl_channel_partner_order values (@subDistCode,@cpCode,@modelNo,@qty,@cpCost,GETDATE())
			declare @currentCpOrderId int
			set @currentCpOrderId = (select max(id) from tbl_channel_partner_order)

			declare @i int = 0
			while(@i < @qty)
			begin
				
				--grabs the the highest id of the model for that Distributor
				declare @unit_id int
				declare @current_sn varchar(50)
				set @unit_id = (select min(id) from tbl_sub_distributor_stock where right(serial_number,5) = @modelNo and current_location = @subDistCode)
				--uses that id to get the serial number that will be removed from Distributor and added to subDist order and later to Dist stock
				set @current_sn = (select serial_number from tbl_sub_distributor_stock where id = (@unit_id))
				insert into tbl_channel_partner_order_details values (@currentcpOrderId , @current_sn)
				insert into tbl_channel_partner_stock values (@cpCode, @current_sn,@unitPrice)
				delete from tbl_sub_distributor_stock where id = @unit_id
				set @i = @i + 1
			end

		end
		else
		begin			
			raiserror('That Sub Distributor does not have enough of that product in stock', 11, 0)
		end
	end
	else
	begin
		raiserror('This Channel Partner cannot order from a Sub Distibutor not in your supply chain', 11, 0)
	end
end
go

--Create store order
go
alter procedure proc_PlacestoreOrder(@cpCode varchar(20), @storeCode varchar(20),@modelNo varchar(50), @qty int)
as
begin
	declare @storeCost money
	set @storeCost = (select distinct unit_price from tbl_channel_partner_stock where @modelNo = right(serial_number,5) and @cpCode = tbl_channel_partner_stock.current_location)
	set @storeCost = @qty * (@storeCost + (@storeCost * .08))
	declare @unitPrice money
	set @unitPrice = (@storeCost / @qty)

	if(right(@cpCode,12) = right(@storeCode,12))
	begin
		if(@qty <= (select count(serial_number) from tbl_channel_partner_stock where right(serial_number,5) = @modelNo and current_location = @cpCode))
		begin
			insert into tbl_store_order values (@cpCode,@storeCode,@modelNo,@qty,@storeCost,GETDATE())
			declare @currentStoreOrderId int
			set @currentStoreOrderId = (select max(id) from tbl_store_order)

			declare @i int = 0
			while(@i < @qty)
			begin
				
				--grabs the the highest id of the model for that Distributor
				declare @unit_id int
				declare @current_sn varchar(50)
				set @unit_id = (select min(id) from tbl_channel_partner_stock where right(serial_number,5) = @modelNo and current_location = @cpCode)
				--uses that id to get the serial number that will be removed from Distributor and added to subDist order and later to Dist stock
				set @current_sn = (select serial_number from tbl_channel_partner_stock where id = (@unit_id))
				insert into tbl_store_order_details values (@currentStoreOrderId , @current_sn)
				insert into tbl_store_stock values (@storeCode, @current_sn,@unitPrice)
				delete from tbl_channel_partner_stock where id = @unit_id
				set @i = @i + 1
			end

		end
		else
		begin			
			raiserror('That Channel partner does not have enough of that product in stock', 11, 0)
		end
	end
	else
	begin
		raiserror('This Store cannot order from a Channel partner not in your supply chain', 11, 0)
	end
end
go

--create customer order
go
create procedure proc_PlaceCustomerOrder(@storeCode varchar(20), @custID int,@modelNo varchar(50), @qty int)
as
begin
	declare @custCost money
	set @custCost = (select distinct unit_price from tbl_store_stock where @modelNo = right(serial_number,5) and @storeCode = tbl_store_stock.current_location)
	set @custCost = @qty * (@custCost + (@custCost * .05))
	declare @unitPrice money
	set @unitPrice = (@custCost / @qty)

	if(@qty <= (select count(serial_number) from tbl_store_stock where right(serial_number,5) = @modelNo and current_location = @storeCode))
		begin
			insert into tbl_customer_order values (@storeCode,@custID,@modelNo,@qty,@custCost,GETDATE())
			declare @currentcustomerOrderId int
			set @currentCustomerOrderId = (select max(id) from tbl_customer_order)

			declare @i int = 0
			while(@i < @qty)
			begin
				
				--grabs the the highest id of the model for that Distributor
				declare @unit_id int
				declare @current_sn varchar(50)
				set @unit_id = (select min(id) from tbl_store_stock where right(serial_number,5) = @modelNo and current_location = @storeCode)
				--uses that id to get the serial number that will be removed from Distributor and added to subDist order and later to Dist stock
				set @current_sn = (select serial_number from tbl_store_stock where id = (@unit_id))
				insert into tbl_customer_order_details values (@currentcustomerOrderId , @current_sn)
				--insert into tbl_store_stock values (@storeCode, @current_sn,@unitPrice)
				delete from tbl_store_stock where id = @unit_id
				set @i = @i + 1
			end
		end
		else
		begin			
			raiserror('That store does not have enough of that product in stock', 11, 0)
		end	
end
go

--create return order
go
alter procedure proc_PlaceReturnOrder(@phCode varchar(10),@serialNo varchar(50),@sn varchar(10))
as
begin	

	declare @custID int	
	set @custID = (select id from tbl_customer where ssn = @sn)
	insert into tbl_return_order values (@custID,@phCode,@serialNo,GETDATE())
	--declare @currentReturnOrderId int
	--set @currentReturnOrderId = (select max(id) from tbl_return_order)			
end
go