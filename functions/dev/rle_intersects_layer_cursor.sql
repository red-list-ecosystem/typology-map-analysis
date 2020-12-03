declare
	layer_cursor cursor for
    	SELECT rast
        FROM raster_tiles_bytype as r
        WHERE lid = r.layer_id
		AND (occurr IS null OR occurr = r.occurrence);
begin
	for tile in layer_cursor loop
	   if ST_Intersects(tile.rast, 1, poly)
	   then
	   	 RETURN TRUE;
	   end if;
	end loop;
	RETURN FALSE;
end;
