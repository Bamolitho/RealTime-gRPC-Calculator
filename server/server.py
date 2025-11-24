import grpc
from concurrent import futures
import time
import calculator_pb2
import calculator_pb2_grpc

class CalculatorServicer(calculator_pb2_grpc.CalculatorServicer):

    def Add(self, request, context):
        result = request.num1 + request.num2
        return calculator_pb2.Result(value=result, operation="add", step=1)

    def Subtract(self, request, context):
        result = request.num1 - request.num2
        return calculator_pb2.Result(value=result, operation="sub", step=1)

    def Multiply(self, request, context):
        result = request.num1 * request.num2
        return calculator_pb2.Result(value=result, operation="mul", step=1)

    def Divide(self, request, context):
        if request.num2 == 0:
            context.abort(grpc.StatusCode.INVALID_ARGUMENT, "Division by zero")
        result = request.num1 / request.num2
        return calculator_pb2.Result(value=result, operation="div", step=1)

    def StreamCalculations(self, request, context):
        value = request.base
        for i in range(1, request.count + 1):
            if request.operation == "add":
                value += request.operand
            elif request.operation == "sub":
                value -= request.operand
            elif request.operation == "mul":
                value *= request.operand
            elif request.operation == "div":
                if request.operand == 0:
                    context.abort(grpc.StatusCode.INVALID_ARGUMENT, "Division by zero in stream")
                value /= request.operand

            time.sleep(1)

            yield calculator_pb2.Result(
                value=value,
                operation=request.operation,
                step=i
            )

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    calculator_pb2_grpc.add_CalculatorServicer_to_server(CalculatorServicer(), server)
    server.add_insecure_port("[::]:50051")
    print("gRPC server running on port 50051")
    server.start()
    server.wait_for_termination()

if __name__ == "__main__":
    serve()
