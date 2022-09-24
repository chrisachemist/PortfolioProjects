--cleaning data in postgresql
select * from nashville_housing;

select * from nashville_housing
order by parcelID ;
-- Check null values where a known address exists
select a1.parcelid, a1.propertyaddress, b1.parcelid, b1.propertyaddress
from nashville_housing a1
join nashville_housing b1 
	on a1.parcelid = b1.parcelid
	and a1.uniqueid != b1.uniqueid
where a1.propertyaddress is null;

--populate a value into those nulls from our known address 
update nashville_housing as a1
set propertyaddress = b1.propertyaddress
from nashville_housing as b1
where a1.parcelid = b1.parcelid
and a1.uniqueid <> b1.uniqueid
and a1.propertyaddress is null


--splitting address into (adress, city,state)
select propertyaddress
from nashville_housing;


	
select split_part(propertyaddress, ',', 1) as address,		  		  
 split_part(propertyaddress, ',', 2) as address
		  from nashville_housing;
		  --  standarize date format 
alter table nashville_housing
		add property_split_address varchar(255);

update nashville_housing
set property_split_address = split_part(propertyaddress, ',', 1);

alter table nashville_housing 
add property_split_city varchar(255);
		  
update nashville_housing
	 set property_split_city = split_part(propertyaddress, ',', 2);
-- owner address 
alter table nashville_housing
		add owner_split_address varchar(255);

update nashville_housing
set owner_split_address = split_part(owneraddress, ',', 1);

select  owner_split_address from  nashville_housing;

alter table nashville_housing 
add owner_split_city varchar(255);
		  
update nashville_housing
	 set owner_split_city = split_part(propertyaddress, ',', 2);


Select * from nashville_housing;
 
 alter table nashville_housing
 drop propertysplitaddress
 
 select owneraddress 
 from nashville_housing;
 
 select split_part(owneraddress, ',', 3) as address
 from nashville_housing

alter table nashville_housing 
add owner_split_state varchar(255);
		  
update nashville_housing
	 set owner_split_state  = split_part(owneraddress, ',', 3)
	 
	 -- now we have split address city and state 
	 select * from nashville_housing
	 
-- change Y to yes and N to no 

select distinct(soldasvacant), count(soldasvacant)
from nashville_housing
group by soldasvacant
order by 2 

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from nashville_housing

update nashville_housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end

--Remove Duplicates, though remember it is not general proecdure just in case 
with RowNumCTE as (
select ctid,
row_number() over (
partition by parcelid,
	propertyaddress,
	saleprice,
	saledate,
	legalreference
	order by 
		uniqueid
		) row_num
from nashville_housing 
--order by parcelid
)
delete from nashville_housing
using RowNumCTE
where row_num > 1 
and RowNumCTE.ctid = nashville_housing.ctid;

with RowNumCTE as (
select *,
row_number() over (
partition by parcelid,
	propertyaddress,
	saleprice,
	saledate,
	legalreference
	order by 
		uniqueid
		) row_num
from nashville_housing 
	) 
	select * from RowNumCTE 
	order by propertyaddress
	
-- Now lets delete unused Columns 
alter table nashville_housing
drop column
saledate;

select * from nashville_housing 