DROP FUNCTION IF EXISTS rle_wrap_polygon;

CREATE OR REPLACE FUNCTION rle_wrap_polygon(poly Geometry)
RETURNS Geometry
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN ST_GeomFromText(ST_AsText(ST_WrapX(ST_WrapX(poly, -180, 360), 180, -360)), 4326);
END;
$function$;
COMMENT ON FUNCTION rle_wrap_polygon IS 'split and wrap polygon';
