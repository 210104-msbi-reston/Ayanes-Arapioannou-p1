use project1

------------------------------------------------------------------------------------------------------
--											Triggers											    --
------------------------------------------------------------------------------------------------------
--gets all the transition info for a SN from log
select * from tbl_product_transition_log where serial_number = 'NAPH01-2019-49-A1280'

go
create trigger trg_logManufacturingOrder
on tbl_manufacturing_order_details after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select order_id from inserted)
	declare @suppliedBy varchar(10)
	set @suppliedBy = (select productionHouse_id from tbl_manufacturing_order where id = @currentOrderId)
	declare @recievedBy varchar(10)
	set @recievedBy = (select wareHouse_id from tbl_manufacturing_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_manufacturing_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go

go
create trigger trg_logDistributorOrder
on tbl_distributor_order_details after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select order_id from inserted)
	declare @suppliedBy varchar(10)
	set @suppliedBy = (select wareHouse_id from tbl_distributor_order where id = @currentOrderId)
	declare @recievedBy varchar(10)
	set @recievedBy = (select distributor_id from tbl_distributor_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_distributor_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go

go
create trigger trg_logSubDistributorOrder
on tbl_sub_distributor_order_details after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select order_id from inserted)
	declare @suppliedBy varchar(10)
	set @suppliedBy = (select distributor_id from tbl_sub_distributor_order where id = @currentOrderId)
	declare @recievedBy varchar(10)
	set @recievedBy = (select sub_distributor_id from tbl_sub_distributor_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_sub_distributor_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go

go
alter trigger trg_logChannelPartnerOrder
on tbl_channel_partner_order_details after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select order_id from inserted)
	declare @suppliedBy varchar(20)
	set @suppliedBy = (select sub_distributor_id from tbl_channel_partner_order where id = @currentOrderId)
	declare @recievedBy varchar(20)
	set @recievedBy = (select channel_partner_id from tbl_channel_partner_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_channel_partner_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go

go
create trigger trg_logStoreOrder
on tbl_store_order_details after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select order_id from inserted)
	declare @suppliedBy varchar(20)
	set @suppliedBy = (select channel_partner_id from tbl_store_order where id = @currentOrderId)
	declare @recievedBy varchar(20)
	set @recievedBy = (select store_id from tbl_store_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_store_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go

go
alter trigger trg_logCustomerOrder
on tbl_customer_order_details after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select order_id from inserted)
	declare @suppliedBy varchar(20)
	set @suppliedBy = (select store_id from tbl_customer_order where id = @currentOrderId)
	declare @recievedBy varchar(20)
	set @recievedBy = (select customer_id from tbl_customer_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_customer_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go

go
alter trigger trg_logReturnOrder
on tbl_return_order after insert
as
begin
	declare @sn varchar(50)
	set @sn = (select serial_number from inserted)
	declare @currentOrderId int
	set @currentOrderId = (select id from inserted)
	declare @suppliedBy varchar(20)
	set @suppliedBy = (select customer_id from tbl_return_order where id = @currentOrderId)
	declare @recievedBy varchar(20)
	set @recievedBy = (select production_house_id from tbl_return_order where id = @currentOrderId)
	declare @orderDate datetime
	set @orderDate = (select order_date from tbl_return_order where id = @currentOrderId)

	insert into tbl_product_transition_log values(@sn,@currentOrderId,@suppliedBy,@recievedBy,@orderDate)
end
go