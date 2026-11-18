// workloads/backend/src/index.ts — Entrypoint server HTTP untuk backend SaaS multi-tenant
import { createApp } from "./app";

const portValue = Number(process.env.PORT ?? "3000");
const port = Number.isNaN(portValue) ? 3000 : portValue;

const app = createApp();

const server = app.listen(port, () => {
  const tenant = process.env.TENANT_NAME ?? "__TENANT_NAME__";
  const tier = process.env.TENANT_TIER ?? "basic";
  process.stdout.write(
    JSON.stringify({
      level: "info",
      message: "SaaS tenant backend listening",
      tenant,
      tier,
      port
    }) + "\n"
  );
});

process.on("SIGTERM", () => {
  server.close(() => {
    process.exit(0);
  });
});
