import { useState, useMemo, useCallback, useRef } from "react";
import { ComposableMap, Geographies, Geography, ZoomableGroup } from "react-simple-maps";
import { useNavigate } from "react-router-dom";
import { useInfiniteQuery } from "@tanstack/react-query";
import {
  Map,
  X,
  ExternalLink,
  GitBranch,
  Loader2,
  AlertTriangle,
  ChevronDown,
  Plus,
  Minus,
  RotateCcw,
  CheckCircle2,
  MinusCircle,
} from "lucide-react";
import { useAuthStore } from "../store/auth";
import { getProcesses } from "../lib/api";
import type { Relationship } from "../lib/types";

// ── Constants ─────────────────────────────────────────────────────────────────

const GEO_URL = "https://cdn.jsdelivr.net/npm/world-atlas@2/countries-110m.json";

// ISO 3166-1 numeric codes used by world-atlas TopoJSON
const COUNTRY_NAME_TO_NUM: Record<string, string> = {
  Afghanistan: "4", Albania: "8", Algeria: "12", Angola: "24", Argentina: "32",
  Armenia: "51", Australia: "36", Austria: "40", Azerbaijan: "31", Bahrain: "48",
  Bangladesh: "50", Belarus: "112", Belgium: "56", Belize: "84", Benin: "204",
  Bhutan: "64", Bolivia: "68", "Bosnia and Herzegovina": "70", Botswana: "72",
  Brazil: "76", Brunei: "96", Bulgaria: "100", "Burkina Faso": "854", Burundi: "108",
  Cambodia: "116", Cameroon: "120", Canada: "124", "Central African Republic": "140",
  Chad: "148", Chile: "152", China: "156", Colombia: "170", Congo: "178",
  "Costa Rica": "188", Croatia: "191", Cuba: "192", Cyprus: "196",
  "Czech Republic": "203", Czechia: "203", Denmark: "208", Djibouti: "262",
  "Dominican Republic": "214", Ecuador: "218", Egypt: "818", "El Salvador": "222",
  Eritrea: "232", Estonia: "233", Ethiopia: "231", Fiji: "242", Finland: "246",
  France: "250", Gabon: "266", Gambia: "270", Georgia: "268", Germany: "276",
  Ghana: "288", Greece: "300", Guatemala: "320", Guinea: "324", Guyana: "328",
  Haiti: "332", Honduras: "340", Hungary: "348", Iceland: "352", India: "356",
  Indonesia: "360", Iran: "364", Iraq: "368", Ireland: "372", Israel: "376",
  Italy: "380", Jamaica: "388", Japan: "392", Jordan: "400", Kazakhstan: "398",
  Kenya: "404", Kuwait: "414", Kyrgyzstan: "417", Laos: "418", Latvia: "428",
  Lebanon: "422", Lesotho: "426", Liberia: "430", Libya: "434", Lithuania: "440",
  Luxembourg: "442", Madagascar: "450", Malawi: "454", Malaysia: "458",
  Maldives: "462", Mali: "466", Malta: "470", Mauritania: "478", Mauritius: "480",
  Mexico: "484", Moldova: "498", Mongolia: "496", Montenegro: "499",
  Morocco: "504", Mozambique: "508", Myanmar: "104", Namibia: "516", Nepal: "524",
  Netherlands: "528", "New Zealand": "554", Nicaragua: "558", Niger: "562",
  Nigeria: "566", "North Korea": "408", "North Macedonia": "807", Norway: "578",
  Oman: "512", Pakistan: "586", Panama: "591", "Papua New Guinea": "598",
  Paraguay: "600", Peru: "604", Philippines: "608", Poland: "616", Portugal: "620",
  Qatar: "634", Romania: "642", Russia: "643", "Russian Federation": "643",
  Rwanda: "646", "Saudi Arabia": "682", Senegal: "686", Serbia: "688",
  "Sierra Leone": "694", Singapore: "702", Slovakia: "703", Slovenia: "705",
  Somalia: "706", "South Africa": "710", "South Korea": "410", "South Sudan": "728",
  Spain: "724", "Sri Lanka": "144", Sudan: "729", Suriname: "740", Sweden: "752",
  Switzerland: "756", Syria: "760", Taiwan: "158", Tajikistan: "762",
  Tanzania: "834", Thailand: "764", Togo: "768", Tunisia: "788", Turkey: "792",
  "Türkiye": "792", Turkmenistan: "795", Uganda: "800", Ukraine: "804",
  "United Arab Emirates": "784", "United Kingdom": "826", "United States": "840",
  "United States of America": "840", Uruguay: "858", Uzbekistan: "860",
  Venezuela: "862", Vietnam: "704", Yemen: "887", Zambia: "894", Zimbabwe: "716",
};

// ── Helpers ───────────────────────────────────────────────────────────────────

function resolveIsoNum(name: string | null | undefined): string | null {
  if (!name) return null;
  const num = COUNTRY_NAME_TO_NUM[name.trim()] ?? COUNTRY_NAME_TO_NUM[name.trim().split(",")[0]] ?? null;
  return num ? num.padStart(3, "0") : null;
}

function groupByPtn(rows: Relationship[]): { ptn: string; rows: Relationship[] }[] {
  const groups: { ptn: string; rows: Relationship[] }[] = [];
  for (const row of rows) {
    const ptn = row.PTN_no ?? "—";
    const last = groups[groups.length - 1];
    if (last && last.ptn === ptn) last.rows.push(row);
    else groups.push({ ptn, rows: [row] });
  }
  return groups;
}

function fmtDate(ts: number | null): string {
  if (!ts) return "—";
  return new Date(ts).toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
}

// ── Country detail panel ───────────────────────────────────────────────────────

interface CountryPanelProps {
  countryName: string;
  rows: Relationship[];
  isHome: boolean;
  onClose: () => void;
}

function CountryPanel({ countryName, rows, isHome, onClose }: CountryPanelProps) {
  const navigate = useNavigate();
  const groups = groupByPtn(rows);

  return (
    <div className="flex h-full flex-col">
      {/* Header */}
      <div
        className="flex items-center justify-between px-5 py-4"
        style={{ background: isHome ? "#1d2428" : "#5e90c0" }}
      >
        <div className="flex items-center gap-2">
          <Map size={16} className="text-white/80" />
          <div>
            <p className="text-sm font-bold text-white leading-tight">{countryName}</p>
            <p className="text-[11px] text-white/60 mt-0.5">
              {isHome ? "Home country · " : ""}
              {rows.length} process{rows.length !== 1 ? "es" : ""} · {groups.length} PTN{groups.length !== 1 ? "s" : ""}
            </p>
          </div>
        </div>
        <button
          onClick={onClose}
          className="rounded-full p-1 text-white/70 hover:bg-white/10 hover:text-white transition"
        >
          <X size={16} />
        </button>
      </div>

      {/* PTN list */}
      <div className="flex-1 overflow-y-auto">
        {groups.map((group) => (
          <div key={group.ptn} className="border-b border-slate-100 last:border-0">
            {/* PTN band */}
            <div className="flex items-center justify-between bg-slate-50 px-5 py-2.5">
              <div className="flex items-center gap-2">
                <GitBranch size={13} className="text-[#5e90c0] shrink-0" />
                <span className="text-xs font-semibold text-[#1d2428] truncate">{group.ptn}</span>
              </div>
              <button
                onClick={() => navigate(`/processes?search=${encodeURIComponent(group.ptn)}`)}
                className="flex items-center gap-1 text-[11px] text-[#5e90c0] hover:underline shrink-0 ml-2"
              >
                <ExternalLink size={11} />
                View
              </button>
            </div>

            {/* Rows */}
            {group.rows.map((row) => {
              const hasSla = !!row.sla?.url;
              return (
                <div key={row.id} className="px-5 py-3 hover:bg-slate-50 transition">
                  <div className="flex items-start justify-between gap-2">
                    <div className="min-w-0 flex-1">
                      <p className="text-xs text-[#1d2428] truncate font-medium">
                        {row.desc?.trim() || "No description"}
                      </p>
                      <div className="mt-1 flex flex-wrap items-center gap-x-3 gap-y-0.5 text-[10px] text-slate-400">
                        {row.functionInfo?.function && (
                          <span>{row.functionInfo.function}</span>
                        )}
                        {row.dataOwner?.Company_Name && (
                          <span>Owner: {row.dataOwner.Company_Name}</span>
                        )}
                        {row.processor?.Company_Name && (
                          <span>Processor: {row.processor.Company_Name}</span>
                        )}
                        <span>{fmtDate(row.created_at)}</span>
                      </div>
                    </div>
                    <div className="shrink-0 mt-0.5">
                      {hasSla ? (
                        <a href={row.sla!.url} target="_blank" rel="noreferrer" title="View SLA">
                          <CheckCircle2 size={15} className="text-emerald-500" />
                        </a>
                      ) : (
                        <span title="No SLA"><MinusCircle size={15} className="text-red-400/70" /></span>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        ))}
      </div>

      {/* Footer link */}
      <div className="border-t border-slate-100 px-5 py-3">
        <button
          onClick={() => navigate("/processes")}
          className="flex w-full items-center justify-center gap-1.5 rounded-lg border border-slate-200 py-2 text-xs font-medium text-[#5e90c0] hover:border-[#5e90c0] hover:bg-[#5e90c0]/5 transition"
        >
          <GitBranch size={13} />
          View all processes
        </button>
      </div>
    </div>
  );
}

// ── Tooltip ───────────────────────────────────────────────────────────────────

interface TooltipState {
  x: number;
  y: number;
  name: string;
  count: number;
  isHome: boolean;
}

// ── Main page ─────────────────────────────────────────────────────────────────

export default function ProcessMaps() {
  const company = useAuthStore((s) => s.selectedCompany);
  const navigate = useNavigate();

  const homeCountryName =
    typeof company?.country_code === "object" && company?.country_code !== null
      ? (company.country_code as { name?: string }).name ?? null
      : null;
  const homeIsoNum = resolveIsoNum(homeCountryName);

  // Fetch all processes (large perPage to get them all in one shot)
  const { data, isLoading, isError, fetchNextPage, hasNextPage } = useInfiniteQuery({
    queryKey: ["processes-map", company?.id],
    enabled: !!company?.id,
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      getProcesses({ companyId: company!.id, page: pageParam, perPage: 200 }),
    getNextPageParam: (lastPage) => lastPage.nextPage ?? undefined,
  });

  // Auto-fetch remaining pages
  const allRows = useMemo(() => data?.pages.flatMap((p) => p.items) ?? [], [data]);
  if (hasNextPage && !isLoading) {
    fetchNextPage();
  }

  // Build: isoNum → rows
  const countryMap = useMemo(() => {
    const map: Record<string, Relationship[]> = {};
    for (const row of allRows) {
      const name = row.countryInfo?.Name;
      const isoNum = resolveIsoNum(name);
      if (!isoNum || !name) continue;
      if (!map[isoNum]) map[isoNum] = [];
      map[isoNum].push(row);
    }
    return map;
  }, [allRows]);

  // Unique country names for PTN filter
  const allPtns = useMemo(
    () =>
      [...new Set(allRows.map((r) => r.PTN_no).filter((p): p is string => !!p))].sort(),
    [allRows]
  );

  // Filtered by PTN
  const [selectedPtn, setSelectedPtn] = useState<string>("all");
  const [ptnOpen, setPtnOpen] = useState(false);
  const ptnRef = useRef<HTMLDivElement>(null);

  const filteredCountryMap = useMemo((): Record<string, Relationship[]> => {
    if (selectedPtn === "all") return countryMap;
    const filtered: Record<string, Relationship[]> = {};
    for (const [iso, rows] of Object.entries(countryMap)) {
      const match = rows.filter((r) => r.PTN_no === selectedPtn);
      if (match.length) filtered[iso] = match;
    }
    return filtered;
  }, [countryMap, selectedPtn]);

  // Zoom
  const [zoom, setZoom] = useState(1);
  const [center, setCenter] = useState<[number, number]>([15, 20]);

  // Tooltip
  const [tooltip, setTooltip] = useState<TooltipState | null>(null);

  // Selected country for detail panel
  const [selectedCountry, setSelectedCountry] = useState<{
    name: string;
    isoNum: string;
  } | null>(null);

  const handleMouseEnter = useCallback(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (geo: any, evt: React.MouseEvent) => {
      const rows: Relationship[] | undefined = filteredCountryMap[String(geo.id)];
      if (!rows?.length && String(geo.id) !== homeIsoNum) return;
      setTooltip({
        x: evt.clientX,
        y: evt.clientY,
        name: geo.properties.name,
        count: rows?.length ?? 0,
        isHome: String(geo.id) === homeIsoNum,
      });
    },
    [filteredCountryMap, homeIsoNum]
  );

  const handleMouseMove = useCallback((evt: React.MouseEvent) => {
    setTooltip((t) => (t ? { ...t, x: evt.clientX, y: evt.clientY } : null));
  }, []);

  const handleMouseLeave = useCallback(() => {
    setTooltip(null);
  }, []);

  const handleCountryClick = useCallback(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (geo: any) => {
      const isoNum = String(geo.id);
      const rows: Relationship[] | undefined = filteredCountryMap[isoNum];
      if (!rows?.length && isoNum !== homeIsoNum) return;
      setTooltip(null);
      setSelectedCountry({ name: geo.properties.name, isoNum });
    },
    [filteredCountryMap, homeIsoNum]
  );

  const selectedRows = selectedCountry ? (filteredCountryMap[selectedCountry.isoNum] ?? []) : [];
  const processedCountries = Object.keys(filteredCountryMap).length;
  const totalShown = allRows.filter((r) => selectedPtn === "all" || r.PTN_no === selectedPtn).length;

  return (
    <div className="flex h-[calc(100vh-56px-48px)] flex-col">
      {/* ── Header bar ─────────────────────────────────────────────────────── */}
      <div className="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between shrink-0">
        <div>
          <h1 className="flex items-center gap-2 text-xl font-bold text-[#1d2428]">
            <Map size={20} className="text-[#5e90c0]" />
            Process Maps
          </h1>
          <p className="mt-0.5 text-xs text-slate-400">
            {isLoading
              ? "Loading processes…"
              : `${processedCountries} countr${processedCountries !== 1 ? "ies" : "y"} · ${totalShown} process${totalShown !== 1 ? "es" : ""}`}
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* PTN filter */}
          <div className="relative" ref={ptnRef}>
            <button
              onClick={() => setPtnOpen((o) => !o)}
              className="flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-medium text-[#1d2428] hover:border-[#5e90c0] transition min-w-[160px] justify-between"
            >
              <span className="truncate">
                {selectedPtn === "all" ? "All Processes" : selectedPtn}
              </span>
              <ChevronDown size={13} className={`shrink-0 transition ${ptnOpen ? "rotate-180" : ""}`} />
            </button>
            {ptnOpen && (
              <div className="absolute right-0 top-full z-50 mt-1 max-h-56 w-52 overflow-y-auto rounded-xl border border-slate-200 bg-white shadow-lg">
                <button
                  onClick={() => { setSelectedPtn("all"); setPtnOpen(false); }}
                  className={`flex w-full items-center px-3 py-2.5 text-xs hover:bg-slate-50 transition ${selectedPtn === "all" ? "font-semibold text-[#5e90c0]" : "text-[#1d2428]"}`}
                >
                  All Processes
                </button>
                {allPtns.map((ptn) => (
                  <button
                    key={ptn}
                    onClick={() => { setSelectedPtn(ptn); setPtnOpen(false); }}
                    className={`flex w-full items-center gap-2 px-3 py-2.5 text-xs hover:bg-slate-50 transition ${selectedPtn === ptn ? "font-semibold text-[#5e90c0]" : "text-[#1d2428]"}`}
                  >
                    <GitBranch size={11} className="shrink-0 text-[#5e90c0]" />
                    <span className="truncate">{ptn}</span>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* ── Map + Panel ────────────────────────────────────────────────────── */}
      <div className="flex flex-1 gap-4 min-h-0">
        {/* Map container */}
        <div
          className="relative flex-1 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm"
          onClick={() => setPtnOpen(false)}
        >
          {/* Loading overlay */}
          {isLoading && (
            <div className="absolute inset-0 z-10 flex flex-col items-center justify-center gap-3 bg-white/80 backdrop-blur-sm">
              <Loader2 size={28} className="animate-spin text-[#5e90c0]" />
              <p className="text-xs text-slate-400">Loading process data…</p>
            </div>
          )}

          {isError && (
            <div className="absolute inset-0 z-10 flex flex-col items-center justify-center gap-2 bg-white">
              <AlertTriangle size={24} className="text-red-400" />
              <p className="text-xs text-slate-400">Could not load processes.</p>
            </div>
          )}

          {/* Zoom controls */}
          <div className="absolute bottom-4 right-4 z-20 flex flex-col gap-1">
            <button
              onClick={() => setZoom((z) => Math.min(z * 1.5, 8))}
              className="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 bg-white shadow-sm hover:border-[#5e90c0] hover:text-[#5e90c0] transition"
            >
              <Plus size={14} />
            </button>
            <button
              onClick={() => setZoom((z) => Math.max(z / 1.5, 1))}
              className="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 bg-white shadow-sm hover:border-[#5e90c0] hover:text-[#5e90c0] transition"
            >
              <Minus size={14} />
            </button>
            <button
              onClick={() => { setZoom(1); setCenter([15, 20]); }}
              className="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 bg-white shadow-sm hover:border-[#5e90c0] hover:text-[#5e90c0] transition"
            >
              <RotateCcw size={14} />
            </button>
          </div>

          {/* Legend */}
          <div className="absolute bottom-4 left-4 z-20 flex flex-col gap-1.5 rounded-xl border border-slate-200 bg-white px-3 py-2.5 shadow-sm">
            <div className="flex items-center gap-2">
              <div className="h-3 w-5 rounded-sm" style={{ background: "#5e90c0" }} />
              <span className="text-[10px] text-slate-500">Has processes</span>
            </div>
            {homeCountryName && (
              <div className="flex items-center gap-2">
                <div className="h-3 w-5 rounded-sm" style={{ background: "#1d2428" }} />
                <span className="text-[10px] text-slate-500">Home country</span>
              </div>
            )}
            <div className="flex items-center gap-2">
              <div className="h-3 w-5 rounded-sm bg-slate-200" />
              <span className="text-[10px] text-slate-500">No processes</span>
            </div>
          </div>

          {/* Map */}
          <ComposableMap
            projection="geoMercator"
            projectionConfig={{ scale: 140, center: [0, 20] }}
            style={{ width: "100%", height: "100%" }}
          >
            {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
            <ZoomableGroup zoom={zoom} center={center} onMoveEnd={(pos: any) => { setZoom(pos.zoom); setCenter(pos.coordinates); }}>
              <Geographies geography={GEO_URL}>
                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                {({ geographies }: { geographies: any[] }) =>
                  geographies.map((geo) => {
                    const isoNum = String(geo.id);
                    const isHome = isoNum === homeIsoNum;
                    const rows: Relationship[] | undefined = filteredCountryMap[isoNum];
                    const hasProcesses = (rows?.length ?? 0) > 0;
                    const isSelected = selectedCountry?.isoNum === isoNum;

                    let fill = "#e2e8f0";
                    if (isHome && hasProcesses) fill = "#2d5a8a";
                    else if (isHome) fill = "#1d2428";
                    else if (hasProcesses) fill = "#5e90c0";

                    const isClickable = hasProcesses || isHome;

                    return (
                      <Geography
                        key={geo.rsmKey}
                        geography={geo}
                        fill={isSelected ? (isHome ? "#3a7abf" : "#4a7ab5") : fill}
                        stroke="#ffffff"
                        strokeWidth={0.5}
                        style={{
                          default: { outline: "none", cursor: isClickable ? "pointer" : "default" },
                          hover: {
                            fill: isClickable ? (isHome ? "#2d3f4a" : "#4a7ab5") : "#d1d9e0",
                            outline: "none",
                            cursor: isClickable ? "pointer" : "default",
                            transition: "fill 150ms ease",
                          },
                          pressed: { outline: "none" },
                        }}
                        onMouseEnter={(e: React.MouseEvent) => handleMouseEnter(geo, e)}
                        onMouseMove={handleMouseMove}
                        onMouseLeave={handleMouseLeave}
                        onClick={() => handleCountryClick(geo)}
                      />
                    );
                  })
                }
              </Geographies>
            </ZoomableGroup>
          </ComposableMap>
        </div>

        {/* Detail panel */}
        {selectedCountry && (
          <div
            className="w-80 shrink-0 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm"
            style={{ animation: "slideIn 200ms ease" }}
          >
            <CountryPanel
              countryName={selectedCountry.name}
              rows={selectedRows}
              isHome={selectedCountry.isoNum === homeIsoNum}
              onClose={() => setSelectedCountry(null)}
            />
            {selectedRows.length === 0 && (
              <div className="flex flex-col items-center justify-center py-12 text-slate-400">
                <Map size={24} className="mb-2 opacity-30" />
                <p className="text-xs">This is your home country.</p>
                <p className="mt-1 text-xs">No processes assigned here.</p>
                <button
                  onClick={() => navigate("/processes")}
                  className="mt-4 flex items-center gap-1.5 text-xs text-[#5e90c0] hover:underline"
                >
                  <ExternalLink size={11} />
                  View all processes
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Floating tooltip */}
      {tooltip && (
        <div
          className="pointer-events-none fixed z-50 rounded-xl border border-slate-200 bg-white px-3 py-2 shadow-lg"
          style={{ left: tooltip.x + 14, top: tooltip.y - 36 }}
        >
          <p className="text-xs font-semibold text-[#1d2428]">{tooltip.name}</p>
          {tooltip.isHome && (
            <p className="text-[10px] text-slate-400">Home country</p>
          )}
          {tooltip.count > 0 && (
            <p className="text-[10px] text-[#5e90c0]">
              {tooltip.count} process{tooltip.count !== 1 ? "es" : ""}
            </p>
          )}
          <p className="mt-0.5 text-[10px] text-slate-300">Click to view details</p>
        </div>
      )}

      <style>{`
        @keyframes slideIn {
          from { opacity: 0; transform: translateX(16px); }
          to   { opacity: 1; transform: translateX(0);    }
        }
      `}</style>
    </div>
  );
}
