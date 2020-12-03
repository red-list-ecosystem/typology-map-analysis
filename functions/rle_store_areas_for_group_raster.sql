DROP FUNCTION IF EXISTS rle_store_areas_for_group_raster;

create or replace function rle_store_areas_for_group_raster(
  l_id varchar(10)
)
RETURNS varchar
LANGUAGE plpgsql
AS $function$
BEGIN
  DELETE FROM region_group_areas
  WHERE region_group_areas.layer_id = l_id;
  INSERT INTO region_group_areas
  SELECT
    l_id as layer_id,
    CAST (intersections.occurrence AS Integer),
    intersections.region_id as region_id,
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
      rt.layer_id as layer_id,
      rt.occurrence as occurrence,
      eez.ogc_fid as region_id,
      st_intersection(rt.rast, 1, eez._ogr_geometry_) AS gval
    FROM
      raster_tiles_bytype_1bb AS rt,
      eez_valid AS eez
    WHERE rt.layer_id = l_id
    AND st_intersects(rt.rast, 1, eez._ogr_geometry_)
  ) AS intersections
  GROUP BY intersections.layer_id, intersections.occurrence, intersections.region_id;
  return l_id;
END;
$function$;
COMMENT ON FUNCTION rle_store_areas_for_group_raster IS 'Calculate and store intersecting areas for all eez regions and a given raster layers/groups';
