FROM python:3.10-slim

WORKDIR /app

COPY client-python/requirements.txt .

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copier les proto depuis le contexte racine
COPY proto ./proto

# Compiler le proto
RUN python3 -m grpc_tools.protoc \
    -I proto \
    --python_out=. \
    --grpc_python_out=. \
    proto/calculator.proto

COPY client-python/client.py .

CMD ["python3", "client.py"]
