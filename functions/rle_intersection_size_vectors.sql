DROP FUNCTION IF EXISTS rle_intersection_size_vectors;

CREATE OR REPLACE FUNCTION rle_intersection_size_vectors(
  poly Geometry,
  realm varchar,
  biome varchar,
  layer varchar,
  occurr int
)
RETURNS TABLE (layer_id varchar, occurrence int, area float)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      l.id AS layer_id,
      vf.occurrence AS occurrence,
      SUM (
        st_area(
          geography(
            st_transform(
              st_intersection(vf.wkb_geometry, poly),
              4326
            )
          )
        ) * 0.000001
      ) AS area
  	FROM
      vector_features AS vf,
      layers AS l
    WHERE vf.layer_id = l.id
    AND l.layer_type = 'vector'
    AND (realm IS null OR realm = l.realm_id)
    AND (biome IS null OR biome = l.biome_id)
    AND (layer IS null OR layer = l.id)
    AND (occurr IS null OR occurr = vf.occurrence)
    AND st_intersects(vf.wkb_geometry, poly)
    GROUP BY l.id, vf.occurrence
    ORDER BY area DESC;
END;
$function$;
COMMENT ON FUNCTION rle_intersection_size_vectors IS 'Calculate the areas for all vecto layers/groups intersecting with a given polygon';;
