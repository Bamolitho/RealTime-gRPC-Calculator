// Vérifier que tout est chargé
console.log('Checking dependencies...');
console.log('grpc available:', typeof grpc !== 'undefined');
console.log('proto available:', typeof proto !== 'undefined');

if (typeof proto === 'undefined' || typeof proto.calculator === 'undefined') {
  console.error('Proto files not loaded correctly!');
  document.getElementById('output').innerHTML = 
    '<li style="background: #ffebee; border-color: #f44336;"> Error: Proto files not loaded. Check console for details.</li>';
}

// Créer le client gRPC-Web
const { CalculatorClient } = proto.calculator;
const { StreamRequest, Numbers } = proto.calculator;

const client = new CalculatorClient('http://localhost:8080', null, null);

// Fonction pour démarrer le streaming
document.getElementById('stream').onclick = () => {
  const output = document.getElementById('output');
  
  const base = parseFloat(document.getElementById('base').value);
  const operand = parseFloat(document.getElementById('operand').value);
  const operation = document.getElementById('operation').value;
  const count = parseInt(document.getElementById('count').value);
  
  const req = new StreamRequest();
  req.setBase(base);
  req.setCount(count);
  req.setOperation(operation);
  req.setOperand(operand);
  
  output.innerHTML += `<li style="background: #e7f3ff; border-color: #2196F3;">
     Starting stream: ${base} ${operation} ${operand} (${count} steps)
  </li>`;
  
  const stream = client.streamCalculations(req, {});
  
  stream.on('data', (response) => {
    const step = response.getStep();
    const value = response.getValue();
    output.innerHTML += `<li>Step ${step}: <strong>${value}</strong></li>`;
    window.scrollTo(0, document.body.scrollHeight);
  });
  
  stream.on('error', (err) => {
    output.innerHTML += `<li style="background: #ffebee; border-color: #f44336;">
      Error: ${err.message}
    </li>`;
    console.error('Stream error:', err);
  });
  
  stream.on('end', () => {
    output.innerHTML += `<li style="background: #e8f5e9; border-color: #4caf50;">
      Stream completed!
    </li>`;
  });
};

document.getElementById('clear').onclick = () => {
  document.getElementById('output').innerHTML = '';
};

// Test de connexion
window.onload = () => {
  console.log('gRPC-Web Client loaded');
  
  const testReq = new Numbers();
  testReq.setNum1(5);
  testReq.setNum2(3);
  
  client.add(testReq, {}, (err, response) => {
    if (err) {
      console.error('Connection test failed:', err);
    } else {
      console.log('Connection test successful! 5 + 3 =', response.getValue());
    }
  });
};
