const { check, sleep } = require('k6');
const http = require('k6/http');

export let options = {
    stages: [
        { duration: '5m', target: 2000 },
        { duration: '20m', target: 2000 },
        { duration: '5m', target: 0 },
    ],
//    thresholds: {
//        'http_req_duration': ['p(95)<500'], // 95% of requests should finish in under 500ms
//    },
};

export default function () {
    const res = http.get('http://192.168.33.91:8081'); // Replace with your target URL

    // Check if the status code is 200
    check(res, {
        'is status 200': (r) => r.status === 200,
    });
    sleep(1);
}
