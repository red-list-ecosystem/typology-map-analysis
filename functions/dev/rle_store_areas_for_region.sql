DROP FUNCTION IF EXISTS rle_store_areas_for_region;

create or replace function rle_store_areas_for_region(
  reg_id int
) 
RETURNS int
LANGUAGE plpgsql
AS $function$
BEGIN
  DELETE FROM region_group_areas
  WHERE region_group_areas.region_id = reg_id;
  INSERT INTO region_group_areas  
  SELECT 
    areas.layer_id as layer_id,
    areas.occurrence as occurrence,
    reg_id as region_id,
    areas.area as area
  FROM
    rle_intersection_size_vectors_eez(reg_id, null, null, null,  null ) as areas;
  return reg_id;
END;
$function$;