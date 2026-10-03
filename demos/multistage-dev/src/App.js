import React, {useState} from 'react';

function App() {
  const [count, setCount] = useState(0);
  return (
    <div className="container">
      <div className="card text-center">
        <div className="card-body">
          <h1>Counter App</h1>
          <div>
            <h2>{count}</h2>
            <button className="btn btn-success" onClick={() => setCount(count + 1)} style={{marginRight: '10px'}}>Increment</button>
            <button className="btn btn-danger" disabled={count === 0} onClick={() => setCount(count - 1)} style={{marginRight: '10px'}}>Decrement</button>
            <button className="btn btn-secondary" disabled={count === 0} onClick={() => setCount(0)}>Reset</button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
