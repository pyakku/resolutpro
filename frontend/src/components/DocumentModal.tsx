import { useEffect } from "react";
import { createPortal } from "react-dom";
import { X, Download, ExternalLink, FileQuestion } from "lucide-react";
import type { MyDocument, XanoFile } from "../lib/types";

type Kind = "pdf" | "image" | "text" | "office" | "unknown";

const OFFICE_EXT = ["doc", "docx", "xls", "xlsx", "ppt", "pptx"];

function extOf(name?: string | null): string {
  if (!name) return "";
  const i = name.lastIndexOf(".");
  return i >= 0 ? name.slice(i + 1).toLowerCase() : "";
}

/** Detect how to render a file, from its MIME type with an extension fallback. */
function detectKind(file: XanoFile): Kind {
  const mime = (file.mime ?? file.type ?? "").toLowerCase();
  const ext = extOf(file.name);

  if (mime === "application/pdf" || ext === "pdf") return "pdf";
  if (mime.startsWith("image/") || ["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp"].includes(ext))
    return "image";
  if (mime.startsWith("text/") || ["txt", "csv", "md", "json", "log"].includes(ext)) return "text";
  if (
    mime.includes("officedocument") ||
    mime.includes("msword") ||
    mime.includes("ms-excel") ||
    mime.includes("ms-powerpoint") ||
    OFFICE_EXT.includes(ext)
  )
    return "office";
  return "unknown";
}

/** Microsoft Office Online embed viewer — needs a publicly reachable file URL. */
function officeViewerUrl(url: string): string {
  return `https://view.officeapps.live.com/op/embed.aspx?src=${encodeURIComponent(url)}`;
}

function Preview({ file }: { file: XanoFile }) {
  const kind = detectKind(file);
  const url = file.url;

  switch (kind) {
    case "pdf":
      return <iframe src={url} title={file.name ?? "document"} className="h-full w-full border-0" />;
    case "image":
      return (
        <div className="flex h-full w-full items-center justify-center overflow-auto bg-slate-50 p-4">
          <img src={url} alt={file.name ?? "document"} className="max-h-full max-w-full object-contain" />
        </div>
      );
    case "text":
      return <iframe src={url} title={file.name ?? "document"} className="h-full w-full border-0 bg-white" />;
    case "office":
      return (
        <iframe
          src={officeViewerUrl(url)}
          title={file.name ?? "document"}
          className="h-full w-full border-0"
        />
      );
    default:
      return (
        <div className="flex h-full w-full flex-col items-center justify-center gap-3 bg-slate-50 text-slate-400">
          <FileQuestion size={40} className="opacity-50" />
          <p className="text-sm">Preview isn't available for this file type.</p>
          <a
            href={url}
            target="_blank"
            rel="noreferrer"
            className="flex items-center gap-1.5 rounded-lg bg-[#5e90c0] px-4 py-2 text-xs font-semibold text-white hover:bg-[#4d7dae]"
          >
            <Download size={13} /> Download
          </a>
        </div>
      );
  }
}

interface Props {
  doc: MyDocument;
  onClose: () => void;
}

export default function DocumentModal({ doc, onClose }: Props) {
  // Close on Escape.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  const file = doc.file;
  const title = doc.nameUA ?? doc.documentInfo?.documentName ?? file?.name ?? "Document";

  return createPortal(
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
    >
      <div
        className="flex h-[90vh] w-full max-w-5xl flex-col overflow-hidden rounded-xl bg-white shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between border-b border-slate-200 px-4 py-3">
          <h2 className="truncate pr-4 text-sm font-semibold text-[#1d2428]">{title}</h2>
          <div className="flex items-center gap-1">
            {file?.url && (
              <>
                <a
                  href={file.url}
                  target="_blank"
                  rel="noreferrer"
                  title="Open in new tab"
                  className="rounded-lg p-2 text-slate-500 hover:bg-slate-100 hover:text-[#1d2428]"
                >
                  <ExternalLink size={16} />
                </a>
                <a
                  href={file.url}
                  download={file.name ?? undefined}
                  title="Download"
                  className="rounded-lg p-2 text-slate-500 hover:bg-slate-100 hover:text-[#1d2428]"
                >
                  <Download size={16} />
                </a>
              </>
            )}
            <button
              onClick={onClose}
              title="Close"
              className="rounded-lg p-2 text-slate-500 hover:bg-slate-100 hover:text-[#1d2428]"
            >
              <X size={16} />
            </button>
          </div>
        </div>

        {/* Body */}
        <div className="min-h-0 flex-1">
          {file?.url ? (
            <Preview file={file} />
          ) : (
            <div className="flex h-full w-full flex-col items-center justify-center gap-2 text-slate-400">
              <FileQuestion size={40} className="opacity-50" />
              <p className="text-sm">No file is attached to this document.</p>
            </div>
          )}
        </div>
      </div>
    </div>,
    document.body
  );
}
