// workloads/backend/tests/app.test.ts — Pengujian otomatis endpoint /healthz, /readyz, dan /api/info
import request from "supertest";
import { createApp } from "../src/app";

describe("SaaS Multi-Tenant Backend Starter Endpoints", () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = {
      ...originalEnv,
      TENANT_NAME: "alpha",
      TENANT_TIER: "basic",
      STORAGE_PARTITION_PREFIX: "s3://saas-shared-bucket/tenants/alpha/"
    };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it("GET /healthz returns 200 and liveness ok", async () => {
    const app = createApp();
    const res = await request(app).get("/healthz");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      status: "ok",
      check: "liveness"
    });
  });

  it("GET /readyz returns 200 when TENANT_NAME is configured", async () => {
    const app = createApp();
    const res = await request(app).get("/readyz");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({
      status: "ready",
      check: "readiness"
    });
  });

  it("GET /api/info returns tenant metadata and partition prefix", async () => {
    const app = createApp();
    const res = await request(app).get("/api/info?format=json");
    expect(res.status).toBe(200);
    expect(res.body.tenant).toBe("alpha");
    expect(res.body.tier).toBe("basic");
    expect(res.body.storagePartitionPrefix).toBe(
      "s3://saas-shared-bucket/tenants/alpha/"
    );
    expect(res.body.status).toBe("active");
  });

  it("GET /api/info rejects unknown query parameter with 400", async () => {
    const app = createApp();
    const res = await request(app).get("/api/info?malicious=1");
    expect(res.status).toBe(400);
    expect(res.body.error).toBe("Invalid query parameters");
  });
});
