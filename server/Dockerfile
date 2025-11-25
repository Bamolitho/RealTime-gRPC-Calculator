FROM python:3.10-slim

WORKDIR /app

COPY server/requirements.txt .

RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

COPY server/server.py .
COPY server/calculator_pb2.py .
COPY server/calculator_pb2_grpc.py .

EXPOSE 50051

CMD ["python3", "server.py"]
