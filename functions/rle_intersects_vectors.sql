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
    SELECT layers.id
    FROM layers
    WHERE layers.layer_type = 'vector'
    AND (realm IS null OR realm = layers.realm_id)
    AND (biome IS null OR biome = layers.biome_id)
    AND (layer IS null OR layer = layers.id)
    AND EXISTS (
      SELECT 1
      FROM vector_features as vf
      WHERE vf.layer_id = layers.id
      AND(occurr IS null OR occurr = vf.occurrence)
      AND	ST_INTERSECTS(vf.wkb_geometry, poly)
    );
END;
$function$;
COMMENT ON FUNCTION rle_intersects_vectors IS 'Query vector layers that intersect with given polygon';
