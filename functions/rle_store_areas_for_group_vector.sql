DROP FUNCTION IF EXISTS rle_store_areas_for_group_vector;

create or replace function rle_store_areas_for_group_vector(
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
    vf.occurrence as occurrence,
    eez.ogc_fid as region_id,
    SUM (
    st_area(
      geography(
      st_transform(
        st_intersection(vf.wkb_geometry, eez._ogr_geometry_),
        4326
      )
      )
    ) * 0.000001
    ) AS area
  FROM
    vector_features AS vf,
    eez_valid AS eez
  WHERE vf.layer_id = l_id
  AND st_intersects(vf.wkb_geometry, eez._ogr_geometry_)
  GROUP BY l_id, vf.occurrence, eez.ogc_fid;
  return l_id;
END;
$function$;
COMMENT ON FUNCTION rle_store_areas_for_group_vector IS 'Calculate and store intersecting areas for all eez regions and a given vector layers/groups';
