exports.handler = async (event) => {
    const { Client } = require('pg');
    const client = new Client({
        host: 'xxx',
        port: 123,
        database: 'xxx',
        user: 'xxx',
        password: 'xxx'
    });
    client.connect();
    console.log("Connected to PostgreSQL database");

    const {
        poly,
        regionid,
        realm,
        biome,
        layer,
        occurrence
    } = event.queryStringParameters;
    let result;
    if (poly) {
      result = await client.query(
          `SELECT * from public.rle_intersection_size_vectors_poly($1::text, $2::varchar, $3::varchar, $4::varchar, $5::int)`,
          [ poly, realm, biome, layer, occurrence ]
      );
    } else if (regionid) {
      result = await client.query(
          `SELECT * from public.rle_intersection_size_vectors_eez($1::numeric, $2::varchar, $3::varchar, $4::varchar, $5::int)`,
          [ regionid, realm, biome, layer, occurrence ]
      );
    }

    await client.end();

    if (result && result.rows) {
      const jsonString = JSON.stringify(result.rows);
      return {
          "statusCode":200,
          "body": jsonString
      };
    }
    return {
      "statusCode":501,
      "body": "Missing parameters 'poly' (PolygonWKT) or 'regionid' (numeric)"
    };
};
