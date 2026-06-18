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
