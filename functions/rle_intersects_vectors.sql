DROP FUNCTION IF EXISTS rle_intersects_vectors;

CREATE OR REPLACE FUNCTION rle_intersects_vectors(
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
    FROM layers as l
    WHERE l.layer_type = 'vector'
    AND (realm IS null OR realm = l.realm_id)
    AND (biome IS null OR biome = l.biome_id)
    AND (layer IS null OR layer = l.id)
    AND EXISTS (
      SELECT 1
      FROM vector_features as vf
      WHERE vf.layer_id = l.id
      AND (occurr IS null OR occurr = vf.occurrence)
      AND ST_Intersects(vf.wkb_geometry, poly)
    );
END;
$function$;
COMMENT ON FUNCTION rle_intersects_vectors IS 'Query vector layers that intersect with given polygon';
