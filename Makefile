PROTO_SRC=proto/calculator.proto
PROTO_PY_OUT=server
PROTO_WEB_OUT=client-web

DOCKER_COMPOSE=docker-compose.yml

.PHONY: all proto proto-python proto-web build up down logs clean tree

all: proto build tree

# ===========================
# Génération du code gRPC Python
# ===========================
proto-python:
	python3 -m grpc_tools.protoc \
		-I proto \
		--python_out=$(PROTO_PY_OUT) \
		--grpc_python_out=$(PROTO_PY_OUT) \
		$(PROTO_SRC)

# ===========================
# Génération du code gRPC-Web
# ===========================
proto-web:
	protoc -I proto \
		--js_out=import_style=commonjs:$(PROTO_WEB_OUT) \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:$(PROTO_WEB_OUT) \
		$(PROTO_SRC)

proto: 
	chmod +x install_protoc_grpc_web.sh
	./install_protoc_grpc_web.sh
	make proto-python 
	make proto-web

# ===========================
# Docker
# ===========================
build:
	docker compose -f $(DOCKER_COMPOSE) build

up:
	docker compose -f $(DOCKER_COMPOSE) up -d

down:
	docker compose -f $(DOCKER_COMPOSE) down

logs:
	docker compose -f $(DOCKER_COMPOSE) logs -f

clean:
	docker compose -f $(DOCKER_COMPOSE) down -v
	rm -f server/calculator_pb2.py server/calculator_pb2_grpc.py
	rm -f client-web/calculator_pb2.js client-web/calculator_grpc_web_pb.js

tree:
	tree -I "__pycache__|node_modules|dist"
