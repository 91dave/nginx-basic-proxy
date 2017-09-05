Introduction
------------

The use-case for this Docker image is configuring Nginx as a reverse proxy for a range of backend services via `docker-compose` without needing to touch the filesystem. If you need more complexe configuration options, extend this `Dockerfile` and add your custom options into `/etc/nginx/custom.conf`.

https://github.com/91dave/nginx-basic-proxy

If this doesn't suit your needs, take a look at https://github.com/jwilder/nginx-proxy, which is an excellent reverse-proxy for docker services.


Configuration
-------------
All configuration is via environment variables;
- `SITE_` to configure a reverse-proxied service
- `REDIRECT_` to configure a simple 304 redirect to another URL

Each env var start `SITE_` will configure a new .conf file with an nginx `server{}` directive. You can configure any number of sites by defining multiple variables with the `SITE_` prefix, and they are sorted by name. The are of the format:
- `SITE_name=backend-url|port|server_name|internal(true|false)`

This is best illustrated by a docker-compose.yml file:

	nginx-basic-proxy:
	  image: 91dave/nginx-basic-proxy
	  ports:
	    - 80:80
	    - 8080:8080
	  environment:
	    - SITE_1frontend=http://front-end/|80||true
	    - SITE_2admin=http://admin-area/|80|admin.example.org login.example.org|true
	    - SITE_3elasticsearch=http://elasticsearch-backend-elb.amazonaws.com|8080|elasticsearch.example.org|false
	  links:
	    - front-end:front-end
	    - admin-area:admin-area
		
	front-end:
	  image: nginx:alpine
	  
	admin-area:
	  image: nginx:alpine
  

In this hopefully self-documenting example, we have configured:
  * A front end listening on port 80 handling any URL, being proxied to a docker container on the same server
  * An admin site listening on port 80, handling URLs (admin.example.org and login.example.org) being proxied to a docker container on the same server. Note here that any valid nginx `server_name` directive is permitted here.
  * An Elastic Search service listening on port 8080 on URL elasticsearch.example.org, being proxied to an AWS elastic load balancer URL

The `server_name` and `internal` parameters are optional and will default to empty and `false` respectively.

By default, nginx-basic-proxy will assume the backend server is external, and configure the nginx resolver directive to use Google's 8.8.8.8 (as per https://distinctplace.com/2017/04/19/nginx-resolver-explained/). Future versions of this image may allow configuration of the resolver via another envionment variable.

If your Backend URL is NOT external (e.g. it's a hard-coded reliable IP address, or an internal hostname as is the case for the docker-compose example above), set the internal flag to true, and nginx-basic-proxy will hardcode the entry.

Logging
-----------
By default, `nginx-basic-proxy` will log everything to the console, using the default `nginx log_format`.

If both of the following environment variables are set, `nginx-basic-proxy` will switch to using `json` logging and push log entries to the configured Elastic Search URL and Index. The `ES_LOG_INDEX` parameter gets passed to the unix `date` command, so must commence with a plus, but can make use of standard date formatting, as in the example to send access logs to a new Elastic Search index for each month.

- `ES_LOG_URL=http://elastic-search-url`
- `ES_LOG_INDEX=+accesslogs-%Y.%m`
