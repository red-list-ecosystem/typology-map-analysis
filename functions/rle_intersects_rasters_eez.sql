DROP FUNCTION IF EXISTS rle_intersects_rasters_eez;

CREATE OR REPLACE FUNCTION rle_intersects_rasters_eez(
  regionid numeric,
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
  poly := (SELECT _ogr_geometry_ FROM eez_valid WHERE ogc_fid = regionid);
  RETURN QUERY SELECT * FROM rle_intersects_rasters(poly, realm, biome, layer, occurr);
END;
$function$;
COMMENT ON FUNCTION rle_intersects_rasters_eez IS 'Identify raster layers/groups that intersect with given eez region, uses rle_intersects_rasters';
