import { CalculatorClient } from "./calculator_grpc_web_pb.js";
import { StreamRequest } from "./calculator_pb.js";

const client = new CalculatorClient("http://localhost:8080");

document.getElementById("stream").onclick = () => {
    const req = new StreamRequest();
    req.setBase(1);
    req.setCount(5);
    req.setOperation("add");
    req.setOperand(3);

    const stream = client.streamCalculations(req, {});

    stream.on("data", function(response) {
        document.getElementById("output").innerHTML +=
            `<li>Step ${response.getStep()}: ${response.getValue()}</li>`;
    });
};
