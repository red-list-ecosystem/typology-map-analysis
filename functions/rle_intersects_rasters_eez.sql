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
  poly := (SELECT _ogr_geometry_ FROM eez_land_v3_202030 WHERE ogc_fid = regionid);
  RETURN QUERY SELECT * FROM rle_intersects_rasters(poly, realm, biome, layer, occurr);
END;
$function$;
COMMENT ON FUNCTION rle_intersects_rasters_eez IS 'Query vector layers that intersect with given polygon';
