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
    // console.log("Connected to PostgreSQL database");

    const {
        regionid,
        realm,
        biome,
        layer,
        occurrence
    } = event.queryStringParameters;

    const result = await client.query(
      `SELECT layer_id, occurrence, area, area_relative, area_total from public.rle_areasbyregion($1::numeric, $2::varchar, $3::varchar, $4::varchar, $5::int)`,
      [ regionid, realm, biome, layer, occurrence ]
     );


    await client.end();

    if (result && result.rows) {
      // console.log("Results", result.rows.length);
      const jsonString = JSON.stringify(result.rows);
      return {
          "statusCode":200,
          "body": jsonString
      };
    }
    return {
      "statusCode":501,
      "body": "Missing parameter 'regionid' (numeric)"
    };
};
