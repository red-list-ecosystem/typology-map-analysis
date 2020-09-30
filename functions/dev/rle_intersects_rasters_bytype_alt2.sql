DROP FUNCTION IF EXISTS rle_intersects_rasters_bytype_alt2;

CREATE OR REPLACE FUNCTION rle_intersects_rasters_bytype_alt2(
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
    AND rle_intersects_layer(l.id, poly, occurr);
END;
$function$;
COMMENT ON FUNCTION rle_intersects_rasters_bytype_alt2 IS 'Query raster layers that intersect with given polygon';
