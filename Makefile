build:
	docker build -t itinance/php-7.4-alpine-ext:latest -t itinance/php-7.4-alpine-ext:v1.0.0 .

push:
	docker push itinance/php-7.4-alpine-ext:latest
	docker push itinance/php-7.4-alpine-ext:v1.0.0

