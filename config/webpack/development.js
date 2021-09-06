process.env.NODE_ENV = process.env.NODE_ENV || "development";

const environment = require("./environment");

const webpack = require("webpack");

environment.plugins.append(
  "env",
  new webpack.DefinePlugin({
    "process.env.HOST": JSON.stringify("localhost:3000"),
    "process.env.API_URL": JSON.stringify("https://www.xyz.com/"),
  })
);

module.exports = environment.toWebpackConfig();
