DROP FUNCTION IF EXISTS rle_areasbyregion_lme;

CREATE OR REPLACE FUNCTION rle_areasbyregion_lme(
  regionid varchar,
  realm varchar,
  biome varchar,
  layer varchar,
  occurr int
)
RETURNS TABLE (layer_id varchar, occurrence int, area float, area_relative float, area_total numeric)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      areas.layer_id AS layer_id,
      areas.occurrence AS occurrence,
      CAST (areas.area AS float) AS area,
    CASE
      WHEN areas.occurrence = 1 THEN CAST (areas.area AS float) / NULLIF(l.area_major, 0)
      WHEN areas.occurrence = 2 THEN CAST (areas.area AS float) / NULLIF(l.area_minor, 0)
    END AS area_relative,
    CASE
      WHEN areas.occurrence = 1 THEN l.area_major
      WHEN areas.occurrence = 2 THEN l.area_minor
    END AS area_total
    FROM
      all_region_group_areas AS areas,
      layers AS l
    WHERE areas.layer_id = l.id
    AND areas.region_id = regionid
    AND (realm IS null OR realm = l.realm_id)
    AND (biome IS null OR biome = l.biome_id)
    AND (layer IS null OR layer = l.id)
    AND (occurr IS null OR occurr = areas.occurrence)
    ORDER BY areas.area DESC;
END;
$function$;
COMMENT ON FUNCTION rle_areasbyregion_lme IS 'Retrieve pre-calculated areas for a given admin or LME region';
