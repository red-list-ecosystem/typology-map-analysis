create or replace function rle_intersects_layer(
	lid varchar,
	poly Geometry,
	occurr int
)
returns boolean
language plpgsql
as $function$
declare
	res boolean;
	tile raster;
begin
	res := FALSE;
	for tile
	in
		SELECT rast
        FROM raster_tiles_bytype as r
        WHERE lid = r.layer_id
		AND (occurr IS null OR occurr = r.occurrence)
	loop
	   if ST_Intersects(tile, 1, poly)
	   then
	   		res := TRUE;
			  exit;
	   end if;
	end loop;
	return res;
end;
$function$;
