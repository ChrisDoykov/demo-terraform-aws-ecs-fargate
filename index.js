const express = require("express");
const version = require("./package.json").version;

const app = express();
const PORT = process.env.PORT || 3000;
const SERVICE_NAME = process.env.SERVICE_NAME;

app.get("/health", (_, res) => {
  console.log("Health endpoint has been hit.");
  return res.status(200).send("OK");
});
app.get("/", (_, res) => {
  console.log("The / endpoint was hit.");
  return res.send(`It bloomin' works! Version: ${version} of ${SERVICE_NAME}`);
});

app.listen(PORT, () => console.log(`Demo Node API listening on port ${PORT}!`));
