# ==============================
# Dockerfile - server (gRPC Python)
# ==============================
FROM python:3.10-slim

WORKDIR /app

# Installer les dépendances Python
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copier le code du serveur
COPY server.py .
COPY calculator_pb2.py .
COPY calculator_pb2_grpc.py .

EXPOSE 50051

CMD ["python", "server.py"]
