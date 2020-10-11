DROP FUNCTION IF EXISTS rle_intersection_size_rasters;

CREATE OR REPLACE FUNCTION rle_intersection_size_rasters(
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
      intersections.layer_id,
      CAST (intersections.occurrence AS Integer),
      SUM (
        st_area(
          geography(
            st_transform(
              (intersections.gval).geom,
              4326
            )
          )
        ) * 0.000001
      ) AS area
    FROM (
        SELECT
          rt.layer_id,
          rt.occurrence,
          st_intersection(rt.rast, 1, poly) AS gval
        FROM (
            SELECT intersects.layer_id
            FROM rle_intersects_rasters(poly, realm, biome, layer, occurr) as intersects
          ) AS layer_ids,
          raster_tiles_bytype AS rt
        WHERE layer_ids.layer_id = rt.layer_id
      ) AS intersections
    GROUP BY intersections.layer_id, intersections.occurrence
    ORDER BY area DESC;
END;
$function$;
COMMENT ON FUNCTION rle_intersection_size_rasters IS 'Query vector layers that intersect with given polygon geometry';
