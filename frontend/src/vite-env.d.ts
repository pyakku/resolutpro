/// <reference types="vite/client" />

declare module "react-simple-maps";

interface ImportMetaEnv {
  readonly VITE_XANO_BASE_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
