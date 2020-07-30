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
        realm,
        biome,
        layer,
        occurrence
    } = event.queryStringParameters;

    const result = await client.query(
        `SELECT public.rle_intersects_rasters($1::text, $2::varchar, $3::varchar, $4::varchar, $5::int) as layer_id`,
        [ poly, realm, biome, layer, occurrence ]
    );

    await client.end();

    const jsonString = JSON.stringify(result.rows);

    const response = {
        "statusCode":200,
        "body": jsonString
    };
    return response;
};
