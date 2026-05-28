<%*
const folder = '06 - Logs'; 
const files = app.vault.getMarkdownFiles()
	.filter(f => f.path.startsWith(folder + '/'))
	.sort((a, b) => b.basename.localeCompare(a.basename)); 
const lastLog = files.length > 1 ? files[1].basename : null; 
const n = files.length; 
const DEADLOG = `Deadlog #${String(n).padStart(3,'0')}`;
-%>
---
date: "<% tp.date.now('YYYY-MM-DD') %>T<% tp.date.now('HH:mm') %>"
tags: [Daily, Deadlog]
cssclasses: [daily, "<% tp.date.now('dddd') %>"]
deadlog: "<% DEADLOG %>"
---

# *{{date:dddd}}*
### *{{date:Do MMMM  YYYY}}*
### ☠️ <% DEADLOG %>
### Location



#### Report
**Mission Outcome:** ...

**Debrief:**
- What did I actually achieve today?  
	- ...

- Highlight / key event:  
	- ...

- What did not go well?  
	- ...

- Primary cause (if known):  
	- ...

- Most important thing for tomorrow:  
	- ...

---
#### Mission
***Mission Intend***

***Objectives***
- [ ] Task1
- [ ] Task2
- [ ] Task3

***SIDE TASKS***
- [ ] Task1

---
#### Operations
- Timeblocks
- Events
- Meetings

---
#### Pending
- Importend Blocked Item
	- What need to be done first

---
#### Boot Sequence
**Time & Constraints**
- [ ] Stamp In 
- [ ] End-of-shift defined
- [ ] Shutdown alarm set (T-30)

**Environment & Readiness**
- [ ] Water available
- [ ] Glasses cleaned
- [ ] Workspace clear
- [ ] Notebook opened / new page

**Mission Setup**
- [ ] Last report reviewed: <% lastLog ? `[[06 - Logs/${lastLog}]]` : '(kein vorheriger Log)' %>
- [ ] Project status reviewed
- [ ] Calendar checked
- [ ] Location Set
- [ ] Mission intent defined
- [ ] 3 Objectives formulated

**Start Sequence**
- [ ] Communications muted
- [ ] Focus mode enabled
- [ ] Countdown initiated (T-5…)

---
#### Shutdown Sequence
**Debrief & Closure**
- [ ] Report written (outcome, highlight, what didn't work)
- [ ] All active projects logged

**Note Processing**
- [ ] Floating notes reviewed (notebook)
- [ ] Relevant notes transferred to vault

**Data Integrity**
- [ ] Files saved
- [ ] Commits made

**Shutdown**
- [ ] Stamp Out 
- [ ] Workday terminated