# ==============================
# Dockerfile - client-python
# ==============================
FROM python:3.10-slim

WORKDIR /app

# Installer les dépendances
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copier le code client
COPY client.py .
COPY calculator_pb2.py .
COPY calculator_pb2_grpc.py .

CMD ["python", "client.py"]
