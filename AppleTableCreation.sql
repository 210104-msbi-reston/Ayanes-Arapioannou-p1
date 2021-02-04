create table Project1
use Porject1

create table tbl_continent
(
	id int identity,
	code char(2) not null,
	cont_name varchar(20),

	constraint [PK_continent] primary key ([code] asc)
)

--CREATED ALL THE CONITNENTS
insert into tbl_continent values('AF','Africa')
insert into tbl_continent values('AS','Asia')
insert into tbl_continent values('EU','Europe')
insert into tbl_continent values('NA','North America')
insert into tbl_continent values('SA','South America')
insert into tbl_continent values('OC','Oceania')
insert into tbl_continent values('AN','Antartica')

create table tbl_countries
(
	id int identity,
	continent_code char(2) not null,
	code char(2) not null,
	ctry_name varchar(70),

	constraint [PK_country] primary key ([code] asc),
	constraint [FK_countries_continent] foreign key (continent_code) references tbl_continent (code)
)
--USED SSIS to import countries into tbl_countries 253 countries

--How SSIS created the table sourced from txt file
create table tbl_product_line
(
	[ModelNumbers] [varchar](50) NOT NULL,
	[Year] [varchar](50) NULL,
	[price] [varchar](50) NULL,
	[Type] [varchar](50) NULL,
	[Specifications] [varchar](400) NULL,

	constraint [PK_product_line] primary key ([ModelNumbers] asc)
)
--USED SSIS create and import product line information for tbl_product_line

create table tbl_production_house
(
	id int identity,
	code varchar(10),
	continent_code char(2)

	constraint [PK_production_house] primary key ([code])
	constraint [FK_productionHouse_continent] foreign key (continent_code) references tbl_continent (code)
)
--CREATED ALL THE PRODUCTION HOUSES PER CONTINENT
insert into tbl_production_house values('AFPH01','AF')
insert into tbl_production_house values('AFPH02','AF')
insert into tbl_production_house values('AFPH03','AF')
insert into tbl_production_house values('ASPH01','AS')
insert into tbl_production_house values('ASPH02','AS')
insert into tbl_production_house values('ASPH03','AS')
insert into tbl_production_house values('EUPH01','EU')
insert into tbl_production_house values('EUPH02','EU')
insert into tbl_production_house values('EUPH03','EU')
insert into tbl_production_house values('NAPH01','NA')
insert into tbl_production_house values('NAPH02','NA')
insert into tbl_production_house values('NAPH03','NA')
insert into tbl_production_house values('SAPH01','SA')
insert into tbl_production_house values('SAPH02','SA')
insert into tbl_production_house values('SAPH03','SA')
insert into tbl_production_house values('OCPH01','OC')
insert into tbl_production_house values('OCPH02','OC')
insert into tbl_production_house values('OCPH03','OC')
insert into tbl_production_house values('ANPH01','AN')
insert into tbl_production_house values('ANPH02','AN')
insert into tbl_production_house values('ANPH03','AN')

create table tbl_warehouse
(
	id int identity,
	code varchar(10),
	country_code char(2) 

	constraint [PK_warehouse] primary key ([code] asc),
	constraint [FK_warehouse_countries] foreign key (country_code) references tbl_countries (code)
)

--Loops through all the countries and inserts 4 warehouses for each
declare @i int = 0
while @i < (select count(id) from tbl_countries)
begin
	set @i = @i + 1
	declare @cntry varchar(2) = (select code from tbl_countries where id = @i)
	declare @j int = 0
	while @j < 4
	begin
		set @j = @j + 1
		insert into tbl_warehouse values((select concat(@cntry,'WH0',@j)),@cntry)
	end
end

create table tbl_manufacturing_order
(
	id int identity(1000,1),
	productionHouse_id varchar(10),
	wareHouse_id varchar(10),
	product_id varchar(50),
	quantity int,
	manufacturing_cost money,
	order_date datetime

	constraint [PK_manufacturing_order] primary key ([id]),
	constraint [FK_manufacturingOrder_productionHouse] foreign key (productionHouse_id) references tbl_production_house,
	constraint [FK_manufacturingOrder_warehouse] foreign key (warehouse_id) references tbl_warehouse (code),
	constraint [FK_manufacturingOrder_productline] foreign key (product_id) references tbl_product_line (modelnumbers)
)

create table tbl_manufacturing_order_details
(
	order_id int,
	serial_number varchar(50),	

	constraint [PK_manufacturing_order_details] primary key (serial_number),
	constraint [FK_manufacturingOrderDetails_manufacturingOrder] foreign key (order_id) references tbl_manufacturing_order
)

create table tbl_warehouse_stock
(
	id int identity,
	current_location varchar(10),
	serial_number varchar(50),
	unit_price money

	constraint [PK_warehouse_stock] primary key (id),
	constraint [FK_warehouseStock_manufacturingOrderDetails] foreign key (serial_number) references tbl_manufacturing_order_details (serial_number),
	constraint [FK_warehouseStock_warehouse] foreign key (current_location) references tbl_warehouse (code),
)

create table tbl_distributor
(
	id int identity,
	code varchar(10),
	country_code char(2) 

	constraint [PK_distributor] primary key ([code] asc),
	constraint [FK_distributor_countries] foreign key (country_code) references tbl_countries (code)
)
--Loops through all the countries and a distributor for each
declare @k int = 0
while @k < (select count(id) from tbl_countries)
begin
	set @k = @k + 1
	declare @cntry1 varchar(2) = (select code from tbl_countries where id = @k)	
	insert into tbl_distributor values((select concat(@cntry1,'-Dist')),@cntry1)	
end

create table tbl_distributor_order
(
	id int identity(20000,1),
	distributor_id varchar(10),
	wareHouse_id varchar(10),
	product_id varchar(50),
	quantity int,
	distributor_cost money,
	order_date datetime

	constraint [PK_distributor_order] primary key ([id]),
	constraint [FK_distributorOrder_distributor] foreign key (distributor_id) references tbl_distributor (code),
	constraint [FK_distributorOrder_warehouse] foreign key (warehouse_id) references tbl_warehouse (code),
	constraint [FK_distributorOrder_productline] foreign key (product_id) references tbl_product_line (modelnumbers)
)

create table tbl_distributor_order_details
(
	order_id int,
	serial_number varchar(50),	

	constraint [PK_distributor_order_details] primary key (serial_number),
	constraint [FK_distributorOrderDetails_distributorOrder] foreign key (order_id) references tbl_distributor_order
)

create table tbl_distributor_stock
(
	id int identity,
	current_location varchar(10),
	serial_number varchar(50),
	unit_price money

	constraint [PK_distributor_stock] primary key (id),
	constraint [FK_distributorStock_distributorOrderDetails] foreign key (serial_number) references tbl_distributor_order_details (serial_number),
	constraint [FK_distributorStock_distributor] foreign key (current_location) references tbl_distributor (code)
)

create table tbl_product_transition_log
(
	id int identity,
	serial_number varchar(50),
	order_id int,
	supplied_by varchar(20),
	recieved_by varchar(20),
	date datetime,

	constraint [PK_product_transidtion_log] primary key (id)
)

create table tbl_sub_distributor
(
	id int identity,
	code varchar(10),
	distributor_code varchar(10),

	constraint [PK_sub_distributor] primary key (code),
	constraint [FK_subDistributor_distributor] foreign key (distributor_code) references tbl_distributor (code)
)

--Loop to create 3 sub distributors for each distributor
declare @s int = 0
while @s < (select count(id) from tbl_distributor)
begin
	set @s = @s + 1
	declare @dist varchar(10) = (select code from tbl_distributor where id = @s)
	declare @f int = 0
	while @f < 3
	begin
		set @f = @f + 1
		insert into tbl_sub_distributor values((select concat(left(@dist,2),'-SD0',@f)),@dist)
	end
end

create table tbl_sub_distributor_order
(
	id int identity(300000,1),
	distributor_id varchar(10),
	sub_distributor_id varchar(10),
	product_id varchar(50),
	quantity int,
	sub_distributor_cost money,
	order_date datetime

	constraint [PK_sub_distributor_order] primary key ([id]),
	constraint [FK_sub_distributorOrder_distributor] foreign key (distributor_id) references tbl_distributor (code),
	constraint [FK_sub_distributorOrder_subDistributor] foreign key (sub_distributor_id) references tbl_sub_distributor (code),
	constraint [FK_sub_distributorOrder_productline] foreign key (product_id) references tbl_product_line (modelnumbers)
)

create table tbl_sub_distributor_order_details
(
	order_id int,
	serial_number varchar(50),	

	constraint [PK_sub_distributor_order_details] primary key (serial_number),
	constraint [FK_subDistributorOrderDetails_subDistributorOrder] foreign key (order_id) references tbl_sub_distributor_order
)

create table tbl_sub_distributor_stock
(
	id int identity,
	current_location varchar(10),
	serial_number varchar(50),
	unit_price money

	constraint [PK_sub_distributor_stock] primary key (id),
	constraint [FK_sub_distributorStock_subDistributorOrderDetails] foreign key (serial_number) references tbl_sub_distributor_order_details (serial_number),
	constraint [FK_sub_distributorStock_subDistributor] foreign key (current_location) references tbl_sub_distributor (code)
)

create table tbl_channel_partner
(
	id int identity,
	code varchar(20),
	sub_distributor_code varchar(10),
	zone varchar(10),

	constraint [PK_channel_partner] primary key (code),
	constraint [FK_channelPartner_subDistributor] foreign key (sub_distributor_code) references tbl_sub_distributor (code)
)

--Loop to create 2 channel partner for each sub distributor
go
declare @i int = 0
while @i < (select count(id) from tbl_sub_distributor)
begin
	set @i = @i + 1
	declare @subDist varchar(10) = (select code from tbl_sub_distributor where id = @i)
	declare @f int = 0
	while @f < 2
	begin
		set @f = @f + 1
		if(@f = 1)
		begin
			insert into tbl_channel_partner values(concat('CP0',@f,':',@subDist),@subDist,'Upper')
		end
		else
		begin
			insert into tbl_channel_partner values(concat('CP0',@f,':',@subDist),@subDist,'Lower')
		end
	end
end
go

create table tbl_channel_partner_order
(
	id int identity(4000000,1),
	sub_distributor_id varchar(10),
	channel_partner_id varchar(20),
	product_id varchar(50),
	quantity int,
	channel_partner_cost money,
	order_date datetime

	constraint [PK_channel_partner_order] primary key ([id]),
	constraint [FK_channel_partner_order_subDistributor] foreign key (sub_distributor_id) references tbl_sub_distributor (code),
	constraint [FK_channel_partner_order_channel_partner] foreign key (channel_partner_id) references tbl_channel_partner (code),
	constraint [FK_channel_partner_order_productline] foreign key (product_id) references tbl_product_line (modelnumbers)
)

create table tbl_channel_partner_order_details
(
	order_id int,
	serial_number varchar(50),	

	constraint [PK_channel_partner_order_details] primary key (serial_number),
	constraint [FK_schannelPartnerOrderDetails_channelPartnerOrder] foreign key (order_id) references tbl_channel_partner_order
)

create table tbl_channel_partner_stock
(
	id int identity,
	current_location varchar(20),
	serial_number varchar(50),
	unit_price money

	constraint [PK_channel_partner_stock] primary key (id),
	constraint [FK_channelPartnerStock_channelPartnerOrderDetails] foreign key (serial_number) references tbl_channel_partner_order_details (serial_number),
	constraint [FK_channelPartnerStock_channelPartner] foreign key (current_location) references tbl_channel_partner (code)
)

create table tbl_store
(
	id int identity,
	code varchar(20),
	channel_partner varchar(20),
	
	constraint [PK_store] primary key (code),
	constraint [FK_store_channelPartner] foreign key (channel_partner) references tbl_channel_partner (code)
)

--loop to create 3 stores for each channel partner
go
declare @i int = 0
while @i < (select count(id) from tbl_channel_partner)
begin
	set @i = @i + 1
	declare @cp varchar(20) = (select code from tbl_channel_partner where id = @i)
	declare @f int = 0
	while @f < 3
	begin
		set @f = @f + 1
		insert into tbl_store values(concat('ST0',@f,':',@cp),@cp)		
	end
end
go

create table tbl_store_order
(
	id int identity(50000000,1),
	channel_partner_id varchar(20),
	store_id varchar(20),
	product_id varchar(50),
	quantity int,
	store_cost money,
	order_date datetime

	constraint [PK_store_order] primary key ([id]),
	constraint [FK_store_order_channelPartner] foreign key (channel_partner_id) references tbl_channel_partner (code),
	constraint [FK_store_order_store] foreign key (store_id) references tbl_store (code),
	constraint [FK_store_order_productline] foreign key (product_id) references tbl_product_line (modelnumbers)
)

create table tbl_store_order_details
(
	order_id int,
	serial_number varchar(50),	

	constraint [PK_store_order_details] primary key (serial_number),
	constraint [FK_storeOrderDetails_storePartnerOrder] foreign key (order_id) references tbl_store_order
)

create table tbl_store_stock
(
	id int identity,
	current_location varchar(20),
	serial_number varchar(50),
	unit_price money

	constraint [PK_store_stock] primary key (id),
	constraint [FK_storeStock_storeOrderDetails] foreign key (serial_number) references tbl_store_order_details (serial_number),
	constraint [FK_storeStock_channelPartner] foreign key (current_location) references tbl_store (code)
)

create table tbl_customer
(
	id int identity,
	firstName varchar(20),
	lastName varchar(20),
	ssn varchar(10)

	constraint [PK_customer] primary key (id)
)

insert into tbl_customer values ('James','Smith', '164-56-881')
insert into tbl_customer values ('Alex','Jones', '231-33-221')
insert into tbl_customer values ('Kelly','Johnson', '648-45-121')
insert into tbl_customer values ('Frank','Clark', '157-87-247')
insert into tbl_customer values ('Brandon','Bronson', '949-93-345')
insert into tbl_customer values ('Ashley','Thomas', '411-42-798')
insert into tbl_customer values ('Sophia','Flay', '071-13-465')

create table tbl_customer_order
(
	id int identity(90000000,1),
	store_id varchar(20),
	customer_id int,
	product_id varchar(50),
	qty int,
	cost money,
	order_date datetime

	constraint [PK_customer_order] primary key ([id]),
	constraint [FK_customer_order_store] foreign key (store_id) references tbl_store (code),
	constraint [FK_customer_order_customer] foreign key (customer_id) references tbl_customer (id),
	constraint [FK_customer_order_productline] foreign key (product_id) references tbl_product_line (modelnumbers)	
)

create table tbl_customer_order_details
(
	order_id int,
	serial_number varchar(50),	

	constraint [PK_customer_order_details] primary key (serial_number),
	constraint [FK_customerOrderDetails_customerOrder] foreign key (order_id) references tbl_customer_order
)

create table tbl_return_order
(
	id int identity(90000000,1),
	customer_id int,
	production_house_id varchar(10),
	serial_number varchar(50),
	order_date datetime

	constraint [PK_return_order] primary key ([id]),
	constraint [FK_return_order_customer] foreign key (customer_id) references tbl_customer (id),
	constraint [FK_return_order_production_house] foreign key (production_house_id) references tbl_production_house (code)
)
------------------------------------------------------------------------------------------------------
--									ALL THE TABLES SO FAR											--
------------------------------------------------------------------------------------------------------

select * from tbl_continent
select * from tbl_countries
select * from tbl_product_line
select * from tbl_production_house
select * from tbl_warehouse
select * from tbl_manufacturing_order
select * from tbl_manufacturing_order_details
select * from tbl_warehouse_stock
select * from tbl_distributor
select * from tbl_distributor_order
select * from tbl_distributor_order_details
select * from tbl_distributor_stock
select * from tbl_sub_distributor
select * from tbl_sub_distributor_order
select * from tbl_sub_distributor_order_details
select * from tbl_sub_distributor_stock
select * from tbl_channel_partner
select * from tbl_channel_partner_order
select * from tbl_channel_partner_order_details
select * from tbl_channel_partner_stock
select * from tbl_store
select * from tbl_store_order
select * from tbl_store_order_details
select * from tbl_store_stock
select * from tbl_customer
select * from tbl_customer_order
select * from tbl_customer_order_details
select * from tbl_return_order
select * from tbl_product_transition_log