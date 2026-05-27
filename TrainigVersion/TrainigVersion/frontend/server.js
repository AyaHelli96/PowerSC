const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const API_HOST = 'http://localhost:5051';

const mimeTypes = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css'
};

const server = http.createServer(async (req, res) => {
    // API-Anfragen an Backend weiterleiten
    if (req.url.startsWith('/api/')) {
        const options = {
            hostname: 'localhost',
            port: 5051,
            path: req.url,
            method: req.method,
            headers: { ...req.headers, host: 'localhost:5051' }
        };

        const proxyReq = http.request(options, (proxyRes) => {
            res.writeHead(proxyRes.statusCode, proxyRes.headers);
            proxyRes.pipe(res);
        });

        req.pipe(proxyReq);
        proxyReq.on('error', () => {
            res.writeHead(502);
            res.end('Backend nicht erreichbar');
        });
        return;
    }

    // Frontend-Dateien ausliefern
    let filePath = '.' + req.url;
    if (filePath === './') filePath = './pages/login.html';

    const ext = path.extname(filePath);
    const contentType = mimeTypes[ext] || 'text/plain';

    try {
        const content = fs.readFileSync(filePath);
        res.writeHead(200, { 'Content-Type': contentType });
        res.end(content);
    } catch (e) {
        res.writeHead(404);
        res.end('Nicht gefunden');
    }
});

server.listen(PORT, () => {
    console.log('Frontend laeuft auf http://localhost:' + PORT);
    console.log('API wird weitergeleitet an http://localhost:5051');
});