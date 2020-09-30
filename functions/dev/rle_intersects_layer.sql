create or replace function rle_intersects_layer(
	lid varchar,
	poly Geometry,
	occurr int
)
returns boolean
language plpgsql
as $function$
declare
	rt RECORD;
	tile raster;
begin
	for tile
	in
		SELECT rast
      FROM raster_tiles_bytype as r
      WHERE lid = r.layer_id
			AND (occurr IS null OR occurr = r.occurrence)
	loop
		if
			ST_Intersects(tile, 1, poly)
	  then
			return TRUE;
	  end if;
	end loop;
	return false;
end;
$function$;
