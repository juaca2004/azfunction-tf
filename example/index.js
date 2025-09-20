//Debido que las funciones de azure no se pueden subir directamente a AKS, convertimos tu Azure Function en una aplicación Express.js
const express = require('express');
const app = express();
app.use(express.json());

app.all('/', (req, res) => {
    const name = req.query.name || req.body?.name;
    const responseMessage = name
        ? { id: name }
        : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";
    res.send(responseMessage);
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
