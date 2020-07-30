DROP FUNCTION IF EXISTS rle_intersects_rasters;

CREATE OR REPLACE FUNCTION rle_intersects_rasters(
  polygonWKT text,
  realm varchar,
  biome varchar,
  layer varchar,
  occurr int
)
RETURNS TABLE (layer_id varchar)
LANGUAGE plpgsql
AS $function$
DECLARE
  poly Geometry;
BEGIN
  poly := ST_GeomFromText(polygonWKT, 4326);
  RETURN QUERY
    SELECT l.id
    FROM layers AS l
    WHERE l.layer_type = 'raster'
    AND (realm IS null OR realm = l.realm_id)
    AND (biome IS null OR biome = l.biome_id)
    AND (layer IS null OR layer = l.id)
    AND (
      occurr IS NOT null 
      OR
      EXISTS (
    		SELECT 1
    		FROM raster_tiles_x as rtx
    		WHERE rtx.layer_id = l.id
    		AND ST_Intersects(rtx.rast,1, poly)
    	)
    )
    AND (
      occurr IS null
      OR
      l.id IN (
      	SELECT DISTINCT intersected.lid
      	FROM (
      		SELECT ST_Intersection(rt.rast, 1, poly) AS geomval,
      		rt.layer_id AS lid
      		FROM raster_tiles_x AS rt
      	) AS intersected
      	WHERE occurr = CAST((intersected.geomval).val as integer)
    )
  );
END;
$function$;
COMMENT ON FUNCTION rle_intersects_rasters IS 'Query raster layers that intersect with given polygon';
