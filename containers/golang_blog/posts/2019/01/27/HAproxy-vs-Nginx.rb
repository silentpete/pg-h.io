Simple testing of a proxy with Apache Benchmark (ab) using HAProxy and Nginx proxy services.

# HAProxy vs. Nginx for Proxy's with the same Apache Backends

Reference: [https://github.com/silentpete/nginx-vs-haproxy](https://github.com/silentpete/nginx-vs-haproxy)

Stand up three Apache httpd containers for backends.

Stand up a HAProxy container frontend.

Stand up a Nginx container frontend.

## Apache Benchmark HAProxy

```
# ab -n 100000 -c 1000 -r -d http://localhost:9001/
This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 10000 requests
Completed 20000 requests
Completed 30000 requests
Completed 40000 requests
Completed 50000 requests
Completed 60000 requests
Completed 70000 requests
Completed 80000 requests
Completed 90000 requests
Completed 100000 requests
Finished 100000 requests


Server Software:        Apache/2.4.38
Server Hostname:        localhost
Server Port:            9001

Document Path:          /
Document Length:        20 bytes

Concurrency Level:      1000
Time taken for tests:   41.349 seconds
Complete requests:      100000
Failed requests:        0
Write errors:           0
Total transferred:      26400000 bytes
HTML transferred:       2000000 bytes
Requests per second:    2418.43 [#/sec] (mean)
Time per request:       413.491 [ms] (mean)
Time per request:       0.413 [ms] (mean, across all concurrent requests)
Transfer rate:          623.50 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   95 383.2      1    3012
Processing:    20  303 558.6    136    7217
Waiting:        2  302 558.6    135    7215
Total:         22  399 685.5    142    7219
```

## Apache Benchmark Nginx

```
# ab -n 100000 -c 1000 -r -d http://localhost:9002/
This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 10000 requests
Completed 20000 requests
Completed 30000 requests
Completed 40000 requests
Completed 50000 requests
Completed 60000 requests
Completed 70000 requests
Completed 80000 requests
Completed 90000 requests
Completed 100000 requests
Finished 100000 requests


Server Software:        nginx/1.15.8
Server Hostname:        localhost
Server Port:            9002

Document Path:          /
Document Length:        20 bytes

Concurrency Level:      1000
Time taken for tests:   47.752 seconds
Complete requests:      100000
Failed requests:        0
Write errors:           0
Total transferred:      25600000 bytes
HTML transferred:       2000000 bytes
Requests per second:    2094.15 [#/sec] (mean)
Time per request:       477.522 [ms] (mean)
Time per request:       0.478 [ms] (mean, across all concurrent requests)
Transfer rate:          523.54 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0   23 162.5      1    3013
Processing:     6  419 883.8     92   15128
Waiting:        2  418 883.8     91   15126
Total:          7  442 896.5     94   15128
```

## Conclusion

I ran this a couple months back and I remember Nginx not doing as well as HAProxy. This time around I feel they run pretty similar. Guess you can use either for simple proxy'ing.
