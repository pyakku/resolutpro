// Shapes returned by the Xano `resolut_apis` group.

/** GET auth/me */
export interface User {
  id: number;
  name: string | null;
  l_name: string | null;
  email: string;
  user_id: string | null;
  profile_img: string | null;
  language: string | null;
  date_format: string | null;
  is_admin: boolean | null;
  plan: number | null;
  business_dev: boolean | null;
  completed_walkthrough: boolean | null;
}

export interface Country {
  id: number;
  name?: string;
  [key: string]: unknown;
}

/** A company record (addon-expanded inside the company option). */
export interface Company {
  id: number;
  Company_Name: string | null;
  company_reg: string | null;
  industry: string | null;
  city: string | null;
  state: string | null;
  country: string | null;
  profile_link: string | null;
  individual: boolean | null;
  country_code: Country | null;
  plan: { id: number; name?: string } | number | null;
  [key: string]: unknown;
}

/** GET dashboard/stats/numbers */
export interface DashboardStats {
  processes: number;
  products: number;
  documents: number;
  validatedDocuments: number;
  rejectedDocuments: number;
  archivedDocuments: number;
  audits: number;
  users: number;
  contacts: number;
  certificates: number;
  policies: number;
  expiredDocuments: number;
}

/**
 * GET company_of_current_user_v2_ff returns a list of subscription rows, each
 * decorated with the expanded `company` and a top-level `companyName`.
 */
export interface CompanyOption {
  id: number; // subscription id
  company: Company;
  companyName: string | null;
  individual: boolean | null;
  active?: boolean | null;
  [key: string]: unknown;
}

// ── Documents ──────────────────────────────────────────────────────────────────

/** Server-side sort field + direction for the documents list. */
export type DocumentSortBy = "name" | "issued" | "expires" | "created";
export type SortDir = "asc" | "desc";

/** The tab / server-side filter applied to the documents list. */
export type DocumentStatus =
  | "all"
  | "validated"
  | "rejected"
  | "expired"
  | "pending"
  | "archived";

/** A Xano `attachment` field value. */
export interface XanoFile {
  url: string;
  name?: string | null;
  /** MIME type, e.g. "application/pdf". May be absent — fall back to the name's extension. */
  mime?: string | null;
  type?: string | null;
  size?: number | null;
  [key: string]: unknown;
}

/** A row from `myDocuments`, addon-expanded, as returned by GET documents/list. */
export interface MyDocument {
  id: number;
  nameUA: string | null;
  /**
   * The `documents` addon, expanded as `documentInfo` (not `document`, which
   * would collide with the myDocuments.document FK int column). Its nested
   * `document_types` addon expands as `typeInfo`.
   */
  documentInfo: {
    id: number;
    documentName?: string | null;
    typeInfo?: { id: number; type?: string | null } | null;
  } | null;
  file: XanoFile | null;
  issueDate: number | null;
  expiryDate: number | null;
  validationDate: number | null;
  validated: boolean | null;
  rejected: boolean | null;
  archived: boolean | null;
  noExpiry: boolean | null;
  issuedBy: string | null;
  /**
   * The contacts addon, expanded as `holderInfo` (per-row via the `items.`
   * prefix). Null when the document has no holder contact — in that case the
   * holder is the current company.
   */
  holderInfo: { name?: string | null; l_name?: string | null } | null;
  validationComments: string | null;
  [key: string]: unknown;
}

// ── Processes (relationships) ────────────────────────────────────────────────

/** A company reference expanded inside a relationship (only id + name needed). */
export interface CompanyRef {
  id: number;
  Company_Name?: string | null;
}

/**
 * A row from `relationships`, addon-expanded, as returned by GET processes/list.
 * Each process belongs to a PTN "chain" (rows sharing the same `PTN_no`). The
 * three company roles: `dataOwner` originates the data, `assignedBy` assigns the
 * process, `processor` (assigned_to) carries it out.
 */
export interface Relationship {
  id: number;
  created_at: number;
  PTN_no: string | null;
  desc: string | null;
  approved: boolean | null;
  terminated: boolean | null;
  /** PTN this row replaces in its chain (empty when it's the original). */
  replaces: string | null;
  /** Service-level agreement file; presence drives the SLA indicator. */
  sla: XanoFile | null;
  countryInfo: { id: number; Name?: string | null } | null;
  functionInfo: { id: number; function?: string | null } | null;
  dataOwner: CompanyRef | null;
  assignedBy: CompanyRef | null;
  processor: CompanyRef | null;
  [key: string]: unknown;
}

/**
 * Xano paged envelope from GET processes/list. Like documents/list, the paging
 * metadata does NOT include `itemsTotal` — the client lazy-loads via `nextPage`.
 */
export interface ProcessesPage {
  items: Relationship[];
  itemsReceived: number;
  curPage: number;
  nextPage: number | null;
  prevPage: number | null;
  pageTotal: number;
}

// ── Veritas AI assistant ─────────────────────────────────────────────────────

export type VeritasRole = "user" | "assistant";

/** A persisted Veritas chat message (table veritas_messages). */
export interface VeritasMessage {
  id: number;
  created_at: number;
  role: VeritasRole;
  content: string;
  /** Documents surfaced by the assistant's tool calls this turn (assistant rows only). */
  documents?: MyDocument[] | null;
  /** Processes (PTNs) surfaced by the assistant's tool calls this turn (assistant rows only). */
  relationships?: Relationship[] | null;
}

/** Xano paged envelope from GET veritas/messages (newest-first). No itemsTotal. */
export interface VeritasMessagesPage {
  items: VeritasMessage[];
  itemsReceived: number;
  curPage: number;
  nextPage: number | null;
  prevPage: number | null;
  pageTotal: number;
}

/** GET veritas/history_status — whether the user has prior history for a company. */
export interface VeritasHistoryStatus {
  hasHistory: boolean;
  total: number;
}

/** POST veritas/chat response. */
export interface VeritasChatReply {
  reply: string;
  message: VeritasMessage;
  documents: MyDocument[];
  relationships: Relationship[];
}

/**
 * Xano paged envelope returned by GET documents/list. NOTE: this endpoint's
 * paging metadata does NOT include `itemsTotal` — the client shows the loaded
 * count instead and relies on `nextPage` to drive lazy-loading.
 */
export interface DocumentsPage {
  items: MyDocument[];
  itemsReceived: number;
  curPage: number;
  /** Next page number, or null when on the last page. */
  nextPage: number | null;
  prevPage: number | null;
  pageTotal: number;
}
