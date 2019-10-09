var express = require('express');
var app = express();
var uuid = require('uuid');

var Pool = require('pg').Pool;
var config = {
  user: process.env.POSTGRES_USER,
  database: process.env.POSTGRES_DATABASE_NAME,
  password: process.env.POSTGRES_PASSWORD,
  host: process.env.POSTGRES_HOSTNAME,
  port: process.env.POSTGRES_PORT || 5432,
  ssl: process.env.POSTGRES_SSL || true,
};

var pool = new Pool(config);

app.get('/sample', (req, res) => {
  pool.connect((dbError, client, done) => {
    if (dbError) {
      console.error(dbError);
      return res.status(500).send('Postgres client error');
    }
    client.query('SELECT now() as time', [], (queryError, result) => {
      done();
      if (queryError) {
        console.error(queryError);
        return res.status(500).send('Postgres query error');
      }
      return res.json({
        rid: uuid.v4(),
        time: result.rows[0].time
      });
    });
  });
});

app.get('/health', (req, res) => {
  pool.connect((dbError, client, done) => {
    if (dbError) {
      console.error(dbError);d
      return res.status(500).send('Postgres client error');
    }
    done();
    return res.status(200).send('OK');
  });
});

module.exports = app;
