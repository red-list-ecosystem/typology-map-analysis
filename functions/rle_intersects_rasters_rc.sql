DROP FUNCTION IF EXISTS rle_intersects_rasters_rc;

CREATE OR REPLACE FUNCTION rle_intersects_rasters_rc(
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
  reclassargs varchar;
BEGIN
  poly := ST_GeomFromText(polygonWKT, 4326);
  reclassargs := CONCAT(occurr, ':1');
  RETURN QUERY
    SELECT l.id
    FROM layers AS l
    WHERE l.layer_type = 'raster'
    AND (realm IS null OR realm = l.realm_id)
    AND (biome IS null OR biome = l.biome_id)
    AND (layer IS null OR layer = l.id)
    AND (
      (
        occurr IS null
        AND
        EXISTS (
          SELECT 1
          FROM raster_tiles_x AS rtx
          WHERE rtx.layer_id = l.id
          AND ST_Intersects(rtx.rast, 1, poly)
        )
      )
      OR (
        occurr IS not null
        AND
        EXISTS (
          SELECT 1
          FROM raster_tiles_x AS rtx
          WHERE rtx.layer_id = l.id
          AND ST_Intersects(
            ST_Reclass(rtx.rast, 1, reclassargs, '1BB', 0),
            1,
            poly
          )
        )
      )
    );
END;
$function$;
COMMENT ON FUNCTION rle_intersects_rasters_rc IS 'Query raster layers that intersect with given polygon';
