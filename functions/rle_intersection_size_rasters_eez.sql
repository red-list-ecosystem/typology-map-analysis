DROP FUNCTION IF EXISTS rle_intersection_size_rasters_eez;

CREATE OR REPLACE FUNCTION rle_intersection_size_rasters_eez(
  regionid numeric,
  realm varchar,
  biome varchar,
  layer varchar,
  occurr int
)
RETURNS TABLE (layer_id varchar, occurrence int, area float)
LANGUAGE plpgsql
AS $function$
DECLARE
  poly Geometry;
BEGIN
  poly := (SELECT _ogr_geometry_ FROM eez_valid WHERE ogc_fid = regionid);
  RETURN QUERY SELECT * FROM rle_intersection_size_rasters(poly, realm, biome, layer, occurr);
END;
$function$;
COMMENT ON FUNCTION rle_intersection_size_rasters_eez IS 'Calculate the areas for all raster layers/groups intersecting with a given eez, uses rle_intersection_size_rasters';
