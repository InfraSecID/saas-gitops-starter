// workloads/backend/src/app.ts — Aplikasi Express utama dengan rate-limiting, Helmet, dan Zod validator
import express, { Express, Request, Response, NextFunction } from "express";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import { z, ZodSchema } from "zod";

export interface TenantInfoResponse {
  tenant: string;
  tier: "basic" | "pro";
  storagePartitionPrefix: string;
  status: string;
  timestamp: string;
}

const emptyQuerySchema = z.object({}).strict();

const infoQuerySchema = z
  .object({
    format: z.enum(["json", "compact"]).optional()
  })
  .strict();

function validateQuery<T>(schema: ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const parsed = schema.safeParse(req.query);
    if (!parsed.success) {
      res.status(400).json({
        error: "Invalid query parameters",
        details: parsed.error.issues.map((issue) => ({
          path: issue.path.join("."),
          message: issue.message
        }))
      });
      return;
    }
    next();
  };
}

export function createApp(): Express {
  const app = express();

  app.disable("x-powered-by");
  app.use(helmet());
  app.use(express.json({ limit: "16kb" }));

  const limiter = rateLimit({
    windowMs: 60 * 1000,
    max: 100,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: "Too many requests, please try again later." }
  });

  app.use(limiter);

  app.get(
    "/healthz",
    validateQuery(emptyQuerySchema),
    (_req: Request, res: Response): void => {
      res.status(200).json({
        status: "ok",
        check: "liveness"
      });
    }
  );

  app.get(
    "/readyz",
    validateQuery(emptyQuerySchema),
    (_req: Request, res: Response): void => {
      const tenantName = process.env.TENANT_NAME ?? "unknown-tenant";
      const isReady = tenantName.trim().length > 0;

      if (!isReady) {
        res.status(503).json({
          status: "not_ready",
          check: "readiness"
        });
        return;
      }

      res.status(200).json({
        status: "ready",
        check: "readiness"
      });
    }
  );

  app.get(
    "/api/info",
    validateQuery(infoQuerySchema),
    (_req: Request, res: Response): void => {
      const rawTier = process.env.TENANT_TIER ?? "basic";
      const tier: "basic" | "pro" = rawTier === "pro" ? "pro" : "basic";
      const tenant = process.env.TENANT_NAME ?? "__TENANT_NAME__";
      const storagePartitionPrefix =
        process.env.STORAGE_PARTITION_PREFIX ??
        `s3://saas-shared-bucket/tenants/${tenant}/`;

      const payload: TenantInfoResponse = {
        tenant,
        tier,
        storagePartitionPrefix,
        status: "active",
        timestamp: new Date().toISOString()
      };

      res.status(200).json(payload);
    }
  );

  return app;
}
