
# Archived Projects 

```dataviewjs
const REASONS = {
  "done":    { label: "✅ Done" },
  "dropped": { label: "🗑️ Dropped" },
  "frozen":  { label: "🧊 Frozen" },
};
const ORDER = ["done", "dropped", "frozen"];

const getLastLog = (content) => {
  const matches = [...content.matchAll(/^### \[\[(\d{4}-\d{2}-\d{2})\]\]|^### (\d{4}-\d{2}-\d{2})/gm)];
  if (!matches.length) return null;
  const dates = matches.map(m => m[1] ?? m[2]).sort();
  return dates[dates.length - 1];
};

const archived = dv.pages('"07 - Archive"').array();

if (!archived.length) {
  dv.paragraph("*Archive is empty.*");
} else {
  // One table per reason
  for (const reasonKey of ORDER) {
    const reason = REASONS[reasonKey];
    const projects = archived
      .filter(p => p.status && String(p.status).toLowerCase() === reasonKey);
    if (!projects.length) continue;

    const rows = [];
    for (const p of projects) {
      const content = await dv.io.load(p.file.path);
      const lastLog = getLastLog(content);
      const pool = p.pool ? String(p.pool) : "—";
      rows.push({
        label: `[[${p.file.path}|${p.file.name}]]`,
        date: lastLog ?? "—",
        pool,
      });
    }
    rows.sort((a, b) => b.date.localeCompare(a.date));
    dv.table(
      [reason.label, "Completed", "Pool"],
      rows.map(r => [r.label, r.date, r.pool])
    );
  }

  // --- ⚠️ Unclear (archived, but no/unknown reason) ---
  const strayArchived = archived
    .filter(p => {
      const s = p.status ? String(p.status).toLowerCase() : null;
      return !s || !ORDER.includes(s);
    });

  if (strayArchived.length) {
    dv.table(
      ["⚠️ Unclear", "status"],
      strayArchived.map(p => [
        `[[${p.file.path}|${p.file.name}]]`,
        p.status ? `\`${p.status}\`` : "no status"
      ])
    );
  }
}
```