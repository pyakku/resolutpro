import { useEffect, useMemo, useRef, useState } from "react";
import { useInfiniteQuery, useMutation, useQuery } from "@tanstack/react-query";
import { Send, Loader2, History, Sparkles, FileText, Eye } from "lucide-react";
import {
  getVeritasHistoryStatus,
  getVeritasMessages,
  sendVeritasMessage,
  errorMessage,
} from "../../lib/api";
import type { MyDocument, VeritasMessage } from "../../lib/types";
import DocumentModal from "../DocumentModal";

interface Props {
  companyId: number;
  onPending: (pending: boolean) => void;
}

/** Prompts offered on an empty chat — each maps cleanly to the document_lookup tool. */
const SUGGESTIONS = [
  "Show me documents expiring this week",
  "What's expiring in the next 30 days?",
  "Do I have any fire safety documents?",
  "Show me my insurance certificates",
];

/** Render light markdown: **bold** and line breaks (the agent replies in prose). */
function renderText(text: string) {
  return text.split("\n").map((line, li) => (
    <span key={li}>
      {li > 0 && <br />}
      {line.split(/(\*\*[^*]+\*\*)/g).map((seg, si) =>
        seg.startsWith("**") && seg.endsWith("**") ? (
          <strong key={si}>{seg.slice(2, -2)}</strong>
        ) : (
          <span key={si}>{seg}</span>
        )
      )}
    </span>
  ));
}

function fmtExpiry(doc: MyDocument): string {
  if (doc.noExpiry) return "No expiry";
  if (!doc.expiryDate) return "—";
  const d = new Date(doc.expiryDate);
  const expired = doc.expiryDate < Date.now();
  return `${expired ? "Expired" : "Expires"} ${d.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  })}`;
}

/** A compact, clickable document card shown under an assistant reply. */
function DocCard({ doc, onPreview }: { doc: MyDocument; onPreview: () => void }) {
  const name = doc.nameUA ?? doc.documentInfo?.documentName ?? doc.file?.name ?? "Untitled document";
  const type = doc.documentInfo?.typeInfo?.type;
  const expired = !doc.noExpiry && !!doc.expiryDate && doc.expiryDate < Date.now();
  return (
    <button
      onClick={onPreview}
      className="group flex w-full items-center gap-2.5 rounded-xl border border-slate-200 bg-white px-2.5 py-2 text-left transition hover:border-[#5e90c0] hover:bg-slate-50"
    >
      <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-[#D5E8F0]">
        <FileText size={14} className="text-[#5e90c0]" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block truncate text-xs font-medium text-[#1d2428]">{name}</span>
        <span className="block truncate text-[10px] text-slate-400">
          {type ? `${type} · ` : ""}
          <span className={expired ? "font-semibold text-red-500" : ""}>{fmtExpiry(doc)}</span>
        </span>
      </span>
      <Eye size={14} className="shrink-0 text-slate-300 group-hover:text-[#5e90c0]" />
    </button>
  );
}

/** One message: a bubble, plus document cards for assistant replies. */
function MessageRow({
  message,
  onPreview,
}: {
  message: VeritasMessage;
  onPreview: (doc: MyDocument) => void;
}) {
  const isUser = message.role === "user";
  // De-dupe documents by id (the agent may call the tool more than once).
  const docs = useMemo(() => {
    const seen = new Set<number>();
    return (message.documents ?? []).filter((d) => (seen.has(d.id) ? false : seen.add(d.id)));
  }, [message.documents]);

  return (
    <div className={`flex flex-col gap-1.5 ${isUser ? "items-end" : "items-start"}`}>
      <div
        className={`max-w-[85%] whitespace-pre-wrap rounded-2xl px-3 py-2 text-xs leading-relaxed ${
          isUser
            ? "rounded-br-sm bg-[#5e90c0] text-white"
            : "rounded-bl-sm bg-slate-100 text-[#1d2428]"
        }`}
      >
        {renderText(message.content)}
      </div>
      {docs.length > 0 && (
        <div className="flex w-[85%] flex-col gap-1.5">
          {docs.map((d) => (
            <DocCard key={d.id} doc={d} onPreview={() => onPreview(d)} />
          ))}
        </div>
      )}
    </div>
  );
}

export default function VeritasChat({ companyId, onPending }: Props) {
  const [input, setInput] = useState("");
  const [session, setSession] = useState<VeritasMessage[]>([]);
  const [historyEnabled, setHistoryEnabled] = useState(false);
  const [preview, setPreview] = useState<MyDocument | null>(null);
  const sessionStart = useRef(Date.now());
  const scrollRef = useRef<HTMLDivElement | null>(null);
  const topSentinel = useRef<HTMLDivElement | null>(null);

  // Does the user have prior history for this company? (drives the load action)
  const status = useQuery({
    queryKey: ["veritas-status", companyId],
    queryFn: () => getVeritasHistoryStatus(companyId),
  });

  // Prior messages — only fetched once the user opts in, then lazy-loaded older.
  const history = useInfiniteQuery({
    queryKey: ["veritas-history", companyId],
    enabled: historyEnabled,
    initialPageParam: 1,
    queryFn: ({ pageParam }) => getVeritasMessages({ companyId, page: pageParam }),
    getNextPageParam: (last) => last.nextPage ?? undefined,
  });

  const send = useMutation({
    mutationFn: (message: string) => sendVeritasMessage({ companyId, message }),
    onSuccess: (data) =>
      setSession((s) => [...s, { ...data.message, documents: data.documents }]),
  });

  useEffect(() => onPending(send.isPending), [send.isPending, onPending]);

  // Previous (pre-session) messages, oldest→newest. Filtering by sessionStart
  // keeps this-session turns (shown locally) from appearing twice.
  const previous = useMemo(() => {
    const items = history.data?.pages.flatMap((p) => p.items) ?? [];
    return items.filter((m) => m.created_at < sessionStart.current).reverse();
  }, [history.data]);

  // Lazy-load older history when the top sentinel scrolls into view.
  useEffect(() => {
    const el = topSentinel.current;
    if (!el || !historyEnabled || !history.hasNextPage) return;
    const obs = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !history.isFetchingNextPage) history.fetchNextPage();
      },
      { rootMargin: "120px" }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [historyEnabled, history.hasNextPage, history.isFetchingNextPage, history.fetchNextPage]);

  // Keep the latest turn in view as the conversation grows.
  useEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [session.length, send.isPending]);

  function sendMessage(raw: string) {
    const text = raw.trim();
    if (!text || send.isPending) return;
    setSession((s) => [
      ...s,
      { id: -Date.now(), created_at: Date.now(), role: "user", content: text },
    ]);
    setInput("");
    send.mutate(text);
  }

  function submit() {
    sendMessage(input);
  }

  const showLoadAction = status.data?.hasHistory && !historyEnabled;
  const isEmpty = previous.length === 0 && session.length === 0 && !send.isPending;

  return (
    <div className="flex h-full flex-col">
      {/* Messages */}
      <div ref={scrollRef} className="flex-1 space-y-2.5 overflow-y-auto px-4 py-3">
        {/* Load-previous action (history is never auto-loaded) */}
        {showLoadAction && (
          <button
            onClick={() => setHistoryEnabled(true)}
            className="mx-auto flex items-center gap-1.5 rounded-full border border-slate-200 px-3 py-1 text-[11px] font-medium text-[#5e90c0] hover:bg-slate-50"
          >
            <History size={12} />
            Load previous messages
          </button>
        )}

        {/* Lazy-load sentinel + spinner for older history */}
        {historyEnabled && (
          <>
            <div ref={topSentinel} />
            {history.isFetching && (
              <div className="flex justify-center py-1 text-slate-400">
                <Loader2 size={14} className="animate-spin" />
              </div>
            )}
            {!history.hasNextPage && previous.length > 0 && (
              <p className="py-1 text-center text-[10px] text-slate-300">Start of conversation</p>
            )}
          </>
        )}

        {isEmpty && (
          <div className="flex h-full flex-col items-center justify-center gap-3 px-1 text-center">
            <Sparkles size={22} className="text-[#5e90c0] opacity-60" />
            <p className="text-xs text-slate-400">Ask Veritas about your documents.</p>
            <div className="flex w-full flex-col gap-1.5">
              {SUGGESTIONS.map((s) => (
                <button
                  key={s}
                  onClick={() => sendMessage(s)}
                  className="rounded-xl border border-slate-200 bg-white px-3 py-2 text-left text-xs text-[#1d2428] transition hover:border-[#5e90c0] hover:bg-slate-50"
                >
                  {s}
                </button>
              ))}
            </div>
          </div>
        )}

        {previous.map((m) => (
          <MessageRow key={`h-${m.id}`} message={m} onPreview={setPreview} />
        ))}
        {session.map((m) => (
          <MessageRow key={`s-${m.id}`} message={m} onPreview={setPreview} />
        ))}

        {send.isPending && (
          <div className="flex justify-start">
            <div className="flex items-center gap-1.5 rounded-2xl rounded-bl-sm bg-slate-100 px-3 py-2 text-xs text-slate-400">
              <Loader2 size={12} className="animate-spin" />
              Veritas is thinking…
            </div>
          </div>
        )}

        {send.isError && (
          <p className="text-center text-[11px] text-red-500">
            {errorMessage(send.error, "Couldn't reach Veritas. Try again.")}
          </p>
        )}
      </div>

      {/* Composer */}
      <div className="border-t border-slate-200 p-2.5">
        <div className="flex items-end gap-2">
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                submit();
              }
            }}
            rows={1}
            placeholder="Ask about your documents…"
            className="max-h-28 min-h-[38px] flex-1 resize-none rounded-xl border border-slate-200 px-3 py-2 text-xs text-[#1d2428] outline-none placeholder:text-slate-400 focus:border-[#5e90c0] focus:ring-2 focus:ring-[#5e90c0]/10"
          />
          <button
            onClick={submit}
            disabled={!input.trim() || send.isPending}
            className="flex h-[38px] w-[38px] shrink-0 items-center justify-center rounded-xl bg-[#5e90c0] text-white transition hover:bg-[#4d7dae] disabled:opacity-40"
            aria-label="Send"
          >
            <Send size={15} />
          </button>
        </div>
      </div>

      {preview && <DocumentModal doc={preview} onClose={() => setPreview(null)} />}
    </div>
  );
}
