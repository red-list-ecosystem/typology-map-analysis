DROP FUNCTION IF EXISTS rle_intersects_rasters_bytype_alt3;

CREATE OR REPLACE FUNCTION rle_intersects_rasters_bytype_alt3(
  polygonWKT text,
  realm varchar,
  biome varchar,
  layer varchar,
  occurr int
)
RETURNS TABLE (layer_id varchar) as
    $$
	SELECT l.id
    FROM layers AS l
    WHERE l.layer_type = 'raster'
    AND (realm IS null OR realm = l.realm_id)
    AND (biome IS null OR biome = l.biome_id)
    AND (layer IS null OR layer = l.id)
    AND EXISTS (
      SELECT 1
      FROM (
        SELECT rast
        FROM raster_tiles_bytype as r
        WHERE r.layer_id = l.id
        AND (occurr IS null OR occurr = r.occurrence)
      ) as rt
      WHERE ST_Intersects(rt.rast, 1, ST_GeomFromText(polygonWKT, 4326))
    )
	$$
	language 'sql';
