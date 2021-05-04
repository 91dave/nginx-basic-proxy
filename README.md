# Introduction

`nginx-basic-proxy` is an nginx-based reverse-proxy, run in Docker and configured entirely via Environment Variables.

The use-case for this Docker image is configuring Nginx as a reverse proxy for a range of backend services via `docker-compose` without needing to touch the filesystem. If you need more complexe configuration options, extend this `Dockerfile` and add your custom options into `/etc/nginx/custom.conf`.

If this doesn't suit your needs, take a look at [`jwilder/nginx-proxy`](https://github.com/jwilder/nginx-proxy), which is an excellent reverse-proxy for docker services.

Find this on:
- [GitHub](https://github.com/91dave/nginx-basic-proxy)
- [Docker Hub](https://hub.docker.com/r/91dave/nginx-basic-proxy)


# Configuration

All configuration is via environment variables. Each env var starting `SITE_` will configure a new `.conf` file with an nginx `server{}` directive. You can configure any number of sites by defining multiple env vars with the `SITE_` prefix. This is best illustrated by a docker-compose.yml file:

	nginx-basic-proxy:
	  image: 91dave/nginx-basic-proxy
	  ports:
	    - 80:80
	    - 8080:8080
	  environment:
	    - SITE_1frontend=endpoint=http://front-end/|port=80|internal=true
	    - SITE_2admin=endpoint=http://admin-area/|port=80|host=admin.example.org login.example.org|internal=true
	    - SITE_3elasticsearch=endpoint=http://elasticsearch-backend-elb.amazonaws.com|port=8080|host=elasticsearch.example.org|internal=false|max_request=20M
	  links:
	    - front-end:front-end
	    - admin-area:admin-area
		
	front-end:
	  image: nginx:alpine
	  
	admin-area:
	  image: nginx:alpine
  
As you can see, every environment variable defining a site to be proxied is effectively a number of key/value pairs split by a `|` character. The available config variables are below, and are optional unless explicitly specified.

* `endpoint` (required): Endpoint to `proxy_pass` requests to
* `port` (required): Port number for the `listen` directive
* `host`: Hostname to listen on - used as the value for the `server_name` directive
* `internal`: If set to true, the endpoint being proxied is assumed to be internal (generally useful for exposing services on the same machine). If set to false (default value), then an explicit DNS resolver of `8.8.8.8` is used to resolve the `proxy_pass` endpoint (incase it's IP address changes, for example)
* `max_request`: If set, the `client_max_body_size` directive is set to the value specified. Useful if the endpoint being proxied to accepts large payloads
* `echohost`: If set to true, then `proxy_set_header Host \$http_host;` directive is added, which effectively passes the existing host header through to the backend server

In this example, we have configured:

  * A front end listening on port 80 handling any URL, being proxied to a docker container on the same server
  * An admin site listening on port 80, handling URLs (admin.example.org and login.example.org) being proxied to a docker container on the same server. Note here that any valid nginx `server_name` directive is permitted here.
  * An Elastic Search service listening on port 8080 on URL elasticsearch.example.org, being proxied to an AWS elastic load balancer URL. Note the use of the `max_request` variable to ensure large indexing requests to the ElasticSearch backend service can be successfully proxied.

## Redirects

Similarly, it is possible to setup redirects by adding environment variables prefixed with `REDIRECT_`. The available config variables are below, and are optional unless explicitly specified.

* `endpoint` (required): Endpoint to `proxy_pass` requests to
* `port` (required): Port number for the `listen` directive
* `host`: Hostname to listen on - used as the value for the `server_name` directive

Each redirect entry will likewise configure a new `.conf` file with an nginx `server{}` directive, that uses a `return 301 $endpoint` statement to redirect users to the desired endpoint.

## Logging

By default, `nginx-basic-proxy` will log everything to the console, using the default `nginx log_format`.

If both of the following environment variables are set, `nginx-basic-proxy` will switch to using `json` logging and push log entries to the configured Elastic Search URL and Index. The `ES_LOG_INDEX` parameter gets passed to the unix `date` command, so must commence with a plus, but can make use of standard date formatting, as in the example to send access logs to a new Elastic Search index for each month.

- `ES_LOG_URL=http://elastic-search-url`
- `ES_LOG_INDEX=+accesslogs-%Y.%m`
