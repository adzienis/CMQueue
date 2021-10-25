const sassPlugin = require("esbuild-sass-plugin");

//    "build": "esbuild app/javascript/*.* --minify --bundle --outdir=app/assets/builds",
//    "watch": "esbuild app/javascript/*.* --watch --bundle --outdir=app/assets/builds"

require("esbuild")
  .build({
    entryPoints: ["app/javascript/packs/application.js"],
    bundle: true,
    watch: true,
    outfile: "app/assets/builds/application.js",
    plugins: [sassPlugin.sassPlugin()],
    define: {
      "process.env.NODE_ENV": '"development"',
    },
  })
  .catch(() => process.exit(1));
