const express = require('express');
const app = express();
app.use(express.json());

app.get('/orgs/:owner/members/:member_name', (req, res) => {
  console.log(`Mock intercepted: GET /orgs/${req.params.owner}/members/${req.params.member_name}`);
  console.log('Request headers:', JSON.stringify(req.headers));

  // Simulate different responses based on member_name or owner
  if (req.params.member_name === 'test-user' && req.params.owner === 'test-owner') {
    res.status(204).send();
  } else {
    res.status(404).json({ message: 'Not Found' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
