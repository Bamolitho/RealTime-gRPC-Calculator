import grpc
import calculator_pb2
import calculator_pb2_grpc

def unary_example():
    channel = grpc.insecure_channel("server:50051")
    stub = calculator_pb2_grpc.CalculatorStub(channel)

    response = stub.Add(calculator_pb2.Numbers(num1=10, num2=20))
    print("Add =>", response.value)

def streaming_example():
    channel = grpc.insecure_channel("server:50051")
    stub = calculator_pb2_grpc.CalculatorStub(channel)

    req = calculator_pb2.StreamRequest(
        base=1,
        count=5,
        operation="mul",
        operand=2
    )

    responses = stub.StreamCalculations(req)
    for r in responses:
        print(f"Step {r.step}: value={r.value}")

if __name__ == "__main__":
    unary_example()
    streaming_example()
