DROP FUNCTION IF EXISTS rle_intersects_vectors_poly;

CREATE OR REPLACE FUNCTION rle_intersects_vectors_poly(
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
  poly := rle_wrap_polygon(ST_GeomFromText(polygonWKT, 4326));
  RETURN QUERY SELECT * FROM rle_intersects_vectors(poly, realm, biome, layer, occurr);
END;
$function$;
COMMENT ON FUNCTION rle_intersects_vectors_poly IS 'Query vector layers that intersect with given polygon';
