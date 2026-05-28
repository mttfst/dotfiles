# Projekt Übersicht


```dataviewjs
const POOLS = {
  "main-quest":  { label: "Main Quest",  maxDays: 3  },
  "side-quest":  { label: "Side Quest",  maxDays: 7  },
  "tinkering":   { label: "Tinkering",   maxDays: 12 },
  "meta":        { label: "Meta",        maxDays: 16 },
};
const ORDER = ["main-quest", "side-quest", "tinkering", "meta"];

const getLastLog = (content) => {
  const matches = [...content.matchAll(/^### \[\[(\d{4}-\d{2}-\d{2})\]\]|^### (\d{4}-\d{2}-\d{2})/gm)];
  if (!matches.length) return null;
  const dates = matches.map(m => m[1] ?? m[2]).sort();
  return dates[dates.length - 1];
};

const getNextDue = (content) => {
  const matches = [...content.matchAll(/^- (\d{4}-\d{2}-\d{2}): (.+)$/gm)];
  if (!matches.length) return null;
  const open = matches
    .filter(m => !m[0].includes('~~'))
    .map(m => ({ date: m[1], event: m[2].trim() }))
    .sort((a, b) => a.date.localeCompare(b.date));
  return open.length ? open[0] : null;
};

const today = new Date();
today.setHours(0,0,0,0);

const workdaysBetween = (from, to) => {
  if (!from || !to) return 0;
  let count = 0;
  let cur = new Date(from);
  cur.setHours(0,0,0,0);
  const end = new Date(to);
  end.setHours(0,0,0,0);
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
  if (workdays === 999)  return 0;
  if (workdays < 0)      return 2;
  if (workdays > 4)      return 0;
  if (workdays >= 2)     return 1;
  return 2;
};

const timeToEscalation = (days, maxDays, deadlineWorkdays) => {
  const dlEscalation = deadlineWorkdays === 999 ? 999
    : deadlineWorkdays < 0  ? deadlineWorkdays
    : deadlineWorkdays > 4  ? deadlineWorkdays - 4
    : deadlineWorkdays >= 2 ? deadlineWorkdays - 2
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

// --- Aktive Projekte ---
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
    const due = getNextDue(content);
    const days = workdaysSince(lastLog);
    const deadlineWorkdays = workdaysUntil(due?.date);
    const freqLevel     = ampelFromFreq(days, pool.maxDays);
    const deadlineLevel = ampelFromDeadline(deadlineWorkdays);
    const level         = Math.max(freqLevel, deadlineLevel);
    const icon          = ICONS[level];
    const urgency       = timeToEscalation(days, pool.maxDays, deadlineWorkdays);
    const daysStr = lastLog ? `${days}d ago` : "never";
    const dueStr = due
      ? deadlineWorkdays < 0
        ? `🚨 ${due.date}: ${due.event} (${Math.abs(deadlineWorkdays)}d overdue)`
        : `${due.date}: ${due.event} (${deadlineWorkdays}d)`
      : "";
    rows.push({ label: `${icon} [[${p.file.path}|${p.file.name}]]`, level, urgency, days, daysStr, dueStr });
  }
  rows.sort((a, b) => b.level - a.level || a.urgency - b.urgency || b.days - a.days);
  dv.table(
    [pool.label, "Last Log", "Deadline"],
    rows.map(r => [r.label, r.daysStr, r.dueStr])
  );
}

// --- Waiting (blockiert durch Abhängigkeit) ---
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

// --- Pause (bewusst zurückgestellt) ---
const pausedProjects = dv.pages('"01 - Projects"')
  .where(p => p.status === "pause")
  .array();

if (pausedProjects.length) {
  dv.table(
    ["⏸️ Pause", ""],
    pausedProjects.map(p => [
      `[[${p.file.path}|${p.file.name}]]`,
      ""
    ])
  );
}

// --- ⚠️ Unklar (status/pool fehlt oder unbekannt) ---
const KNOWN_STATUS = ["open", "waiting", "pause"];

const strayProjects = dv.pages('"01 - Projects"')
  .where(p => {
    const s = p.status ? String(p.status).toLowerCase() : null;
    const statusBad = !s || !KNOWN_STATUS.includes(s);
    const poolBad = s === "open" && !p.pool;   // open braucht einen Pool
    return statusBad || poolBad;
  })
  .array();

if (strayProjects.length) {
  dv.table(
    ["⚠️ Unklar", "Problem"],
    strayProjects.map(p => {
      const s = p.status ? String(p.status).toLowerCase() : null;
      let problem;
      if (!s)                               problem = "kein status";
      else if (!KNOWN_STATUS.includes(s))   problem = `status: \`${p.status}\``;
      else                                  problem = "open, aber kein pool";
      return [`[[${p.file.path}|${p.file.name}]]`, problem];
    })
  );
}
```



