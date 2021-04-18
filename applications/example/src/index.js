#!/usr/bin/env node
var app = require('./app');
var http = require('http');
var port = process.env.PORT || '8080';
app.set('port', port);
var server = http.createServer(app);

server.listen(port);
server.on('error', console.error);
server.on('listening', () => console.log('server running'));
