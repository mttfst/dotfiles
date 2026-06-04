
# Running Projects

```dataviewjs
const POOLS = {
  "main-quest":  { label: "Main Quest",  maxDays: 5  },
  "side-quest":  { label: "Side Quest",  maxDays: 10 },
  "tinkering":   { label: "Tinkering",   maxDays: 15 },
  "meta":        { label: "Meta",        maxDays: 20 },
};
const ORDER = ["main-quest", "side-quest", "tinkering", "meta"];

const getLastLog = (content) => {
  const matches = [...content.matchAll(/^### \[\[(\d{4}-\d{2}-\d{2})\]\]|^### (\d{4}-\d{2}-\d{2})/gm)];
  if (!matches.length) return null;
  const dates = matches.map(m => m[1] ?? m[2]).sort();
  return dates[dates.length - 1];
};

const getAllDeadlines = (content) => {
  const matches = [...content.matchAll(/^- (\d{4}-\d{2}-\d{2}): (.+)$/gm)];
  if (!matches.length) return { open: [], overdue: [], total: 0 };
  const all = matches.map(m => ({
    date: m[1],
    event: m[2].trim(),
    done: m[0].includes('~~')
  }));
  const total = all.length;
  const open    = all.filter(d => !d.done && d.date >= todayStr).sort((a,b) => a.date.localeCompare(b.date));
  const overdue = all.filter(d => !d.done && d.date < todayStr).sort((a,b) => a.date.localeCompare(b.date));
  return { open, overdue, total };
};

const today = new Date();
today.setHours(0, 0, 0, 0);
const todayStr = today.toISOString().slice(0, 10);

const workdaysBetween = (from, to) => {
  if (!from || !to) return 0;
  let count = 0;
  let cur = new Date(from);
  cur.setHours(0, 0, 0, 0);
  const end = new Date(to);
  end.setHours(0, 0, 0, 0);
  const dir = end > cur ? 1 : -1;
  while (cur.getTime() !== end.getTime()) {
    cur.setDate(cur.getDate() + dir);
    const dow = cur.getDay();
    if (dow !== 0 && dow !== 6) count++;
  }
  return count * dir;
};

const workdaysSince = (dateStr) => {
  if (!dateStr) return 999;
  return workdaysBetween(new Date(dateStr), today);
};

const workdaysUntil = (dateStr) => {
  if (!dateStr) return 999;
  return workdaysBetween(today, new Date(dateStr));
};

const ampelFromFreq = (days, maxDays) => {
  if (days <= maxDays * 0.75) return 0;
  if (days <= maxDays)        return 1;
  return 2;
};

const ampelFromDeadline = (workdays) => {
  if (workdays === 999) return 0;
  if (workdays < 0)     return 2;
  if (workdays > 5)     return 0;
  if (workdays >= 3)    return 1;
  return 2;
};

const timeToEscalation = (days, maxDays, deadlineWorkdays) => {
  const dlEscalation = deadlineWorkdays === 999 ? 999
    : deadlineWorkdays < 0  ? deadlineWorkdays
    : deadlineWorkdays > 5  ? deadlineWorkdays - 5
    : deadlineWorkdays >= 3 ? deadlineWorkdays - 3
    : deadlineWorkdays;
  const freqLevel = ampelFromFreq(days, maxDays);
  let freqEscalation;
  if (freqLevel === 0) {
    freqEscalation = Math.ceil(maxDays * 0.75) - days;
  } else if (freqLevel === 1) {
    freqEscalation = maxDays - days;
  } else {
    freqEscalation = 999;
  }
  return Math.min(freqEscalation, dlEscalation);
};

const ICONS = ["🟢", "🟡", "🔴"];

// --- Active projects ---
const activeProjects = dv.pages('"01 - Projects"')
  .where(p => p.status === "open" && p.pool);

for (const poolKey of ORDER) {
  const pool = POOLS[poolKey];
  const poolProjects = activeProjects
    .where(p => String(p.pool).toLowerCase() === poolKey)
    .array();
  if (!poolProjects.length) continue;

  const rows = [];
  for (const p of poolProjects) {
    const content = await dv.io.load(p.file.path);
    const lastLog = getLastLog(content);
    const { open, overdue, total } = getAllDeadlines(content);

    // Urgency is driven by the next upcoming deadline (first open) or worst overdue
    const nextDue = overdue.length ? overdue[0] : (open.length ? open[0] : null);
    const deadlineWorkdays = nextDue ? workdaysUntil(nextDue.date) : 999;

    const days = workdaysSince(lastLog);
    const freqLevel     = ampelFromFreq(days, pool.maxDays);
    const deadlineLevel = ampelFromDeadline(deadlineWorkdays);
    const level         = Math.max(freqLevel, deadlineLevel);
    const icon          = ICONS[level];
    const urgency       = timeToEscalation(days, pool.maxDays, deadlineWorkdays);
    const daysStr       = lastLog ? `${days}d ago` : "never";

    // Build deadline cell: all overdue, then all on the next due date
    const dlLines = [];
    for (const d of overdue) {
      const wd = Math.abs(workdaysUntil(d.date));
      dlLines.push(`🚨 ${d.date}: ${d.event} (${wd}d overdue)`);
    }
    if (open.length > 0) {
      const nextDate = open[0].date;
      for (const d of open.filter(d => d.date === nextDate)) {
        const wd = workdaysUntil(d.date);
        dlLines.push(`${d.date}: ${d.event} (${wd}d)`);
      }
    }
    const dueStr = dlLines.join("<br>");

    // Header counter: open = overdue + upcoming (not done), shown as (pending/total)
    const nextDate = open.length ? open[0].date : null; 
    const nextOpen = nextDate ? open.filter(d => d.date === nextDate) : [];
    const pending = overdue.length + nextOpen.length;

    rows.push({ label: `${icon} [[${p.file.path}|${p.file.name}]]`, level, urgency, days, daysStr, dueStr, pending, total });
  }
  rows.sort((a, b) => b.level - a.level || a.urgency - b.urgency || b.days - a.days);

  // Sum up for header
  const totalPending = rows.reduce((s, r) => s + r.pending, 0);
  const totalAll     = rows.reduce((s, r) => s + r.total, 0);
  const dlHeader     = totalAll > 0
    ? `Deadline (${totalPending}/${totalAll})`
    : "Deadline";

  dv.table(
    [pool.label, "Last Log", dlHeader],
    rows.map(r => [r.label, r.daysStr, r.dueStr])
  );
}

// --- Waiting (blocked by dependency) ---
const waitingProjects = dv.pages('"01 - Projects"')
  .where(p => p.status === "waiting")
  .array();

if (waitingProjects.length) {
  dv.table(
    ["⏳ Waiting", "Blocked by"],
    waitingProjects.map(p => [
      `[[${p.file.path}|${p.file.name}]]`,
      p.waiting_for ?? "—"
    ])
  );
}

// --- Paused (deliberately deferred) ---
const pausedProjects = dv.pages('"01 - Projects"')
  .where(p => p.status === "pause")
  .array();

if (pausedProjects.length) {
  dv.table(
    ["⏸️ Paused", ""],
    pausedProjects.map(p => [
      `[[${p.file.path}|${p.file.name}]]`,
      ""
    ])
  );
}

// --- Unclear (missing or unknown status/pool) ---
const KNOWN_STATUS = ["open", "waiting", "pause"];

const strayProjects = dv.pages('"01 - Projects"')
  .where(p => {
    const s = p.status ? String(p.status).toLowerCase() : null;
    const statusBad = !s || !KNOWN_STATUS.includes(s);
    const poolBad = s === "open" && !p.pool;
    return statusBad || poolBad;
  })
  .array();

if (strayProjects.length) {
  dv.table(
    ["⚠️ Unclear", "Problem"],
    strayProjects.map(p => {
      const s = p.status ? String(p.status).toLowerCase() : null;
      let problem;
      if (!s)                             problem = "no status";
      else if (!KNOWN_STATUS.includes(s)) problem = `status: \`${p.status}\``;
      else                                problem = "open, but no pool";
      return [`[[${p.file.path}|${p.file.name}]]`, problem];
    })
  );
}
```



